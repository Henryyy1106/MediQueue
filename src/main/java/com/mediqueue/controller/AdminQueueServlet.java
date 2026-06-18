package com.mediqueue.controller;

import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.ai.AIHelper;
import com.mediqueue.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.util.List;

/**
 * AdminQueueServlet - Admin queue management panel
 * Author: Ong Rong Yaw (22061584) - Module 5
 */
@WebServlet("/admin/queue")
public class AdminQueueServlet extends HttpServlet {

    private final QueueDAO queueDAO = new QueueDAO();
    private final AppointmentDAO apptDAO = new AppointmentDAO();
    private final ClinicDAO clinicDAO = new ClinicDAO();
    private final VisitHistoryDAO visitDAO = new VisitHistoryDAO();
    private final AIHelper aiHelper = new AIHelper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clinicIdStr = req.getParameter("clinicId");
        String dateStr = req.getParameter("date");

        try {
            List<Clinic> clinics = clinicDAO.getAllClinics();
            req.setAttribute("clinics", clinics);
            List<Queue> queues;
            String scopeTitle;
            String selectedDate;

            if (dateStr != null && !dateStr.isBlank()) {
                Date date = Date.valueOf(dateStr);
                selectedDate = dateStr;
                if (clinicIdStr != null && !clinicIdStr.isBlank()) {
                    int clinicId = Integer.parseInt(clinicIdStr);
                    queues = queueDAO.getQueueByClinicAndDate(clinicId, date);
                    req.setAttribute("selectedClinicId", clinicId);
                    Clinic selectedClinic = clinicDAO.getClinicById(clinicId);
                    scopeTitle = selectedClinic != null
                            ? selectedClinic.getName() + " on " + dateStr
                            : "Selected clinic on " + dateStr;
                } else {
                    queues = queueDAO.getAllQueueByDate(date);
                    scopeTitle = "All clinics on " + dateStr;
                }
            } else {
                queues = queueDAO.getAllTodayQueue();
                selectedDate = new Date(System.currentTimeMillis()).toString();
                scopeTitle = "All clinics today";
            }

            req.setAttribute("queues", queues);
            long waitingCount = queues.stream().filter(q -> "waiting".equals(q.getStatus())).count();
            long inProgressCount = queues.stream().filter(q -> "in_progress".equals(q.getStatus())).count();
            long doneCount = queues.stream().filter(q -> "done".equals(q.getStatus())).count();
            long skippedCount = queues.stream().filter(q -> "skipped".equals(q.getStatus())).count();

            req.setAttribute("selectedDate", selectedDate);
            req.setAttribute("scopeTitle", scopeTitle);
            req.setAttribute("waitingCount", waitingCount);
            req.setAttribute("inProgressCount", inProgressCount);
            req.setAttribute("doneCount", doneCount);
            req.setAttribute("skippedCount", skippedCount);

            req.getRequestDispatcher("/WEB-INF/views/admin/queue_panel.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Error loading queue", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/admin/queue_panel.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("updateStatus".equals(action)) {
                int queueId = Integer.parseInt(req.getParameter("queueId"));
                String status = req.getParameter("status");
                queueDAO.updateQueueStatus(queueId, status);

                // If done, also update appointment status and create visit history
                if ("done".equals(status)) {
                    Queue q = queueDAO.getQueueByApptId(Integer.parseInt(req.getParameter("apptId")));
                    if (q != null) {
                        apptDAO.updateStatus(q.getApptId(), "completed");
                        if (visitDAO.getVisitByApptId(q.getApptId()) == null) {
                            Appointment appt = apptDAO.getAppointmentById(q.getApptId());
                            String outcome = req.getParameter("outcome");
                            if (outcome == null || outcome.isBlank()) {
                                outcome = "Completed from queue panel.";
                            }
                            VisitHistory visit = new VisitHistory();
                            visit.setUserId(q.getUserId());
                            visit.setClinicId(q.getClinicId());
                            visit.setApptId(q.getApptId());
                            visit.setVisitDate(new Date(System.currentTimeMillis()));
                            visit.setActualWaitMins(q.getEstimatedWaitMins());
                            visit.setOutcome(outcome);
                            if (appt != null) {
                                visit.setAiSummary(aiHelper.generateVisitSummary(appt.getClinicName(), appt.getReason(), appt.getSymptoms(), outcome));
                            }
                            visitDAO.addVisit(visit);
                        }
                    }
                }
            }
            resp.sendRedirect(req.getContextPath() + buildQueueRedirectSuffix(req));
        } catch (Exception e) {
            log("Queue update error", e);
            resp.sendRedirect(req.getContextPath() + buildQueueRedirectSuffix(req) + (hasQueryParams(req) ? "&" : "?") + "error=1");
        }
    }

    private String buildQueueRedirectSuffix(HttpServletRequest req) throws IOException {
        StringBuilder redirect = new StringBuilder("/admin/queue");
        boolean hasParams = false;

        String clinicId = req.getParameter("clinicId");
        if (clinicId != null && !clinicId.isBlank()) {
            redirect.append(hasParams ? '&' : '?')
                    .append("clinicId=")
                    .append(URLEncoder.encode(clinicId, "UTF-8"));
            hasParams = true;
        }

        String date = req.getParameter("date");
        if (date != null && !date.isBlank()) {
            redirect.append(hasParams ? '&' : '?')
                    .append("date=")
                    .append(URLEncoder.encode(date, "UTF-8"));
        }

        return redirect.toString();
    }

    private boolean hasQueryParams(HttpServletRequest req) {
        String clinicId = req.getParameter("clinicId");
        String date = req.getParameter("date");
        return (clinicId != null && !clinicId.isBlank()) || (date != null && !date.isBlank());
    }
}
