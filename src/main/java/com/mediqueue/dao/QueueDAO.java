package com.mediqueue.dao;

import com.mediqueue.model.Queue;
import com.mediqueue.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * QueueDAO - Database operations for Queue entity
 * MediQueue | SWE3024 Code Camp
 * Author: Ong Rong Yaw (22061584) - Module 5: Queue Dashboard & Reporting
 */
public class QueueDAO {

    public int addToQueue(Queue queue) throws SQLException {
        String posSql = "SELECT COALESCE(MAX(position), 0) + 1 FROM queue WHERE clinic_id=? AND queue_date=?";
        String insertSql = "INSERT INTO queue (clinic_id, appt_id, user_id, position, status, estimated_wait_mins, queue_date) VALUES (?,?,?,?,?,?,?)";
        Connection conn = null;
        try {
            int minutesPerPatient = new AppSettingDAO().getIntSetting("queue.default_minutes_per_patient", 10);
            conn = DatabaseConnection.getConnection();
            PreparedStatement posPs = conn.prepareStatement(posSql);
            posPs.setInt(1, queue.getClinicId());
            posPs.setDate(2, queue.getQueueDate());
            ResultSet rs = posPs.executeQuery();
            int position = rs.next() ? rs.getInt(1) : 1;

            PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, queue.getClinicId());
            ps.setInt(2, queue.getApptId());
            ps.setInt(3, queue.getUserId());
            ps.setInt(4, position);
            ps.setString(5, queue.getStatus() != null ? queue.getStatus() : "waiting");
            ps.setInt(6, position * minutesPerPatient);
            ps.setDate(7, queue.getQueueDate());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : -1;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public Queue getQueueByApptId(int apptId) throws SQLException {
        String sql = "SELECT q.*, u.name AS patient_name, c.name AS clinic_name, a.time_slot, a.urgency_level, a.symptoms " +
                "FROM queue q JOIN users u ON q.user_id = u.user_id JOIN clinics c ON q.clinic_id = c.clinic_id " +
                "JOIN appointments a ON q.appt_id = a.appt_id WHERE q.appt_id = ?";
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

    public Queue getActiveQueueByUser(int userId) throws SQLException {
        String sql = "SELECT q.*, u.name AS patient_name, c.name AS clinic_name, a.time_slot, a.urgency_level, a.symptoms " +
                "FROM queue q JOIN users u ON q.user_id = u.user_id JOIN clinics c ON q.clinic_id = c.clinic_id " +
                "JOIN appointments a ON q.appt_id = a.appt_id " +
                "WHERE q.user_id = ? AND q.queue_date = CURDATE() AND q.status IN ('waiting', 'in_progress') " +
                "ORDER BY q.queue_id DESC LIMIT 1";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSet(rs);
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<Queue> getQueueByClinicAndDate(int clinicId, Date date) throws SQLException {
        String sql = "SELECT q.*, u.name AS patient_name, c.name AS clinic_name, a.time_slot, a.urgency_level, a.symptoms " +
                "FROM queue q JOIN users u ON q.user_id = u.user_id JOIN clinics c ON q.clinic_id = c.clinic_id " +
                "JOIN appointments a ON q.appt_id = a.appt_id " +
                "WHERE q.clinic_id = ? AND q.queue_date = ? ORDER BY " +
                "FIELD(a.urgency_level, 'emergency', 'urgent', 'routine'), q.position ASC";
        Connection conn = null;
        List<Queue> list = new ArrayList<>();
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

    public List<Queue> getAllTodayQueue() throws SQLException {
        return getAllQueueByDate(new Date(System.currentTimeMillis()));
    }

    public List<Queue> getAllQueueByDate(Date date) throws SQLException {
        String sql = "SELECT q.*, u.name AS patient_name, c.name AS clinic_name, a.time_slot, a.urgency_level, a.symptoms " +
                "FROM queue q JOIN users u ON q.user_id = u.user_id JOIN clinics c ON q.clinic_id = c.clinic_id " +
                "JOIN appointments a ON q.appt_id = a.appt_id " +
                "WHERE q.queue_date = ? ORDER BY c.name, FIELD(a.urgency_level, 'emergency', 'urgent', 'routine'), q.position";
        Connection conn = null;
        List<Queue> list = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDate(1, date);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapResultSet(rs));
            return list;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public boolean updateQueueStatus(int queueId, String status) throws SQLException {
        String sql = "UPDATE queue SET status=?, updated_at=NOW()" +
                ("in_progress".equals(status) ? ", called_at=NOW()" : "") +
                ("done".equals(status) ? ", completed_at=NOW()" : "") +
                " WHERE queue_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, queueId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public boolean updateQueueStatusByApptId(int apptId, String status) throws SQLException {
        Queue queue = getQueueByApptId(apptId);
        return queue != null && updateQueueStatus(queue.getQueueId(), status);
    }

    public boolean removeQueueByApptId(int apptId) throws SQLException {
        String sql = "DELETE FROM queue WHERE appt_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, apptId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public int getWaitingCountByClinic(int clinicId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM queue WHERE clinic_id=? AND queue_date=CURDATE() AND status='waiting'";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, clinicId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private Queue mapResultSet(ResultSet rs) throws SQLException {
        Queue q = new Queue();
        q.setQueueId(rs.getInt("queue_id"));
        q.setClinicId(rs.getInt("clinic_id"));
        q.setApptId(rs.getInt("appt_id"));
        q.setUserId(rs.getInt("user_id"));
        q.setPosition(rs.getInt("position"));
        q.setStatus(rs.getString("status"));
        q.setEstimatedWaitMins(rs.getInt("estimated_wait_mins"));
        q.setQueueDate(rs.getDate("queue_date"));
        q.setCalledAt(rs.getTimestamp("called_at"));
        q.setCompletedAt(rs.getTimestamp("completed_at"));
        q.setUpdatedAt(rs.getTimestamp("updated_at"));
        try { q.setPatientName(rs.getString("patient_name")); } catch (SQLException ignored) {}
        try { q.setClinicName(rs.getString("clinic_name")); } catch (SQLException ignored) {}
        try { q.setTimeSlot(rs.getString("time_slot")); } catch (SQLException ignored) {}
        try { q.setUrgencyLevel(rs.getString("urgency_level")); } catch (SQLException ignored) {}
        try { q.setSymptoms(rs.getString("symptoms")); } catch (SQLException ignored) {}
        return q;
    }
}
