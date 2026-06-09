package com.mediqueue.controller;

import com.mediqueue.dao.AppointmentDAO;
import com.mediqueue.dao.ClinicDAO;
import com.mediqueue.dao.QueueDAO;
import com.mediqueue.dao.VisitHistoryDAO;
import com.mediqueue.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String clinicIdStr = req.getParameter("clinicId");
        String dateStr = req.getParameter("date");

        try {
            List<Clinic> clinics = clinicDAO.getAllClinics();
            req.setAttribute("clinics", clinics);

            if (clinicIdStr != null && dateStr != null) {
                int clinicId = Integer.parseInt(clinicIdStr);
                Date date = Date.valueOf(dateStr);
                List<Queue> queues = queueDAO.getQueueByClinicAndDate(clinicId, date);
                req.setAttribute("queues", queues);
                req.setAttribute("selectedClinicId", clinicId);
                req.setAttribute("selectedDate", dateStr);
            } else {
                List<Queue> todayQueue = queueDAO.getAllTodayQueue();
                req.setAttribute("queues", todayQueue);
                req.setAttribute("selectedDate", new Date(System.currentTimeMillis()).toString());
            }

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
                        VisitHistory visit = new VisitHistory();
                        visit.setUserId(q.getUserId());
                        visit.setClinicId(q.getClinicId());
                        visit.setApptId(q.getApptId());
                        visit.setVisitDate(new Date(System.currentTimeMillis()));
                        visit.setActualWaitMins(q.getEstimatedWaitMins());
                        visit.setOutcome(req.getParameter("outcome"));
                        visitDAO.addVisit(visit);
                    }
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/queue");
        } catch (Exception e) {
            log("Queue update error", e);
            resp.sendRedirect(req.getContextPath() + "/admin/queue?error=1");
        }
    }
}
