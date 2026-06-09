package com.mediqueue.controller;

import com.mediqueue.dao.UserDAO;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

/**
 * RegisterServlet - Handles new patient registration
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String phone = req.getParameter("phone");
        String icNumber = req.getParameter("icNumber");
        String gender = req.getParameter("gender");
        String dobStr = req.getParameter("dateOfBirth");
        String address = req.getParameter("address");

        // Validation
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Name, email, and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.emailExists(email.trim())) {
                req.setAttribute("error", "An account with this email already exists.");
                req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
                return;
            }

            User user = new User();
            user.setName(name.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPasswordHash(password); // Will be hashed in DAO
            user.setRole("patient");
            user.setPhone(phone);
            user.setIcNumber(icNumber);
            user.setGender(gender);
            user.setAddress(address);
            if (dobStr != null && !dobStr.isEmpty()) {
                user.setDateOfBirth(Date.valueOf(dobStr));
            }

            boolean success = userDAO.registerUser(user);
            if (success) {
                req.setAttribute("success", "Account created successfully! Please log in.");
                req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
            } else {
                req.setAttribute("error", "Registration failed. Please try again.");
                req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            log("System error", e);
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/views/common/register.jsp").forward(req, resp);
        }
    }
}
