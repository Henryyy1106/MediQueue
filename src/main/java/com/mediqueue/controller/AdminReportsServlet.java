package com.mediqueue.controller;

import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.UserDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.Clinic;
import com.mediqueue.model.VisitHistory;
import com.mediqueue.util.DatabaseConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * AdminReportsServlet
 * Author: Ong Rong Yaw (22061584) - Module 5
 */
@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {

    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final VisitHistoryDAO visitDAO = new VisitHistoryDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Clinic> clinics = clinicDAO.getAllClinics();
            List<VisitHistory> allVisits = visitDAO.getAllVisits();

            // Summary stats
            int totalPatients = userDAO.getAllUsers().stream().filter(u -> u.isPatient()).mapToInt(u -> 1).sum();
            int totalCompleted = allVisits.size();
            int avgWaitMins = allVisits.isEmpty() ? 0 : (int) allVisits.stream().mapToInt(VisitHistory::getActualWaitMins).average().orElse(0);

            // Per-clinic stats via SQL
            List<Map<String,Object>> clinicStats = getClinicStats();

            req.setAttribute("totalPatients", totalPatients);
            req.setAttribute("totalCompleted", totalCompleted);
            req.setAttribute("avgWaitMins", avgWaitMins);
            req.setAttribute("totalClinics", clinics.size());
            req.setAttribute("clinicStats", clinicStats);
            req.setAttribute("recentVisits", allVisits.size() > 10 ? allVisits.subList(0, 10) : allVisits);

            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Reports error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
        }
    }

    private List<Map<String,Object>> getClinicStats() throws SQLException {
        String sql = "SELECT c.name, c.district, c.capacity, " +
                "COUNT(a.appt_id) AS total_appts, " +
                "COALESCE(AVG(vh.actual_wait_mins), 0) AS avg_wait " +
                "FROM clinics c " +
                "LEFT JOIN appointments a ON c.clinic_id = a.clinic_id " +
                "LEFT JOIN visit_history vh ON c.clinic_id = vh.clinic_id " +
                "WHERE c.is_active = TRUE GROUP BY c.clinic_id ORDER BY c.name";
        Connection conn = null;
        List<Map<String,Object>> result = new ArrayList<>();
        try {
            conn = DatabaseConnection.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("name", rs.getString("name"));
                row.put("district", rs.getString("district"));
                row.put("capacity", rs.getInt("capacity"));
                row.put("totalAppts", rs.getInt("total_appts"));
                row.put("avgWait", (int) rs.getDouble("avg_wait"));
                result.add(row);
            }
        } finally {
            DatabaseConnection.closeConnection(conn);
        }
        return result;
    }
}
