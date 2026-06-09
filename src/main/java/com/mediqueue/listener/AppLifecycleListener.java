package com.mediqueue.listener;

import com.mediqueue.util.DatabaseConnection;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * AppLifecycleListener - closes the DB connection pool when the web app stops,
 * so connections are not leaked across Tomcat redeploys.
 * MediQueue | SWE3024 Code Camp
 */
@WebListener
public class AppLifecycleListener implements ServletContextListener {

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DatabaseConnection.shutdown();
    }
}
