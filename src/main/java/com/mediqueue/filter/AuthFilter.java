package com.mediqueue.filter;

import com.mediqueue.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter - Role-based access control filter
 * MediQueue | SWE3024 Code Camp
 * Author: Tam Lik Herng (23093024) - Module 1: User Auth & Profile
 *
 * Protects /patient/*, /admin/* and /ai/* routes.
 * Redirects unauthenticated users to /login.
 * Prevents patients from accessing admin routes.
 */
@WebFilter(urlPatterns = {"/patient/*", "/admin/*", "/ai/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String contextPath = req.getContextPath();
        String requestURI = req.getRequestURI();

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Not logged in - redirect to login
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // Role enforcement: patients cannot access admin routes
        if (requestURI.startsWith(contextPath + "/admin") && !user.isAdmin()) {
            resp.sendRedirect(contextPath + "/patient/dashboard");
            return;
        }

        // Role enforcement: admins go to admin dashboard if accessing patient routes
        if (requestURI.startsWith(contextPath + "/patient") && user.isAdmin()) {
            resp.sendRedirect(contextPath + "/admin/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }
}
