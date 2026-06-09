package com.mediqueue.dao;

import com.mediqueue.model.User;
import com.mediqueue.util.DatabaseConnection;
import com.mediqueue.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO - Database operations for User entity
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 */
public class UserDAO {

    /**
     * Register a new user
     */
    public boolean registerUser(User user) throws SQLException {
        String sql = "INSERT INTO users (name, email, password_hash, role, phone, ic_number, date_of_birth, gender, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, PasswordUtil.hashPassword(user.getPasswordHash()));
            ps.setString(4, user.getRole() != null ? user.getRole() : "patient");
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getIcNumber());
            ps.setDate(7, user.getDateOfBirth());
            ps.setString(8, user.getGender());
            ps.setString(9, user.getAddress());
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Authenticate user - returns User object if credentials are valid
     */
    public User authenticateUser(String email, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password_hash");
                if (PasswordUtil.checkPassword(password, storedHash)) {
                    User user = mapResultSetToUser(rs);
                    if (PasswordUtil.isLegacySha256Hash(storedHash)) {
                        String bcryptHash = PasswordUtil.hashPassword(password);
                        updatePasswordHash(conn, user.getUserId(), bcryptHash);
                        user.setPasswordHash(bcryptHash);
                    }
                    return user;
                }
            }
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Get user by ID
     */
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Get user by email
     */
    public User getUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapResultSetToUser(rs);
            return null;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Check if email already exists
     */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
            return false;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Update user profile
     */
    public boolean updateProfile(User user) throws SQLException {
        String sql = "UPDATE users SET name=?, phone=?, ic_number=?, date_of_birth=?, gender=?, address=?, updated_at=NOW() WHERE user_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getIcNumber());
            ps.setDate(4, user.getDateOfBirth());
            ps.setString(5, user.getGender());
            ps.setString(6, user.getAddress());
            ps.setInt(7, user.getUserId());
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Update password
     */
    public boolean updatePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash=?, updated_at=NOW() WHERE user_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    /**
     * Get all users (admin)
     */
    public List<User> getAllUsers() throws SQLException {
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        Connection conn = null;
        List<User> users = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) users.add(mapResultSetToUser(rs));
            return users;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setPhone(rs.getString("phone"));
        user.setIcNumber(rs.getString("ic_number"));
        user.setDateOfBirth(rs.getDate("date_of_birth"));
        user.setGender(rs.getString("gender"));
        user.setAddress(rs.getString("address"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    private void updatePasswordHash(Connection conn, int userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash=?, updated_at=NOW() WHERE user_id=?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, passwordHash);
        ps.setInt(2, userId);
        ps.executeUpdate();
    }
}
