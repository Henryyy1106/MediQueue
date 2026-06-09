package com.mediqueue.controller;

import com.mediqueue.dao.QueueDAO;
import com.mediqueue.model.Queue;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * QueueServlet - Patient live queue status
 * Author: Ong Rong Yaw (22061584) - Module 5
 */
@WebServlet("/patient/queue")
public class QueueServlet extends HttpServlet {

    private final QueueDAO queueDAO = new QueueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        try {
            Queue queue = queueDAO.getActiveQueueByUser(user.getUserId());
            req.setAttribute("queue", queue);
            req.getRequestDispatcher("/WEB-INF/views/patient/queue_status.jsp").forward(req, resp);
        } catch (Exception e) {
            log("Error loading queue", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/patient/queue_status.jsp").forward(req, resp);
        }
    }
}
