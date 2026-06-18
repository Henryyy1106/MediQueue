package com.mediqueue.controller;

import com.mediqueue.ai.AIHelper;
import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.Appointment;
import com.mediqueue.model.Clinic;
import com.mediqueue.model.Queue;
import com.mediqueue.model.VisitHistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * AdminAppointmentsServlet - appointment moderation and reassignment.
 */
@WebServlet("/admin/appointments/*")
public class AdminAppointmentsServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final QueueDAO queueDAO = new QueueDAO();
    private final VisitHistoryDAO visitHistoryDAO = new VisitHistoryDAO();
    private final AIHelper aiHelper = new AIHelper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String status = trimToNull(req.getParameter("status"));
        String urgency = trimToNull(req.getParameter("urgency"));
        String patientSearch = trimToNull(req.getParameter("patient"));
        Integer clinicId = parseIntOrNull(req.getParameter("clinicId"));
        Date apptDate = parseDateOrNull(req.getParameter("apptDate"));

        try {
            List<Clinic> clinics = clinicDAO.getAllClinics();
            List<Appointment> appointments = appointmentDAO.searchAppointmentsForAdmin(status, clinicId, urgency, apptDate, patientSearch);
            req.setAttribute("clinics", clinics);
            req.setAttribute("appointments", appointments);
            req.setAttribute("filterStatus", status);
            req.setAttribute("filterUrgency", urgency);
            req.setAttribute("filterClinicId", clinicId);
            req.setAttribute("filterApptDate", req.getParameter("apptDate"));
            req.setAttribute("filterPatient", patientSearch);

            Integer selectedId = null;
            if (pathInfo != null && pathInfo.startsWith("/view/")) {
                selectedId = Integer.parseInt(pathInfo.substring("/view/".length()));
            } else if (req.getParameter("apptId") != null && !req.getParameter("apptId").isBlank()) {
                selectedId = Integer.parseInt(req.getParameter("apptId"));
            }
            if (selectedId != null) {
                req.setAttribute("selectedAppointment", appointmentDAO.getAppointmentById(selectedId));
            }

            req.getRequestDispatcher("/WEB-INF/views/admin/appointments.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Appointment moderation error", e);
            req.setAttribute("error", "Unable to load appointments right now.");
            req.getRequestDispatcher("/WEB-INF/views/admin/appointments.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String contextPath = req.getContextPath();
        try {
            int apptId = Integer.parseInt(req.getParameter("apptId"));
            Appointment existing = appointmentDAO.getAppointmentById(apptId);
            if (existing == null) {
                throw new IllegalArgumentException("Appointment not found.");
            }

            Appointment updated = buildUpdatedAppointment(req, existing);
            boolean slotChanged = existing.getClinicId() != updated.getClinicId()
                    || !existing.getApptDate().equals(updated.getApptDate())
                    || !existing.getTimeSlot().equals(updated.getTimeSlot());

            if (!"cancelled".equals(updated.getStatus())
                    && appointmentDAO.isTimeSlotTaken(updated.getClinicId(), updated.getApptDate(), updated.getTimeSlot(), updated.getApptId())) {
                throw new IllegalArgumentException("That clinic time slot is already full.");
            }

            appointmentDAO.updateAppointmentForAdmin(updated);
            syncQueueAndVisitHistory(existing, updated, slotChanged);

            resp.sendRedirect(contextPath + "/admin/appointments/view/" + apptId + "?updated=1");
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(contextPath + "/admin/appointments?error=" + e.getMessage().replace(" ", "_"));
        } catch (Exception e) {
            log("Appointment moderation update error", e);
            resp.sendRedirect(contextPath + "/admin/appointments?error=system");
        }
    }

    private Appointment buildUpdatedAppointment(HttpServletRequest req, Appointment existing) {
        Appointment updated = new Appointment();
        updated.setApptId(existing.getApptId());
        updated.setUserId(existing.getUserId());
        updated.setClinicId(Integer.parseInt(req.getParameter("clinicId")));
        updated.setApptDate(Date.valueOf(req.getParameter("apptDate")));
        updated.setTimeSlot(required(req.getParameter("timeSlot"), "Time slot is required."));
        updated.setReason(required(req.getParameter("reason"), "Reason is required."));
        updated.setSymptoms(trimToNull(req.getParameter("symptoms")));
        updated.setStatus(validateStatus(required(req.getParameter("status"), "Status is required.")));
        updated.setUrgencyLevel(validateUrgency(required(req.getParameter("urgencyLevel"), "Urgency level is required.")));
        updated.setAiNotes(existing.getAiNotes());
        updated.setAdminNotes(trimToNull(req.getParameter("adminNotes")));
        return updated;
    }

    private void syncQueueAndVisitHistory(Appointment existing, Appointment updated, boolean slotChanged) throws Exception {
        Queue existingQueue = queueDAO.getQueueByApptId(existing.getApptId());
        String status = updated.getStatus();

        if ("cancelled".equals(status)) {
            queueDAO.removeQueueByApptId(updated.getApptId());
            return;
        }

        if ("completed".equals(status)) {
            if (existingQueue != null) {
                queueDAO.updateQueueStatus(existingQueue.getQueueId(), "done");
            }
            ensureVisitHistory(updated, existingQueue);
            return;
        }

        boolean shouldRecreateQueue = existingQueue == null
                || slotChanged
                || "done".equals(existingQueue.getStatus())
                || "skipped".equals(existingQueue.getStatus());

        if (shouldRecreateQueue) {
            if (existingQueue != null) {
                queueDAO.removeQueueByApptId(updated.getApptId());
            }
            Queue queue = new Queue();
            queue.setClinicId(updated.getClinicId());
            queue.setApptId(updated.getApptId());
            queue.setUserId(updated.getUserId());
            queue.setQueueDate(updated.getApptDate());
            queue.setStatus("waiting");
            queueDAO.addToQueue(queue);
        }
    }

    private void ensureVisitHistory(Appointment appointment, Queue queue) throws Exception {
        if (visitHistoryDAO.getVisitByApptId(appointment.getApptId()) != null) {
            return;
        }

        String outcome = appointment.getAdminNotes() != null && !appointment.getAdminNotes().isBlank()
                ? appointment.getAdminNotes()
                : "Completed via admin moderation.";
        String clinicName = appointment.getClinicName();
        if (clinicName == null || clinicName.isBlank()) {
            Clinic clinic = clinicDAO.getClinicById(appointment.getClinicId());
            clinicName = clinic != null ? clinic.getName() : "Clinic Visit";
        }

        VisitHistory visit = new VisitHistory();
        visit.setUserId(appointment.getUserId());
        visit.setClinicId(appointment.getClinicId());
        visit.setApptId(appointment.getApptId());
        visit.setVisitDate(appointment.getApptDate());
        visit.setActualWaitMins(queue != null ? queue.getEstimatedWaitMins() : 0);
        visit.setOutcome(outcome);
        visit.setAiSummary(aiHelper.generateVisitSummary(clinicName, appointment.getReason(), appointment.getSymptoms(), outcome));
        visitHistoryDAO.addVisit(visit);
    }

    private Integer parseIntOrNull(String value) {
        try {
            return value == null || value.isBlank() ? null : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Date parseDateOrNull(String value) {
        try {
            return value == null || value.isBlank() ? null : Date.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String required(String value, String message) {
        String trimmed = trimToNull(value);
        if (trimmed == null) throw new IllegalArgumentException(message);
        return trimmed;
    }

    private String validateStatus(String status) {
        if (!"pending".equals(status) && !"confirmed".equals(status) && !"cancelled".equals(status) && !"completed".equals(status)) {
            throw new IllegalArgumentException("Invalid status.");
        }
        return status;
    }

    private String validateUrgency(String urgency) {
        if (!"routine".equals(urgency) && !"urgent".equals(urgency) && !"emergency".equals(urgency)) {
            throw new IllegalArgumentException("Invalid urgency level.");
        }
        return urgency;
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
