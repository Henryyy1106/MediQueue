<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Details - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container" style="max-width: 700px;">
    <div class="page-header">
        <h1><i class="fi fi-ss-clipboard-list"></i> Appointment Details</h1>
        <a href="${pageContext.request.contextPath}/patient/appointments" style="color:var(--primary); font-size:0.9rem;"><i class="fi fi-ss-arrow-small-left"></i> Back to Appointments</a>
    </div>

    <c:if test="${param.booked == 'true'}">
        <div class="alert alert-success"><i class="fi fi-ss-check"></i> Appointment booked successfully! You've been added to the queue.</div>
    </c:if>

    <c:if test="${param.emergency == 'true'}">
        <div class="urgency-emergency">
            <i class="fi fi-ss-light-emergency-on"></i> EMERGENCY: Your symptoms may require immediate care. Please proceed to the nearest A&E department NOW.
        </div>
    </c:if>

    <c:if test="${not empty appointment}">
        <!-- Appointment Info -->
        <div class="card mb-3">
            <div class="card-header">
                <h5>Appointment Information</h5>
                <span class="badge ${appointment.statusBadgeClass}">${appointment.status}</span>
            </div>
            <div class="card-body">
                <table style="width:100%; font-size:0.9rem;">
                    <tr><td style="padding:0.5rem; color:#888; width:35%;">Clinic</td><td><strong>${fn:escapeXml(appointment.clinicName)}</strong></td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Address</td><td>${fn:escapeXml(appointment.clinicAddress)}</td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Date</td><td>${appointment.apptDate}</td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Time Slot</td><td>${appointment.timeSlot}</td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Reason</td><td>${fn:escapeXml(appointment.reason)}</td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Symptoms</td><td>${not empty appointment.symptoms ? appointment.symptoms : '—'}</td></tr>
                    <tr><td style="padding:0.5rem; color:#888;">Urgency</td><td><span class="badge ${appointment.urgencyBadgeClass}">${appointment.urgencyLevel}</span></td></tr>
                </table>
            </div>
        </div>

        <!-- AI Notes -->
        <c:if test="${not empty appointment.aiNotes}">
            <div class="ai-card mb-3">
                <h4><i class="fi fi-ss-robot"></i> AI Helper Notes</h4>
                <p>${fn:escapeXml(appointment.aiNotes)}</p>
                <p style="font-size:0.75rem; opacity:0.8; margin-top:0.5rem;">AI guidance only. Not a medical diagnosis. Consult a qualified doctor.</p>
            </div>
        </c:if>

        <!-- Queue Status -->
        <c:if test="${not empty queue}">
            <div class="card mb-3">
                <div class="card-header"><h5><i class="fi fi-ss-list"></i> Queue Status</h5></div>
                <div class="card-body queue-status-card">
                    <div class="queue-position">#${queue.position}</div>
                    <p style="font-size:1.1rem; color:#555; margin:0.5rem 0;">Your queue position</p>
                    <div class="queue-progress">
                        <div class="queue-progress-bar" style="width: ${queue.status == 'done' ? 100 : queue.status == 'in_progress' ? 80 : 30}%"></div>
                    </div>
                    <div style="display: flex; gap: 1.5rem; justify-content: center; margin-top: 1rem;">
                        <div><strong>${queue.waitLabel}</strong><br><span class="text-muted">Est. Wait</span></div>
                        <div><span class="badge ${queue.statusBadgeClass}">${queue.status}</span><br><span class="text-muted">Status</span></div>
                    </div>
                    <div style="margin-top:1rem;">
                        <a href="${pageContext.request.contextPath}/patient/queue" class="btn btn-primary">Live Queue Tracker <i class="fi fi-ss-arrow-small-right"></i></a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Actions -->
        <c:if test="${appointment.status == 'pending' || appointment.status == 'confirmed'}">
            <div class="card">
                <div class="card-body">
                    <form method="post" action="${pageContext.request.contextPath}/patient/appointments/cancel"
                          onsubmit="return confirm('Are you sure you want to cancel this appointment?')">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="apptId" value="${appointment.apptId}">
                        <button type="submit" class="btn btn-danger"><i class="fi fi-ss-cross-small"></i> Cancel Appointment</button>
                    </form>
                </div>
            </div>
        </c:if>
    </c:if>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
