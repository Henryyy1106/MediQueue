package com.mediqueue.dao;

import com.mediqueue.model.Clinic;
import com.mediqueue.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ClinicDAO - Database operations for Clinic entity
 * MediQueue | SWE3024 Code Camp
 */
public class ClinicDAO {

    public List<Clinic> getAllClinics() throws SQLException {
        String sql = "SELECT c.*, " +
                "(SELECT COUNT(*) FROM queue q WHERE q.clinic_id = c.clinic_id AND q.queue_date = CURDATE() AND q.status = 'waiting') AS current_queue, " +
                "COALESCE((SELECT cs.avg_wait_mins FROM clinic_stats cs WHERE cs.clinic_id = c.clinic_id AND cs.stat_date = CURDATE() AND cs.hour_slot = HOUR(NOW()) LIMIT 1), 30) AS est_wait " +
                "FROM clinics c WHERE c.is_active = TRUE ORDER BY c.name";
        Connection conn = null;
        List<Clinic> clinics = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) {
                Clinic c = mapResultSet(rs);
                c.setCurrentQueueCount(rs.getInt("current_queue"));
                c.setEstimatedWaitMins(rs.getInt("est_wait"));
                clinics.add(c);
            }
            return clinics;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public Clinic getClinicById(int clinicId) throws SQLException {
        String sql = "SELECT c.*, " +
                "(SELECT COUNT(*) FROM queue q WHERE q.clinic_id = c.clinic_id AND q.queue_date = CURDATE() AND q.status = 'waiting') AS current_queue, " +
                "COALESCE((SELECT cs.avg_wait_mins FROM clinic_stats cs WHERE cs.clinic_id = c.clinic_id AND cs.stat_date = CURDATE() AND cs.hour_slot = HOUR(NOW()) LIMIT 1), 30) AS est_wait " +
                "FROM clinics c WHERE c.clinic_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, clinicId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Clinic c = mapResultSet(rs);
                c.setCurrentQueueCount(rs.getInt("current_queue"));
                c.setEstimatedWaitMins(rs.getInt("est_wait"));
                return c;
            }
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<Clinic> searchClinics(String keyword) throws SQLException {
        String sql = "SELECT c.*, " +
                "(SELECT COUNT(*) FROM queue q WHERE q.clinic_id = c.clinic_id AND q.queue_date = CURDATE() AND q.status = 'waiting') AS current_queue, " +
                "COALESCE((SELECT cs.avg_wait_mins FROM clinic_stats cs WHERE cs.clinic_id = c.clinic_id AND cs.stat_date = CURDATE() AND cs.hour_slot = HOUR(NOW()) LIMIT 1), 30) AS est_wait " +
                "FROM clinics c WHERE c.is_active = TRUE AND (c.name LIKE ? OR c.district LIKE ? OR c.address LIKE ?) ORDER BY est_wait ASC";
        Connection conn = null;
        List<Clinic> clinics = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw); ps.setString(2, kw); ps.setString(3, kw);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Clinic c = mapResultSet(rs);
                c.setCurrentQueueCount(rs.getInt("current_queue"));
                c.setEstimatedWaitMins(rs.getInt("est_wait"));
                clinics.add(c);
            }
            return clinics;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private Clinic mapResultSet(ResultSet rs) throws SQLException {
        Clinic c = new Clinic();
        c.setClinicId(rs.getInt("clinic_id"));
        c.setName(rs.getString("name"));
        c.setAddress(rs.getString("address"));
        c.setDistrict(rs.getString("district"));
        c.setState(rs.getString("state"));
        c.setPhone(rs.getString("phone"));
        c.setOperatingHours(rs.getString("operating_hours"));
        c.setCapacity(rs.getInt("capacity"));
        c.setRating(rs.getDouble("rating"));
        c.setRatingCount(rs.getInt("rating_count"));
        c.setLatitude(rs.getDouble("latitude"));
        c.setLongitude(rs.getDouble("longitude"));
        c.setActive(rs.getBoolean("is_active"));
        return c;
    }
}
