package com.mediqueue.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * CsrfFilter - per-session CSRF protection for state-changing requests.
 * MediQueue | SWE3024 Code Camp
 *
 * Ensures every session has a CSRF token (exposed as the session attribute
 * "csrfToken" so forms can embed it in a hidden field) and rejects unsafe
 * requests (POST/PUT/DELETE/PATCH) whose submitted token does not match.
 *
 * Safe (GET/HEAD) requests pass through and simply guarantee a token exists.
 * Login/register live outside /patient and /admin and are intentionally not
 * covered (no authenticated session to protect yet); /ai/* is read-only.
 */
@WebFilter(urlPatterns = {"/patient/*", "/admin/*"})
public class CsrfFilter implements Filter {

    private static final String TOKEN_ATTR = "csrfToken";
    private static final String TOKEN_PARAM = "csrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(true);
        String token = (String) session.getAttribute(TOKEN_ATTR);
        if (token == null) {
            token = generateToken();
            session.setAttribute(TOKEN_ATTR, token);
        }

        if (isUnsafeMethod(req.getMethod())) {
            String submitted = req.getParameter(TOKEN_PARAM);
            if (submitted == null || !constantTimeEquals(submitted, token)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isUnsafeMethod(String method) {
        return "POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method) || "PATCH".equalsIgnoreCase(method);
    }

    private String generateToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    // Length-constant comparison to avoid timing leaks.
    private boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
