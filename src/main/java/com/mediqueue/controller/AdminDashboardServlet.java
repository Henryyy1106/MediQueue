package com.mediqueue.controller;

import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.UserDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * AdminDashboardServlet
 * Author: Ong Rong Yaw (22061584) - Module 5: Queue Dashboard & Reporting
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final QueueDAO queueDAO = new QueueDAO();
    private final AppointmentDAO apptDAO = new AppointmentDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ClinicDAO clinicDAO = new ClinicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Queue> todayQueue = queueDAO.getAllTodayQueue();
            List<Appointment> allAppts = apptDAO.getAllAppointments();
            List<Clinic> clinics = clinicDAO.getAllClinics();

            long waitingCount = todayQueue.stream().filter(q -> "waiting".equals(q.getStatus())).count();
            long inProgressCount = todayQueue.stream().filter(q -> "in_progress".equals(q.getStatus())).count();
            long doneCount = todayQueue.stream().filter(q -> "done".equals(q.getStatus())).count();

            req.setAttribute("todayQueue", todayQueue);
            req.setAttribute("clinics", clinics);
            req.setAttribute("waitingCount", waitingCount);
            req.setAttribute("inProgressCount", inProgressCount);
            req.setAttribute("doneCount", doneCount);
            req.setAttribute("totalToday", todayQueue.size());

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Dashboard error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        }
    }
}
