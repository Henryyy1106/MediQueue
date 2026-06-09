package com.mediqueue.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * DatabaseConnection - pooled DB connection utility (HikariCP)
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024)
 *
 * Backed by a HikariCP pool instead of opening a fresh DriverManager
 * connection per call. The public API is unchanged: getConnection() hands out
 * a pooled connection and closeConnection() returns it to the pool.
 */
public class DatabaseConnection {

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/mediqueue?useSSL=false&serverTimezone=Asia/Kuala_Lumpur&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USERNAME = "root";
    private static final String DEFAULT_PASSWORD = "root";

    private static volatile HikariDataSource dataSource;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        }
    }

    private static HikariDataSource getDataSource() {
        HikariDataSource ds = dataSource;
        if (ds == null) {
            synchronized (DatabaseConnection.class) {
                ds = dataSource;
                if (ds == null) {
                    HikariConfig config = new HikariConfig();
                    config.setPoolName("MediQueuePool");
                    config.setJdbcUrl(getConfigValue("mediqueue.db.url", "MEDIQUEUE_DB_URL", DEFAULT_URL));
                    config.setUsername(getConfigValue("mediqueue.db.username", "MEDIQUEUE_DB_USERNAME", DEFAULT_USERNAME));
                    config.setPassword(getConfigValue("mediqueue.db.password", "MEDIQUEUE_DB_PASSWORD", DEFAULT_PASSWORD));
                    config.setMaximumPoolSize(10);
                    config.setMinimumIdle(2);
                    config.setConnectionTimeout(10_000);
                    ds = new HikariDataSource(config);
                    dataSource = ds;
                }
            }
        }
        return ds;
    }

    public static Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close(); // returns the connection to the pool
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    /** Close the pool. Invoked on web app shutdown to avoid leaks across redeploys. */
    public static synchronized void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
        dataSource = null;
    }

    private static String getConfigValue(String propertyName, String envName, String defaultValue) {
        String propertyValue = System.getProperty(propertyName);
        if (propertyValue != null && !propertyValue.isEmpty()) {
            return propertyValue;
        }

        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isEmpty()) {
            return envValue;
        }

        return defaultValue;
    }
}
