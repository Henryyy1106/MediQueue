package com.mediqueue.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Ensures lightweight runtime schema compatibility for local/dev databases.
 */
public final class SchemaBootstrap {

    private SchemaBootstrap() {}

    public static void ensureRuntimeSchema() {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("ALTER TABLE appointments ADD COLUMN IF NOT EXISTS admin_notes TEXT NULL");
                st.executeUpdate("CREATE TABLE IF NOT EXISTS app_settings (" +
                        "setting_key VARCHAR(100) PRIMARY KEY," +
                        "setting_value TEXT NOT NULL," +
                        "setting_label VARCHAR(150) NOT NULL," +
                        "setting_description TEXT," +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)");
                st.executeUpdate("INSERT INTO app_settings (setting_key, setting_value, setting_label, setting_description) VALUES " +
                        "('appointment.max_per_slot', '5', 'Appointment Slot Limit', 'Maximum number of bookings allowed for a single clinic time slot.')," +
                        "('queue.default_minutes_per_patient', '10', 'Queue Minutes Per Patient', 'Default number of minutes used to estimate queue waiting time per patient.')," +
                        "('session.timeout_minutes_display', '30', 'Session Timeout Display', 'Admin-facing display value for the configured session timeout in minutes.')," +
                        "('ai.fallback_disclaimer', 'This is for guidance only. Consult a qualified doctor for medical advice.', 'AI Fallback Disclaimer', 'Shown in AI fallback responses when health-related advice is provided.')," +
                        "('ai.help_message', 'AI features are temporarily unavailable. Please contact clinic staff for assistance.', 'AI Help Message', 'Fallback message used when the assistant cannot provide a live response.')" +
                        " ON DUPLICATE KEY UPDATE setting_label = VALUES(setting_label), setting_description = VALUES(setting_description)");
            }
        } catch (SQLException e) {
            System.err.println("Runtime schema bootstrap warning: " + e.getMessage());
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
    }
}
