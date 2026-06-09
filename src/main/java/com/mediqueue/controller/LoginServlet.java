package com.mediqueue.controller;

import com.mediqueue.dao.UserDAO;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet - Handles user authentication
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Redirect already-logged-in users
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            resp.sendRedirect(user.isAdmin() ? req.getContextPath() + "/admin/dashboard" : req.getContextPath() + "/patient/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.authenticateUser(email.trim(), password);
            if (user != null) {
                // Prevent session fixation: discard any pre-login session (and its
                // CSRF token) and start a fresh one with a new session id.
                HttpSession oldSession = req.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                HttpSession session = req.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("userName", user.getName());
                session.setAttribute("userRole", user.getRole());
                session.setMaxInactiveInterval(30 * 60); // 30 min

                // Redirect based on role
                if (user.isAdmin()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/patient/dashboard");
                }
            } else {
                req.setAttribute("error", "Invalid email or password. Please try again.");
                req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            log("Login failed due to an unexpected system error for email: " + email, e);
            req.setAttribute("error", "System error. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
        }
    }
}
