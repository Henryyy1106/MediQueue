package com.mediqueue.controller;

import com.mediqueue.dao.UserDAO;
import com.mediqueue.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * AdminUsersServlet - Full admin CRUD user management with guardrails.
 */
@WebServlet("/admin/users/*")
public class AdminUsersServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("user");
        String keyword = trimToNull(req.getParameter("search"));
        String role = trimToNull(req.getParameter("role"));
        String pathInfo = req.getPathInfo();

        try {
            List<User> users = userDAO.searchUsers(keyword, role);
            req.setAttribute("users", users);
            req.setAttribute("search", keyword);
            req.setAttribute("role", role);
            req.setAttribute("adminCount", userDAO.countAdmins());
            req.setAttribute("currentAdminId", currentAdmin.getUserId());

            if (pathInfo != null && pathInfo.startsWith("/edit/")) {
                int userId = Integer.parseInt(pathInfo.substring("/edit/".length()));
                req.setAttribute("editingUser", userDAO.getUserById(userId));
            }

            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        } catch (Exception e) {
            log("User management error", e);
            req.setAttribute("error", "Unable to load users right now.");
            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentAdmin = (User) session.getAttribute("user");
        String action = req.getParameter("action");
        String contextPath = req.getContextPath();

        try {
            if ("create".equals(action)) {
                handleCreate(req);
                resp.sendRedirect(contextPath + "/admin/users?created=1");
                return;
            }
            if ("update".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                handleUpdate(req, currentAdmin, userId);
                if (userId == currentAdmin.getUserId()) {
                    User refreshed = userDAO.getUserById(userId);
                    session.setAttribute("user", refreshed);
                    session.setAttribute("userName", refreshed.getName());
                    session.setAttribute("userRole", refreshed.getRole());
                }
                resp.sendRedirect(contextPath + "/admin/users?updated=1");
                return;
            }
            if ("delete".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                handleDelete(currentAdmin, userId);
                resp.sendRedirect(contextPath + "/admin/users?deleted=1");
                return;
            }
            if ("resetPassword".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                handleResetPassword(req, userId);
                resp.sendRedirect(contextPath + "/admin/users?passwordReset=1");
                return;
            }
            resp.sendRedirect(contextPath + "/admin/users?error=unknown_action");
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(contextPath + "/admin/users?error=" + encodeError(e.getMessage()));
        } catch (Exception e) {
            log("User management update error", e);
            resp.sendRedirect(contextPath + "/admin/users?error=system");
        }
    }

    private void handleCreate(HttpServletRequest req) throws Exception {
        String name = required(req.getParameter("name"), "Name is required.");
        String email = required(req.getParameter("email"), "Email is required.").toLowerCase();
        String password = required(req.getParameter("password"), "Password is required.");
        String role = sanitizeRole(required(req.getParameter("role"), "Role is required."));

        if (password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters.");
        }
        if (userDAO.emailExists(email)) {
            throw new IllegalArgumentException("That email is already in use.");
        }

        User user = buildUserFromRequest(req);
        user.setName(name);
        user.setEmail(email);
        user.setPasswordHash(password);
        user.setRole(role);
        userDAO.createUser(user);
    }

    private void handleUpdate(HttpServletRequest req, User currentAdmin, int userId) throws Exception {
        User existing = userDAO.getUserById(userId);
        if (existing == null) {
            throw new IllegalArgumentException("User not found.");
        }

        String name = required(req.getParameter("name"), "Name is required.");
        String email = required(req.getParameter("email"), "Email is required.").toLowerCase();
        String role = sanitizeRole(required(req.getParameter("role"), "Role is required."));

        if (userDAO.emailExistsForOtherUser(email, userId)) {
            throw new IllegalArgumentException("That email is already in use.");
        }
        if (existing.isAdmin() && !"admin".equals(role) && userDAO.countAdmins() <= 1) {
            throw new IllegalArgumentException("You cannot demote the last remaining admin.");
        }
        if (existing.getUserId() == currentAdmin.getUserId() && !"admin".equals(role)) {
            throw new IllegalArgumentException("You cannot remove your own admin access.");
        }

        User updated = buildUserFromRequest(req);
        updated.setUserId(userId);
        updated.setName(name);
        updated.setEmail(email);
        updated.setRole(role);
        userDAO.updateUserByAdmin(updated);
    }

    private void handleDelete(User currentAdmin, int userId) throws Exception {
        User existing = userDAO.getUserById(userId);
        if (existing == null) {
            throw new IllegalArgumentException("User not found.");
        }
        if (existing.getUserId() == currentAdmin.getUserId()) {
            throw new IllegalArgumentException("You cannot delete your own admin account.");
        }
        if (existing.isAdmin() && userDAO.countAdmins() <= 1) {
            throw new IllegalArgumentException("You cannot delete the last remaining admin.");
        }
        userDAO.deleteUserById(userId);
    }

    private void handleResetPassword(HttpServletRequest req, int userId) throws Exception {
        User existing = userDAO.getUserById(userId);
        if (existing == null) {
            throw new IllegalArgumentException("User not found.");
        }
        String password = required(req.getParameter("newPassword"), "New password is required.");
        if (password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters.");
        }
        userDAO.resetPasswordByAdmin(userId, password);
    }

    private User buildUserFromRequest(HttpServletRequest req) {
        User user = new User();
        user.setPhone(trimToNull(req.getParameter("phone")));
        user.setIcNumber(trimToNull(req.getParameter("icNumber")));
        user.setGender(trimToNull(req.getParameter("gender")));
        user.setAddress(trimToNull(req.getParameter("address")));
        String dob = trimToNull(req.getParameter("dateOfBirth"));
        if (dob != null) {
            user.setDateOfBirth(Date.valueOf(dob));
        }
        return user;
    }

    private String required(String value, String message) {
        String trimmed = trimToNull(value);
        if (trimmed == null) {
            throw new IllegalArgumentException(message);
        }
        return trimmed;
    }

    private String sanitizeRole(String role) {
        if (!"patient".equals(role) && !"admin".equals(role)) {
            throw new IllegalArgumentException("Invalid role.");
        }
        return role;
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String encodeError(String message) {
        return message.replace(" ", "_");
    }
}
