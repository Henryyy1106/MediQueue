package com.mediqueue.dao;

import com.mediqueue.model.User;
import com.mediqueue.util.DatabaseConnection;
import com.mediqueue.util.PasswordUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO - Database operations for User entity
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 */
public class UserDAO {

    public boolean registerUser(User user) throws SQLException {
        return createUser(user);
    }

    public boolean createUser(User user) throws SQLException {
        String sql = "INSERT INTO users (name, email, password_hash, role, phone, ic_number, date_of_birth, gender, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            bindUserForInsert(ps, user);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

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

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public boolean emailExistsForOtherUser(String email, int excludedUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ? AND user_id != ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setInt(2, excludedUserId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

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

    public boolean updateUserByAdmin(User user) throws SQLException {
        String sql = "UPDATE users SET name=?, email=?, role=?, phone=?, ic_number=?, date_of_birth=?, gender=?, address=?, updated_at=NOW() WHERE user_id=?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getRole());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getIcNumber());
            ps.setDate(6, user.getDateOfBirth());
            ps.setString(7, user.getGender());
            ps.setString(8, user.getAddress());
            ps.setInt(9, user.getUserId());
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

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

    public boolean resetPasswordByAdmin(int userId, String newPassword) throws SQLException {
        return updatePassword(userId, newPassword);
    }

    public boolean deleteUserById(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public int countAdmins() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'admin'";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public List<User> getAllUsers() throws SQLException {
        return searchUsers(null, null);
    }

    public List<User> searchUsers(String keyword, String role) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (name LIKE ? OR email LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
        }
        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        sql.append(" ORDER BY created_at DESC");

        Connection conn = null;
        List<User> users = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
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

    private void bindUserForInsert(PreparedStatement ps, User user) throws SQLException {
        ps.setString(1, user.getName());
        ps.setString(2, user.getEmail());
        ps.setString(3, PasswordUtil.hashPassword(user.getPasswordHash()));
        ps.setString(4, user.getRole() != null ? user.getRole() : "patient");
        ps.setString(5, user.getPhone());
        ps.setString(6, user.getIcNumber());
        ps.setDate(7, user.getDateOfBirth());
        ps.setString(8, user.getGender());
        ps.setString(9, user.getAddress());
    }
}
