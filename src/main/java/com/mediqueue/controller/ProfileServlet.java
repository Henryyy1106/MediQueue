package com.mediqueue.controller;

import com.mediqueue.dao.UserDAO;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

/**
 * ProfileServlet - View and update user profile
 * Author: Tam Lik Herng (23093024) - Module 1
 */
@WebServlet("/patient/profile")
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User sessionUser = (User) session.getAttribute("user");
        try {
            User user = userDAO.getUserById(sessionUser.getUserId());
            req.setAttribute("user", user);
            req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("error", "Failed to load profile.");
            req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User sessionUser = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                User user = userDAO.getUserById(sessionUser.getUserId());
                user.setName(req.getParameter("name"));
                user.setPhone(req.getParameter("phone"));
                user.setIcNumber(req.getParameter("icNumber"));
                user.setGender(req.getParameter("gender"));
                user.setAddress(req.getParameter("address"));
                String dob = req.getParameter("dateOfBirth");
                if (dob != null && !dob.isEmpty()) user.setDateOfBirth(Date.valueOf(dob));

                userDAO.updateProfile(user);

                // Update session name
                session.setAttribute("userName", user.getName());
                session.setAttribute("user", user);

                req.setAttribute("success", "Profile updated successfully.");
                req.setAttribute("user", user);
            } else if ("changePassword".equals(action)) {
                String current = req.getParameter("currentPassword");
                String newPass = req.getParameter("newPassword");
                String confirm = req.getParameter("confirmPassword");

                User user = userDAO.getUserById(sessionUser.getUserId());
                if (!com.mediqueue.util.PasswordUtil.checkPassword(current, user.getPasswordHash())) {
                    req.setAttribute("error", "Current password is incorrect.");
                } else if (!newPass.equals(confirm)) {
                    req.setAttribute("error", "New passwords do not match.");
                } else if (newPass.length() < 6) {
                    req.setAttribute("error", "Password must be at least 6 characters.");
                } else {
                    userDAO.updatePassword(sessionUser.getUserId(), newPass);
                    req.setAttribute("success", "Password changed successfully.");
                }
                req.setAttribute("user", userDAO.getUserById(sessionUser.getUserId()));
            }
        } catch (Exception e) {
            log("Error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
        }
        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp").forward(req, resp);
    }
}
