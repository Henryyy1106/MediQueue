<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Appointments - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container">
    <div class="page-header d-flex justify-between align-center">
        <div>
            <h1><i class="fi fi-ss-calendar"></i> My Appointments</h1>
            <p>All your clinic bookings</p>
        </div>
        <a href="${pageContext.request.contextPath}/patient/appointments/book" class="btn btn-primary">+ New Booking</a>
    </div>

    <c:if test="${param.cancelled == 'true'}">
        <div class="alert alert-success"><i class="fi fi-ss-check"></i> Appointment cancelled successfully.</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
        <c:choose>
            <c:when test="${empty appointments}">
                <div class="card-body text-center" style="padding: 3rem;">
                    <div style="font-size: 3rem; margin-bottom: 1rem;"><i class="fi fi-ss-calendar"></i></div>
                    <h3>No appointments yet</h3>
                    <p class="text-muted">Book your first clinic appointment below.</p>
                    <a href="${pageContext.request.contextPath}/patient/appointments/book" class="btn btn-primary mt-2">Book Appointment</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container">
                    <table class="mediqueue-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Clinic</th>
                                <th>Date</th>
                                <th>Time</th>
                                <th>Reason</th>
                                <th>Urgency</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="appt" items="${appointments}" varStatus="s">
                                <tr>
                                    <td style="color: #aaa; font-size:0.8rem;">${s.index + 1}</td>
                                    <td><strong>${fn:escapeXml(appt.clinicName)}</strong></td>
                                    <td>${appt.apptDate}</td>
                                    <td>${appt.timeSlot}</td>
                                    <td>${fn:escapeXml(appt.reason)}</td>
                                    <td><span class="badge ${appt.urgencyBadgeClass}">${appt.urgencyLevel}</span></td>
                                    <td><span class="badge ${appt.statusBadgeClass}">${appt.status}</span></td>
                                    <td>
                                        <div style="display:flex; gap:0.4rem;">
                                            <a href="${pageContext.request.contextPath}/patient/appointments/view/${appt.apptId}" class="btn btn-outline btn-sm">View</a>
                                            <c:if test="${appt.status == 'pending' || appt.status == 'confirmed'}">
                                                <form method="post" action="${pageContext.request.contextPath}/patient/appointments/cancel" style="display:inline;"
                                                      onsubmit="return confirm('Cancel this appointment?')">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="apptId" value="${appt.apptId}">
                                                    <button type="submit" class="btn btn-danger btn-sm">Cancel</button>
                                                </form>
                                            </c:if>
                                        </div>
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
