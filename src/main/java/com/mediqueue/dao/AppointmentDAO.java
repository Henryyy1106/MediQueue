package com.mediqueue.dao;

import com.mediqueue.model.Appointment;
import com.mediqueue.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AppointmentDAO - Database operations for Appointment entity
 * MediQueue | SWE3024 Code Camp
 * Author: Si Thu Lin Khant (22042642) - Module 2: Appointment Booking
 */
public class AppointmentDAO {

    public int createAppointment(Appointment appt) throws SQLException {
        String sql = "INSERT INTO appointments (user_id, clinic_id, appt_date, time_slot, reason, symptoms, status, urgency_level, ai_notes) VALUES (?,?,?,?,?,?,?,?,?)";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, appt.getUserId());
            ps.setInt(2, appt.getClinicId());
            ps.setDate(3, appt.getApptDate());
            ps.setString(4, appt.getTimeSlot());
            ps.setString(5, appt.getReason());
            ps.setString(6, appt.getSymptoms());
            ps.setString(7, appt.getStatus() != null ? appt.getStatus() : "pending");
            ps.setString(8, appt.getUrgencyLevel() != null ? appt.getUrgencyLevel() : "routine");
            ps.setString(9, appt.getAiNotes());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
            return -1;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public Appointment getAppointmentById(int apptId) throws SQLException {
        String sql = "SELECT a.*, u.name AS patient_name, c.name AS clinic_name, c.address AS clinic_address " +
                "FROM appointments a JOIN users u ON a.user_id = u.user_id JOIN clinics c ON a.clinic_id = c.clinic_id " +
                "WHERE a.appt_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, apptId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSet(rs);
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<Appointment> getAppointmentsByUser(int userId) throws SQLException {
        String sql = "SELECT a.*, u.name AS patient_name, c.name AS clinic_name, c.address AS clinic_address " +
                "FROM appointments a JOIN users u ON a.user_id = u.user_id JOIN clinics c ON a.clinic_id = c.clinic_id " +
                "WHERE a.user_id = ? ORDER BY a.appt_date DESC, a.time_slot DESC";
        Connection conn = null;
        List<Appointment> list = new ArrayList<>();
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

    public List<Appointment> getAppointmentsByClinicAndDate(int clinicId, Date date) throws SQLException {
        String sql = "SELECT a.*, u.name AS patient_name, c.name AS clinic_name, c.address AS clinic_address " +
                "FROM appointments a JOIN users u ON a.user_id = u.user_id JOIN clinics c ON a.clinic_id = c.clinic_id " +
                "WHERE a.clinic_id = ? AND a.appt_date = ? AND a.status != 'cancelled' ORDER BY a.time_slot";
        Connection conn = null;
        List<Appointment> list = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, clinicId);
            ps.setDate(2, date);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
            return list;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<Appointment> getAllAppointments() throws SQLException {
        String sql = "SELECT a.*, u.name AS patient_name, c.name AS clinic_name, c.address AS clinic_address " +
                "FROM appointments a JOIN users u ON a.user_id = u.user_id JOIN clinics c ON a.clinic_id = c.clinic_id " +
                "ORDER BY a.appt_date DESC, a.time_slot DESC";
        Connection conn = null;
        List<Appointment> list = new ArrayList<>();
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

    public boolean updateStatus(int apptId, String status) throws SQLException {
        String sql = "UPDATE appointments SET status=?, updated_at=NOW() WHERE appt_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, apptId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public boolean cancelAppointment(int apptId, int userId) throws SQLException {
        String sql = "UPDATE appointments SET status='cancelled', updated_at=NOW() WHERE appt_id=? AND user_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, apptId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public boolean isTimeSlotTaken(int clinicId, Date date, String timeSlot) throws SQLException {
        String sql = "SELECT COUNT(*) FROM appointments WHERE clinic_id=? AND appt_date=? AND time_slot=? AND status != 'cancelled'";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, clinicId);
            ps.setDate(2, date);
            ps.setString(3, timeSlot);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) >= 5; // max 5 per slot
            return false;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private Appointment mapResultSet(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setApptId(rs.getInt("appt_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setClinicId(rs.getInt("clinic_id"));
        a.setApptDate(rs.getDate("appt_date"));
        a.setTimeSlot(rs.getString("time_slot"));
        a.setReason(rs.getString("reason"));
        a.setSymptoms(rs.getString("symptoms"));
        a.setStatus(rs.getString("status"));
        a.setUrgencyLevel(rs.getString("urgency_level"));
        a.setAiNotes(rs.getString("ai_notes"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        try { a.setPatientName(rs.getString("patient_name")); } catch (SQLException ignored) {}
        try { a.setClinicName(rs.getString("clinic_name")); } catch (SQLException ignored) {}
        try { a.setClinicAddress(rs.getString("clinic_address")); } catch (SQLException ignored) {}
        return a;
    }
}
