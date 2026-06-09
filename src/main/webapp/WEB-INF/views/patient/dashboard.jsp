<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1>Welcome back, ${fn:escapeXml(sessionScope.userName)}</h1>
        <p>Manage your clinic appointments and queue status</p>
    </div>

    <!-- Stats -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fi fi-ss-calendar"></i></div>
            <div>
                <div class="stat-value">${upcomingAppointments.size()}</div>
                <div class="stat-label">Upcoming Appointments</div>
            </div>
        </div>
        <div class="stat-card info">
            <div class="stat-icon"><i class="fi fi-ss-chart-histogram"></i></div>
            <div>
                <div class="stat-value">${totalAppointments}</div>
                <div class="stat-label">Total Appointments</div>
            </div>
        </div>
        <div class="stat-card success">
            <div class="stat-icon"><i class="fi fi-ss-list"></i></div>
            <div>
                <c:choose>
                    <c:when test="${not empty activeQueue}">
                        <div class="stat-value">#${activeQueue.position}</div>
                        <div class="stat-label">Current Queue Position</div>
                    </c:when>
                    <c:otherwise>
                        <div class="stat-value">—</div>
                        <div class="stat-label">No Active Queue</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="stat-card warning">
            <div class="stat-icon"><i class="fi fi-ss-stopwatch"></i></div>
            <div>
                <c:choose>
                    <c:when test="${not empty activeQueue}">
                        <div class="stat-value">${activeQueue.waitLabel}</div>
                        <div class="stat-label">Est. Wait Time</div>
                    </c:when>
                    <c:otherwise>
                        <div class="stat-value">—</div>
                        <div class="stat-label">Est. Wait Time</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Active Queue Banner -->
    <c:if test="${not empty activeQueue}">
        <div class="card mb-3" style="border-left: 4px solid var(--primary); background: #f0f7ff;">
            <div class="card-body">
                <div class="d-flex justify-between align-center">
                    <div>
                        <h4 style="margin:0; color: var(--primary);"><i class="fi fi-ss-list"></i> You are in queue at ${activeQueue.clinicName}</h4>
                        <p class="text-muted mt-1">Position #${activeQueue.position} · Est. wait: ${activeQueue.waitLabel} · Status: <span class="badge ${activeQueue.statusBadgeClass}">${activeQueue.status}</span></p>
                    </div>
                    <a href="${pageContext.request.contextPath}/patient/queue" class="btn btn-primary">View Queue</a>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Quick Actions -->
    <div class="card mb-3">
        <div class="card-header"><h5>Quick Actions</h5></div>
        <div class="card-body">
            <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/patient/clinics" class="btn btn-primary"><i class="fi fi-ss-hospital"></i> Find a Clinic</a>
                <a href="${pageContext.request.contextPath}/patient/appointments/book" class="btn btn-outline"><i class="fi fi-ss-calendar"></i> Book Appointment</a>
                <a href="${pageContext.request.contextPath}/patient/queue" class="btn btn-outline"><i class="fi fi-ss-list"></i> Check My Queue</a>
                <a href="${pageContext.request.contextPath}/patient/history" class="btn btn-outline"><i class="fi fi-ss-clipboard-list"></i> Visit History</a>
            </div>
        </div>
    </div>

    <!-- Upcoming Appointments -->
    <div class="card">
        <div class="card-header">
            <h5><i class="fi fi-ss-calendar"></i> Upcoming Appointments</h5>
            <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-outline btn-sm">View All</a>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty upcomingAppointments}">
                    <div class="text-center" style="padding: 2rem; color: #888;">
                        <div style="font-size: 2.5rem; margin-bottom: 0.5rem;"><i class="fi fi-ss-calendar"></i></div>
                        <p>No upcoming appointments</p>
                        <a href="${pageContext.request.contextPath}/patient/appointments/book" class="btn btn-primary mt-1">Book Now</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="mediqueue-table">
                            <thead>
                                <tr>
                                    <th>Clinic</th>
                                    <th>Date & Time</th>
                                    <th>Reason</th>
                                    <th>Urgency</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="appt" items="${upcomingAppointments}">
                                    <tr>
                                        <td><strong>${fn:escapeXml(appt.clinicName)}</strong></td>
                                        <td>${appt.apptDate} ${appt.timeSlot}</td>
                                        <td>${fn:escapeXml(appt.reason)}</td>
                                        <td><span class="badge ${appt.urgencyBadgeClass}">${appt.urgencyLevel}</span></td>
                                        <td><span class="badge ${appt.statusBadgeClass}">${appt.status}</span></td>
                                        <td><a href="${pageContext.request.contextPath}/patient/appointments/view/${appt.apptId}" class="btn btn-outline btn-sm">View</a></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University | SDG 3 · 10 · 11</div>
</body>
</html>
