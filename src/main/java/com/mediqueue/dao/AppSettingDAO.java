package com.mediqueue.dao;

import com.mediqueue.model.AppSetting;
import com.mediqueue.util.DatabaseConnection;
import com.mediqueue.util.SchemaBootstrap;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * AppSettingDAO - persisted business settings editable by admins.
 */
public class AppSettingDAO {

    public List<AppSetting> getAllSettings() throws SQLException {
        SchemaBootstrap.ensureRuntimeSchema();
        String sql = "SELECT * FROM app_settings ORDER BY setting_key";
        Connection conn = null;
        List<AppSetting> settings = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {
                while (rs.next()) {
                    settings.add(mapResultSet(rs));
                }
            }
            return settings;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    public Map<String, String> getSettingsMap() throws SQLException {
        Map<String, String> map = new LinkedHashMap<>();
        for (AppSetting setting : getAllSettings()) {
            map.put(setting.getKey(), setting.getValue());
        }
        return map;
    }

    public String getSettingValue(String key, String defaultValue) {
        SchemaBootstrap.ensureRuntimeSchema();
        String sql = "SELECT setting_value FROM app_settings WHERE setting_key = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, key);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String value = rs.getString("setting_value");
                        return value != null && !value.isBlank() ? value : defaultValue;
                    }
                }
            }
        } catch (SQLException e) {
            return defaultValue;
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
        return defaultValue;
    }

    public int getIntSetting(String key, int defaultValue) {
        String value = getSettingValue(key, Integer.toString(defaultValue));
        try {
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return defaultValue;
        }
    }

    public void updateSettings(Map<String, String> values) throws SQLException {
        SchemaBootstrap.ensureRuntimeSchema();
        String sql = "UPDATE app_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?";
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Map.Entry<String, String> entry : values.entrySet()) {
                    ps.setString(1, entry.getValue());
                    ps.setString(2, entry.getKey());
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }

    private AppSetting mapResultSet(ResultSet rs) throws SQLException {
        AppSetting setting = new AppSetting();
        setting.setKey(rs.getString("setting_key"));
        setting.setValue(rs.getString("setting_value"));
        setting.setLabel(rs.getString("setting_label"));
        setting.setDescription(rs.getString("setting_description"));
        setting.setUpdatedAt(rs.getTimestamp("updated_at"));
        return setting;
    }
}
