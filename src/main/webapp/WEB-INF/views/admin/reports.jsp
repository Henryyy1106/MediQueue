<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-chart-line-up"></i> Reports & Analytics</h1>
        <p>Clinic performance and queue statistics</p>
    </div>

    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fi fi-ss-users-alt"></i></div>
            <div>
                <div class="stat-value">${totalPatients}</div>
                <div class="stat-label">Total Patients</div>
            </div>
        </div>
        <div class="stat-card success">
            <div class="stat-icon"><i class="fi fi-ss-check-circle"></i></div>
            <div>
                <div class="stat-value">${totalCompleted}</div>
                <div class="stat-label">Completed Visits</div>
            </div>
        </div>
        <div class="stat-card info">
            <div class="stat-icon"><i class="fi fi-ss-stopwatch"></i></div>
            <div>
                <div class="stat-value">${avgWaitMins} min</div>
                <div class="stat-label">Avg Wait Time</div>
            </div>
        </div>
        <div class="stat-card warning">
            <div class="stat-icon"><i class="fi fi-ss-hospital"></i></div>
            <div>
                <div class="stat-value">${totalClinics}</div>
                <div class="stat-label">Active Clinics</div>
            </div>
        </div>
    </div>

    <!-- Clinic Performance Table -->
    <div class="card mb-3">
        <div class="card-header"><h5>Clinic Performance Summary</h5></div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty clinicStats}">
                    <p class="text-muted text-center" style="padding:1.5rem;">No data available yet.</p>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="mediqueue-table">
                            <thead>
                                <tr>
                                    <th>Clinic</th>
                                    <th>District</th>
                                    <th>Total Appointments</th>
                                    <th>Avg Wait (min)</th>
                                    <th>Capacity</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="stat" items="${clinicStats}">
                                    <tr>
                                        <td><strong>${stat.name}</strong></td>
                                        <td>${stat.district}</td>
                                        <td>${stat.totalAppts}</td>
                                        <td>${stat.avgWait}</td>
                                        <td>${stat.capacity}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Visit History Summary -->
    <div class="card">
        <div class="card-header"><h5>Recent Completed Visits</h5></div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty recentVisits}">
                    <p class="text-muted text-center" style="padding:1.5rem;">No completed visits yet.</p>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="mediqueue-table">
                            <thead>
                                <tr><th>Date</th><th>Patient</th><th>Clinic</th><th>Wait</th><th>Outcome</th></tr>
                            </thead>
                            <tbody>
                                <c:forEach var="v" items="${recentVisits}">
                                    <tr>
                                        <td>${v.visitDate}</td>
                                        <td>${v.patientName}</td>
                                        <td>${v.clinicName}</td>
                                        <td>${v.actualWaitMins} min</td>
                                        <td>${not empty v.outcome ? v.outcome : '—'}</td>
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

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
