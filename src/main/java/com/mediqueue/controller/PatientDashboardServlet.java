package com.mediqueue.controller;

import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.Appointment;
import com.mediqueue.model.Queue;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * PatientDashboardServlet
 * Author: Tam Lik Herng (23093024) - Module 1
 */
@WebServlet("/patient/dashboard")
public class PatientDashboardServlet extends HttpServlet {

    private final AppointmentDAO apptDAO = new AppointmentDAO();
    private final QueueDAO queueDAO = new QueueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        try {
            List<Appointment> appointments = apptDAO.getAppointmentsByUser(user.getUserId());
            Queue activeQueue = queueDAO.getActiveQueueByUser(user.getUserId());

            // Only upcoming appointments (pending/confirmed)
            List<Appointment> upcoming = appointments.stream()
                    .filter(a -> "pending".equals(a.getStatus()) || "confirmed".equals(a.getStatus()))
                    .limit(3)
                    .collect(java.util.stream.Collectors.toList());

            req.setAttribute("upcomingAppointments", upcoming);
            req.setAttribute("activeQueue", activeQueue);
            req.setAttribute("totalAppointments", appointments.size());

            req.getRequestDispatcher("/WEB-INF/views/patient/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Dashboard error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/patient/dashboard.jsp").forward(req, resp);
        }
    }
}
