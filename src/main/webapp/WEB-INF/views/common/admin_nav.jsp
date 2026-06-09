<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- Flaticon UIcons (solid straight) for icons -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
<nav class="navbar-mediqueue" style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="navbar-brand">
        <div class="brand-icon"><i class="fi fi-ss-hospital"></i></div>
        <div>
            <span class="brand-name">MediQueue</span>
            <span class="brand-tagline">Admin Panel</span>
        </div>
    </a>

    <button class="navbar-toggle" type="button" aria-label="Toggle navigation menu"
            onclick="this.closest('.navbar-mediqueue').querySelector('.navbar-nav').classList.toggle('open')">
        <i class="fi fi-ss-menu-burger"></i>
    </button>

    <ul class="navbar-nav">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link"><i class="fi fi-ss-chart-histogram"></i> Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/queue" class="nav-link"><i class="fi fi-ss-list"></i> Queue Panel</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/reports" class="nav-link"><i class="fi fi-ss-chart-line-up"></i> Reports</a></li>
    </ul>

    <div class="navbar-user">
        <div class="user-avatar" style="background: rgba(255,165,0,0.3);">A</div>
        <div>
            <div style="font-size:0.85rem; font-weight:600;">${fn:escapeXml(sessionScope.userName)}</div>
            <div style="font-size:0.7rem; opacity:0.7; color:#ffc107;">Admin</div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fi fi-ss-sign-out-alt"></i> Logout</a>
    </div>
</nav>
