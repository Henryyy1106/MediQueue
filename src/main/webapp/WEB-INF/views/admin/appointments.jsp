<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Moderation - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-calendar"></i> Appointment Moderation</h1>
        <p>Review, filter, and safely update patient bookings.</p>
    </div>

    <c:if test="${param.updated == '1'}"><div class="alert alert-success">Appointment updated successfully.</div></c:if>
    <c:if test="${not empty param.error}"><div class="alert alert-danger">${fn:escapeXml(fn:replace(param.error, '_', ' '))}</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-danger">${fn:escapeXml(error)}</div></c:if>

    <div class="card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/appointments">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Patient</label>
                        <input type="text" name="patient" class="form-control" value="${fn:escapeXml(filterPatient)}" placeholder="Name or email">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Clinic</label>
                        <select name="clinicId" class="form-control">
                            <option value="">All clinics</option>
                            <c:forEach var="clinic" items="${clinics}">
                                <option value="${clinic.clinicId}" ${clinic.clinicId == filterClinicId ? 'selected' : ''}>${fn:escapeXml(clinic.name)}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control">
                            <option value="">All statuses</option>
                            <option value="pending" ${filterStatus == 'pending' ? 'selected' : ''}>Pending</option>
                            <option value="confirmed" ${filterStatus == 'confirmed' ? 'selected' : ''}>Confirmed</option>
                            <option value="cancelled" ${filterStatus == 'cancelled' ? 'selected' : ''}>Cancelled</option>
                            <option value="completed" ${filterStatus == 'completed' ? 'selected' : ''}>Completed</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Urgency</label>
                        <select name="urgency" class="form-control">
                            <option value="">All urgency levels</option>
                            <option value="routine" ${filterUrgency == 'routine' ? 'selected' : ''}>Routine</option>
                            <option value="urgent" ${filterUrgency == 'urgent' ? 'selected' : ''}>Urgent</option>
                            <option value="emergency" ${filterUrgency == 'emergency' ? 'selected' : ''}>Emergency</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Appointment Date</label>
                        <input type="date" name="apptDate" class="form-control" value="${filterApptDate}">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Filter Appointments</button>
            </form>
        </div>
    </div>

    <c:if test="${not empty selectedAppointment}">
        <div class="card mb-3">
            <div class="card-header"><h5>Moderate Appointment #${selectedAppointment.apptId}</h5></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/admin/appointments">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="apptId" value="${selectedAppointment.apptId}">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Clinic *</label>
                            <select name="clinicId" class="form-control" required>
                                <c:forEach var="clinic" items="${clinics}">
                                    <option value="${clinic.clinicId}" ${clinic.clinicId == selectedAppointment.clinicId ? 'selected' : ''}>${fn:escapeXml(clinic.name)}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Date *</label>
                            <input type="date" name="apptDate" class="form-control" value="${selectedAppointment.apptDate}" required>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Time Slot *</label>
                            <select name="timeSlot" class="form-control" required>
                                <option value="08:00" ${selectedAppointment.timeSlot == '08:00' ? 'selected' : ''}>08:00</option>
                                <option value="08:30" ${selectedAppointment.timeSlot == '08:30' ? 'selected' : ''}>08:30</option>
                                <option value="09:00" ${selectedAppointment.timeSlot == '09:00' ? 'selected' : ''}>09:00</option>
                                <option value="09:30" ${selectedAppointment.timeSlot == '09:30' ? 'selected' : ''}>09:30</option>
                                <option value="10:00" ${selectedAppointment.timeSlot == '10:00' ? 'selected' : ''}>10:00</option>
                                <option value="10:30" ${selectedAppointment.timeSlot == '10:30' ? 'selected' : ''}>10:30</option>
                                <option value="11:00" ${selectedAppointment.timeSlot == '11:00' ? 'selected' : ''}>11:00</option>
                                <option value="11:30" ${selectedAppointment.timeSlot == '11:30' ? 'selected' : ''}>11:30</option>
                                <option value="14:00" ${selectedAppointment.timeSlot == '14:00' ? 'selected' : ''}>14:00</option>
                                <option value="14:30" ${selectedAppointment.timeSlot == '14:30' ? 'selected' : ''}>14:30</option>
                                <option value="15:00" ${selectedAppointment.timeSlot == '15:00' ? 'selected' : ''}>15:00</option>
                                <option value="15:30" ${selectedAppointment.timeSlot == '15:30' ? 'selected' : ''}>15:30</option>
                                <option value="16:00" ${selectedAppointment.timeSlot == '16:00' ? 'selected' : ''}>16:00</option>
                                <option value="16:30" ${selectedAppointment.timeSlot == '16:30' ? 'selected' : ''}>16:30</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Status *</label>
                            <select name="status" class="form-control" required>
                                <option value="pending" ${selectedAppointment.status == 'pending' ? 'selected' : ''}>Pending</option>
                                <option value="confirmed" ${selectedAppointment.status == 'confirmed' ? 'selected' : ''}>Confirmed</option>
                                <option value="cancelled" ${selectedAppointment.status == 'cancelled' ? 'selected' : ''}>Cancelled</option>
                                <option value="completed" ${selectedAppointment.status == 'completed' ? 'selected' : ''}>Completed</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Urgency *</label>
                            <select name="urgencyLevel" class="form-control" required>
                                <option value="routine" ${selectedAppointment.urgencyLevel == 'routine' ? 'selected' : ''}>Routine</option>
                                <option value="urgent" ${selectedAppointment.urgencyLevel == 'urgent' ? 'selected' : ''}>Urgent</option>
                                <option value="emergency" ${selectedAppointment.urgencyLevel == 'emergency' ? 'selected' : ''}>Emergency</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Reason *</label>
                        <input type="text" name="reason" class="form-control" value="${fn:escapeXml(selectedAppointment.reason)}" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Symptoms</label>
                        <textarea name="symptoms" class="form-control" rows="3">${fn:escapeXml(selectedAppointment.symptoms)}</textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Internal Admin Notes</label>
                        <textarea name="adminNotes" class="form-control" rows="3">${fn:escapeXml(selectedAppointment.adminNotes)}</textarea>
                    </div>
                    <c:if test="${not empty selectedAppointment.aiNotes}">
                        <div class="ai-card mb-2">
                            <h4><i class="fi fi-ss-robot"></i> Existing AI Notes</h4>
                            <p>${fn:escapeXml(selectedAppointment.aiNotes)}</p>
                        </div>
                    </c:if>
                    <div style="display:flex; gap:0.75rem; flex-wrap:wrap;">
                        <button type="submit" class="btn btn-primary">Save Appointment</button>
                        <a href="${pageContext.request.contextPath}/admin/appointments" class="btn btn-outline">Close</a>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h5>Appointments</h5>
            <span class="badge badge-primary">${empty appointments ? 0 : appointments.size()} records</span>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty appointments}">
                    <p class="text-muted text-center">No appointments match the current filters.</p>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="mediqueue-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Patient</th>
                                    <th>Clinic</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Status</th>
                                    <th>Urgency</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="appt" items="${appointments}">
                                    <tr>
                                        <td>#${appt.apptId}</td>
                                        <td>${fn:escapeXml(appt.patientName)}</td>
                                        <td>${fn:escapeXml(appt.clinicName)}</td>
                                        <td>${appt.apptDate}</td>
                                        <td>${appt.timeSlot}</td>
                                        <td><span class="badge ${appt.statusBadgeClass}">${fn:escapeXml(appt.status)}</span></td>
                                        <td><span class="badge ${appt.urgencyBadgeClass}">${fn:escapeXml(appt.urgencyLevel)}</span></td>
                                        <td><a href="${pageContext.request.contextPath}/admin/appointments/view/${appt.apptId}" class="btn btn-outline btn-sm">Moderate</a></td>
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
