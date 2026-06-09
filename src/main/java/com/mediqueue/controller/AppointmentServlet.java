package com.mediqueue.controller;

import com.mediqueue.ai.AIHelper;
import com.mediqueue.ai.AIResponse;
import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.model.Appointment;
import com.mediqueue.model.Clinic;
import com.mediqueue.model.Queue;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * AppointmentServlet - Handles appointment booking, viewing, cancellation
 * MediQueue | SWE3024 Code Camp
 * Author: Si Thu Lin Khant (22042642) - Module 2: Appointment Booking
 */
@WebServlet("/patient/appointments/*")
public class AppointmentServlet extends HttpServlet {

    private final AppointmentDAO apptDAO = new AppointmentDAO();
    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final QueueDAO queueDAO = new QueueDAO();
    private final AIHelper aiHelper = new AIHelper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");

        try {
            if (pathInfo == null || "/".equals(pathInfo) || "/list".equals(pathInfo)) {
                // List appointments
                List<Appointment> appointments = apptDAO.getAppointmentsByUser(user.getUserId());
                req.setAttribute("appointments", appointments);
                req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp").forward(req, resp);

            } else if ("/book".equals(pathInfo)) {
                // Show booking form
                List<Clinic> clinics = clinicDAO.getAllClinics();
                req.setAttribute("clinics", clinics);
                String preClinicId = req.getParameter("clinicId");
                if (preClinicId != null) {
                    req.setAttribute("preClinicId", preClinicId);
                }
                req.getRequestDispatcher("/WEB-INF/views/patient/book_appointment.jsp").forward(req, resp);

            } else if (pathInfo.startsWith("/view/")) {
                int apptId = Integer.parseInt(pathInfo.substring(6));
                Appointment appt = apptDAO.getAppointmentById(apptId);
                if (appt == null || appt.getUserId() != user.getUserId()) {
                    resp.sendError(403, "Access denied.");
                    return;
                }
                Queue queue = queueDAO.getQueueByApptId(apptId);
                req.setAttribute("appointment", appt);
                req.setAttribute("queue", queue);
                req.getRequestDispatcher("/WEB-INF/views/patient/appointment_detail.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            log("Error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");

        try {
            if ("/book".equals(pathInfo)) {
                handleBooking(req, resp, user);
            } else if ("/cancel".equals(pathInfo)) {
                handleCancellation(req, resp, user);
            }
        } catch (Exception e) {
            log("Booking error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/patient/book_appointment.jsp").forward(req, resp);
        }
    }

    private void handleBooking(HttpServletRequest req, HttpServletResponse resp, User user) throws Exception {
        int clinicId = Integer.parseInt(req.getParameter("clinicId"));
        String dateStr = req.getParameter("apptDate");
        String timeSlot = req.getParameter("timeSlot");
        String reason = req.getParameter("reason");
        String symptoms = req.getParameter("symptoms");

        if (dateStr == null || timeSlot == null || reason == null) {
            req.setAttribute("error", "Please fill in all required fields.");
            List<Clinic> clinics = clinicDAO.getAllClinics();
            req.setAttribute("clinics", clinics);
            req.getRequestDispatcher("/WEB-INF/views/patient/book_appointment.jsp").forward(req, resp);
            return;
        }

        Date apptDate = Date.valueOf(dateStr);

        // Check slot availability
        if (apptDAO.isTimeSlotTaken(clinicId, apptDate, timeSlot)) {
            req.setAttribute("error", "This time slot is fully booked. Please choose another time.");
            List<Clinic> clinics = clinicDAO.getAllClinics();
            req.setAttribute("clinics", clinics);
            req.getRequestDispatcher("/WEB-INF/views/patient/book_appointment.jsp").forward(req, resp);
            return;
        }

        // AI urgency classification
        AIResponse aiResp = null;
        if (symptoms != null && !symptoms.trim().isEmpty()) {
            aiResp = aiHelper.classifyUrgency(symptoms);
        }

        Appointment appt = new Appointment();
        appt.setUserId(user.getUserId());
        appt.setClinicId(clinicId);
        appt.setApptDate(apptDate);
        appt.setTimeSlot(timeSlot);
        appt.setReason(reason);
        appt.setSymptoms(symptoms);
        appt.setStatus("confirmed");

        if (aiResp != null) {
            appt.setUrgencyLevel(aiResp.getUrgencyLevel());
            appt.setAiNotes(aiResp.getAdvice());
        } else {
            appt.setUrgencyLevel("routine");
        }

        int apptId = apptDAO.createAppointment(appt);

        if (apptId > 0) {
            // Add to queue
            Queue queue = new Queue();
            queue.setClinicId(clinicId);
            queue.setApptId(apptId);
            queue.setUserId(user.getUserId());
            queue.setQueueDate(apptDate);
            queueDAO.addToQueue(queue);

            req.getSession().setAttribute("bookingSuccess", true);
            req.getSession().setAttribute("bookedApptId", apptId);
            req.getSession().setAttribute("aiResponse", aiResp);

            // Emergency redirect
            if (aiResp != null && "emergency".equals(aiResp.getUrgencyLevel())) {
                resp.sendRedirect(req.getContextPath() + "/patient/appointments/view/" + apptId + "?emergency=true");
            } else {
                resp.sendRedirect(req.getContextPath() + "/patient/appointments/view/" + apptId + "?booked=true");
            }
        } else {
            req.setAttribute("error", "Booking failed. Please try again.");
            List<Clinic> clinics = clinicDAO.getAllClinics();
            req.setAttribute("clinics", clinics);
            req.getRequestDispatcher("/WEB-INF/views/patient/book_appointment.jsp").forward(req, resp);
        }
    }

    private void handleCancellation(HttpServletRequest req, HttpServletResponse resp, User user) throws Exception {
        int apptId = Integer.parseInt(req.getParameter("apptId"));
        boolean success = apptDAO.cancelAppointment(apptId, user.getUserId());
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/patient/appointments?cancelled=true");
        } else {
            resp.sendRedirect(req.getContextPath() + "/patient/appointments?error=cancel_failed");
        }
    }
}
