package com.mediqueue.controller;

import com.mediqueue.ai.AIHelper;
import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.RatingDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.Appointment;
import com.mediqueue.model.Rating;
import com.mediqueue.model.User;
import com.mediqueue.model.VisitHistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * VisitHistoryServlet
 * Author: Ong Rong Yaw (22061584) - Module 5
 */
@WebServlet("/patient/history")
public class VisitHistoryServlet extends HttpServlet {

    private final VisitHistoryDAO visitDAO = new VisitHistoryDAO();
    private final RatingDAO ratingDAO = new RatingDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final AIHelper aiHelper = new AIHelper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        try {
            List<VisitHistory> visits = visitDAO.getVisitsByUser(user.getUserId());
            req.setAttribute("visits", visits);
            req.getRequestDispatcher("/WEB-INF/views/patient/visit_history.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Error loading visit history.");
            req.getRequestDispatcher("/WEB-INF/views/patient/visit_history.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        String contextPath = req.getContextPath();
        try {
            int apptId = Integer.parseInt(req.getParameter("apptId"));
            int stars = Integer.parseInt(req.getParameter("stars"));

            // Verify the appointment exists and belongs to this user; derive the
            // clinic server-side rather than trusting the submitted clinicId.
            Appointment appt = appointmentDAO.getAppointmentById(apptId);
            if (appt == null || appt.getUserId() != user.getUserId()) {
                resp.sendRedirect(contextPath + "/patient/history?error=1");
                return;
            }

            Rating rating = new Rating();
            rating.setUserId(user.getUserId());
            rating.setClinicId(appt.getClinicId());
            rating.setApptId(apptId);
            rating.setStars(stars);
            rating.setComment(req.getParameter("comment"));
            ratingDAO.addRating(rating);

            resp.sendRedirect(contextPath + "/patient/history?rated=1");
        } catch (Exception e) {
            resp.sendRedirect(contextPath + "/patient/history?error=1");
        }
    }
}
