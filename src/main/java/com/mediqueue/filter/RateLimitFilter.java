package com.mediqueue.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

/**
 * RateLimitFilter - lightweight in-memory rate limiting.
 * MediQueue | SWE3024 Code Camp
 *
 * Two protections:
 *  - Login (POST /login): caps attempts per client IP to slow password brute-forcing.
 *  - AI (POST /ai/*): caps requests per user to limit Claude API cost/abuse.
 *
 * Uses a fixed-window counter held in memory (fine for a single instance; a
 * clustered deployment would use a shared store such as Redis). Limits are
 * intentionally generous so normal use never hits them.
 */
@WebFilter(urlPatterns = {"/login", "/ai/*"})
public class RateLimitFilter implements Filter {

    private static final int  LOGIN_LIMIT      = 10;
    private static final long LOGIN_WINDOW_MS   = 5 * 60 * 1000L;   // 10 attempts / 5 min / IP
    private static final int  AI_LIMIT          = 20;
    private static final long AI_WINDOW_MS       = 60 * 1000L;       // 20 requests / min / user

    private final ConcurrentHashMap<String, Counter> buckets = new ConcurrentHashMap<>();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Only meter state-changing POSTs; let page views (GET) through.
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String path = req.getRequestURI().substring(req.getContextPath().length());

        if (path.equals("/login")) {
            if (!allow("login:" + clientIp(req), LOGIN_LIMIT, LOGIN_WINDOW_MS)) {
                resp.setStatus(429);
                req.setAttribute("error", "Too many login attempts. Please wait a few minutes and try again.");
                req.getRequestDispatcher("/WEB-INF/views/common/login.jsp").forward(req, resp);
                return;
            }
        } else if (path.startsWith("/ai/")) {
            if (!allow("ai:" + userKey(req), AI_LIMIT, AI_WINDOW_MS)) {
                resp.setStatus(429);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().print("{\"error\": \"You're sending requests too quickly. Please wait a moment and try again.\"}");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    /** Fixed-window allow check: true if this hit is within the limit. */
    private boolean allow(String key, int limit, long windowMs) {
        Counter c = buckets.computeIfAbsent(key, k -> new Counter());
        synchronized (c) {
            long now = System.currentTimeMillis();
            if (now - c.windowStart > windowMs) {
                c.windowStart = now;
                c.count = 0;
            }
            c.count++;
            return c.count <= limit;
        }
    }

    private String userKey(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return "u" + session.getAttribute("userId");
        }
        return "ip" + clientIp(req);
    }

    private String clientIp(HttpServletRequest req) {
        String xff = req.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            return xff.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }

    private static final class Counter {
        long windowStart;
        int count;
    }
}
