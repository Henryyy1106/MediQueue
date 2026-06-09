package com.mediqueue.dao;

import com.mediqueue.model.Rating;
import com.mediqueue.util.DatabaseConnection;

import java.sql.*;

/**
 * RatingDAO - Database operations for clinic ratings
 * MediQueue | SWE3024 Code Camp
 */
public class RatingDAO {

    /**
     * Add (or update) a patient's rating for a completed visit, then refresh
     * the clinic's average rating. A patient may only have one rating per
     * appointment (enforced by a unique key), so re-submitting overwrites it.
     */
    private static final String RECALC_SQL = "UPDATE clinics c SET " +
            "c.rating = COALESCE((SELECT ROUND(AVG(cr.stars), 1) FROM clinic_ratings cr WHERE cr.clinic_id = c.clinic_id), 0), " +
            "c.rating_count = (SELECT COUNT(*) FROM clinic_ratings cr WHERE cr.clinic_id = c.clinic_id) " +
            "WHERE c.clinic_id = ?";

    public boolean addRating(Rating r) throws SQLException {
        int stars = r.getStars();
        if (stars < 1) stars = 1;
        if (stars > 5) stars = 5;

        String sql = "INSERT INTO clinic_ratings (user_id, clinic_id, appt_id, stars, comment) VALUES (?,?,?,?,?) " +
                "ON DUPLICATE KEY UPDATE stars = VALUES(stars), comment = VALUES(comment)";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // insert + average recalc must be atomic
            try {
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, r.getUserId());
                ps.setInt(2, r.getClinicId());
                ps.setInt(3, r.getApptId());
                ps.setInt(4, stars);
                ps.setString(5, r.getComment());
                boolean ok = ps.executeUpdate() > 0;
                recalcWithin(conn, r.getClinicId());
                conn.commit();
                return ok;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Recalculate and store a clinic's average rating and total rating count
     * from the clinic_ratings table.
     */
    public void recalculateClinicRating(int clinicId) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            recalcWithin(conn, clinicId);
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    // Runs the recalc on a caller-supplied connection (so it can join a transaction).
    private void recalcWithin(Connection conn, int clinicId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(RECALC_SQL)) {
            ps.setInt(1, clinicId);
            ps.executeUpdate();
        }
    }

    /**
     * Return the star rating this user already gave for an appointment,
     * or 0 if they have not rated it yet.
     */
    public int getRatingForAppt(int userId, int apptId) throws SQLException {
        String sql = "SELECT stars FROM clinic_ratings WHERE user_id = ? AND appt_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, apptId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt("stars") : 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }
}
