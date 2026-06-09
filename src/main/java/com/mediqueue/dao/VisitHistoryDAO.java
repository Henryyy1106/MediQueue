package com.mediqueue.dao;

import com.mediqueue.model.VisitHistory;
import com.mediqueue.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * VisitHistoryDAO
 * MediQueue | SWE3024 Code Camp
 * Author: Ong Rong Yaw (22061584) - Module 5
 */
public class VisitHistoryDAO {

    public boolean addVisit(VisitHistory v) throws SQLException {
        String sql = "INSERT INTO visit_history (user_id, clinic_id, appt_id, visit_date, actual_wait_mins, outcome, doctor_notes, ai_summary) VALUES (?,?,?,?,?,?,?,?)";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, v.getUserId());
            ps.setInt(2, v.getClinicId());
            ps.setInt(3, v.getApptId());
            ps.setDate(4, v.getVisitDate());
            ps.setInt(5, v.getActualWaitMins());
            ps.setString(6, v.getOutcome());
            ps.setString(7, v.getDoctorNotes());
            ps.setString(8, v.getAiSummary());
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<VisitHistory> getVisitsByUser(int userId) throws SQLException {
        String sql = "SELECT vh.*, c.name AS clinic_name, u.name AS patient_name, a.time_slot, " +
                "COALESCE(cr.stars, 0) AS user_rating " +
                "FROM visit_history vh JOIN clinics c ON vh.clinic_id = c.clinic_id " +
                "JOIN users u ON vh.user_id = u.user_id " +
                "LEFT JOIN appointments a ON vh.appt_id = a.appt_id " +
                "LEFT JOIN clinic_ratings cr ON cr.appt_id = vh.appt_id AND cr.user_id = vh.user_id " +
                "WHERE vh.user_id = ? ORDER BY vh.visit_date DESC";
        Connection conn = null;
        List<VisitHistory> list = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
            return list;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<VisitHistory> getAllVisits() throws SQLException {
        String sql = "SELECT vh.*, c.name AS clinic_name, u.name AS patient_name, a.time_slot " +
                "FROM visit_history vh JOIN clinics c ON vh.clinic_id = c.clinic_id " +
                "JOIN users u ON vh.user_id = u.user_id " +
                "LEFT JOIN appointments a ON vh.appt_id = a.appt_id " +
                "ORDER BY vh.visit_date DESC";
        Connection conn = null;
        List<VisitHistory> list = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) list.add(mapResultSet(rs));
            return list;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private VisitHistory mapResultSet(ResultSet rs) throws SQLException {
        VisitHistory v = new VisitHistory();
        v.setVisitId(rs.getInt("visit_id"));
        v.setUserId(rs.getInt("user_id"));
        v.setClinicId(rs.getInt("clinic_id"));
        v.setApptId(rs.getInt("appt_id"));
        v.setVisitDate(rs.getDate("visit_date"));
        v.setActualWaitMins(rs.getInt("actual_wait_mins"));
        v.setOutcome(rs.getString("outcome"));
        v.setDoctorNotes(rs.getString("doctor_notes"));
        v.setAiSummary(rs.getString("ai_summary"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        try { v.setClinicName(rs.getString("clinic_name")); } catch (SQLException ignored) {}
        try { v.setPatientName(rs.getString("patient_name")); } catch (SQLException ignored) {}
        try { v.setTimeSlot(rs.getString("time_slot")); } catch (SQLException ignored) {}
        try { v.setUserRating(rs.getInt("user_rating")); } catch (SQLException ignored) {}
        return v;
    }
}
