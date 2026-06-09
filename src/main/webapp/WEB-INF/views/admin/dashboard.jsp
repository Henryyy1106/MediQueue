<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
    <meta http-equiv="refresh" content="60">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-chart-histogram"></i> Admin Dashboard</h1>
        <p>Today's clinic overview · Auto-refreshes every 60 seconds</p>
    </div>

    <!-- Stats -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fi fi-ss-users-alt"></i></div>
            <div>
                <div class="stat-value">${totalToday}</div>
                <div class="stat-label">Total Today</div>
            </div>
        </div>
        <div class="stat-card warning">
            <div class="stat-icon"><i class="fi fi-ss-hourglass-end"></i></div>
            <div>
                <div class="stat-value">${waitingCount}</div>
                <div class="stat-label">Waiting</div>
            </div>
        </div>
        <div class="stat-card info">
            <div class="stat-icon"><i class="fi fi-ss-circle" style="color:#28a745"></i></div>
            <div>
                <div class="stat-value">${inProgressCount}</div>
                <div class="stat-label">In Progress</div>
            </div>
        </div>
        <div class="stat-card success">
            <div class="stat-icon"><i class="fi fi-ss-check-circle"></i></div>
            <div>
                <div class="stat-value">${doneCount}</div>
                <div class="stat-label">Completed</div>
            </div>
        </div>
    </div>

    <!-- Clinic Summary -->
    <div class="card mb-3">
        <div class="card-header">
            <h5><i class="fi fi-ss-hospital"></i> Clinic Queue Summary</h5>
            <a href="${pageContext.request.contextPath}/admin/queue" class="btn btn-primary btn-sm">Manage Queue</a>
        </div>
        <div class="card-body">
            <div class="table-container">
                <table class="mediqueue-table">
                    <thead>
                        <tr><th>Clinic</th><th>District</th><th>Waiting</th><th>Est. Wait</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="clinic" items="${clinics}">
                            <tr>
                                <td><strong>${fn:escapeXml(clinic.name)}</strong></td>
                                <td>${fn:escapeXml(clinic.district)}</td>
                                <td><span class="badge ${clinic.currentQueueCount > 20 ? 'badge-danger' : clinic.currentQueueCount > 10 ? 'badge-warning' : 'badge-success'}">${clinic.currentQueueCount}</span></td>
                                <td>${clinic.estimatedWaitMins} min</td>
                                <td><a href="${pageContext.request.contextPath}/admin/queue?clinicId=${clinic.clinicId}&date=${pageContext.request.contextPath}" class="btn btn-outline btn-sm">View Queue</a></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Today's Queue -->
    <div class="card">
        <div class="card-header">
            <h5><i class="fi fi-ss-list"></i> Today's Queue</h5>
        </div>
        <c:choose>
            <c:when test="${empty todayQueue}">
                <div class="card-body text-center" style="padding: 2rem;">
                    <p class="text-muted">No patients in queue today.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container">
                    <table class="mediqueue-table">
                        <thead>
                            <tr><th>#</th><th>Patient</th><th>Clinic</th><th>Time</th><th>Urgency</th><th>Status</th><th>Action</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="q" items="${todayQueue}">
                                <tr>
                                    <td><strong>${q.position}</strong></td>
                                    <td>${fn:escapeXml(q.patientName)}</td>
                                    <td>${fn:escapeXml(q.clinicName)}</td>
                                    <td>${q.timeSlot}</td>
                                    <td><span class="badge badge-${q.urgencyLevel == 'emergency' ? 'danger' : q.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${q.urgencyLevel}</span></td>
                                    <td><span class="badge ${q.statusBadgeClass}">${q.status}</span></td>
                                    <td>
                                        <c:if test="${q.status == 'waiting'}">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/queue" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="queueId" value="${q.queueId}">
                                                <input type="hidden" name="apptId" value="${q.apptId}">
                                                <input type="hidden" name="status" value="in_progress">
                                                <button type="submit" class="btn btn-primary btn-sm">Call</button>
                                            </form>
                                        </c:if>
                                        <c:if test="${q.status == 'in_progress'}">
                                            <form method="post" action="${pageContext.request.contextPath}/admin/queue" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="queueId" value="${q.queueId}">
                                                <input type="hidden" name="apptId" value="${q.apptId}">
                                                <input type="hidden" name="status" value="done">
                                                <button type="submit" class="btn btn-success btn-sm">Done</button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
