<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- Flaticon UIcons (solid straight) for icons -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">

<c:set var="currentPath" value="${pageContext.request.requestURI}" />

<div class="admin-mobile-bar">
    <button class="admin-sidebar-toggle" type="button" aria-label="Open admin navigation"
            onclick="document.querySelector('.admin-sidebar').classList.toggle('open'); document.querySelector('.admin-sidebar-backdrop').classList.toggle('open');">
        <i class="fi fi-ss-menu-burger"></i>
    </button>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-mobile-brand">
        <span class="admin-brand-mark"><i class="fi fi-ss-hospital"></i></span>
        <span>MediQueue</span>
    </a>
</div>

<div class="admin-sidebar-backdrop" onclick="document.querySelector('.admin-sidebar').classList.remove('open'); this.classList.remove('open');"></div>

<aside class="admin-sidebar" aria-label="Admin navigation">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="admin-sidebar-brand">
        <span class="admin-brand-mark"><i class="fi fi-ss-hospital"></i></span>
        <span>
            <strong>MediQueue</strong>
            <small>Admin Panel</small>
        </span>
    </a>

    <nav class="admin-sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard"
           class="admin-sidebar-link ${fn:contains(currentPath, '/admin/dashboard') ? 'active' : ''}">
            <i class="fi fi-ss-chart-histogram"></i>
            <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/queue"
           class="admin-sidebar-link ${fn:contains(currentPath, '/admin/queue') ? 'active' : ''}">
            <i class="fi fi-ss-list"></i>
            <span>Queue Panel</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/users"
           class="admin-sidebar-link ${fn:contains(currentPath, '/admin/users') ? 'active' : ''}">
            <i class="fi fi-ss-users-alt"></i>
            <span>Users</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/appointments"
           class="admin-sidebar-link ${fn:contains(currentPath, '/admin/appointments') ? 'active' : ''}">
            <i class="fi fi-ss-calendar"></i>
            <span>Appointments</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/reports"
           class="admin-sidebar-link ${fn:contains(currentPath, '/admin/reports') ? 'active' : ''}">
            <i class="fi fi-ss-chart-line-up"></i>
            <span>Reports</span>
        </a>
    </nav>

    <div class="admin-sidebar-footer">
        <div class="admin-sidebar-user">
            <div class="admin-sidebar-avatar">A</div>
            <div>
                <strong>${empty sessionScope.userName ? 'Admin MediQueue' : fn:escapeXml(sessionScope.userName)}</strong>
                <span>Admin</span>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="admin-sidebar-logout">
            <i class="fi fi-ss-sign-out-alt"></i>
            <span>Logout</span>
        </a>
    </div>
</aside>
