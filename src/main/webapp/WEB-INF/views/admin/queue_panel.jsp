<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Queue Panel - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-list"></i> Queue Management Panel</h1>
        <p>Filter by clinic and date to manage patient queue</p>
    </div>

    <!-- Filter Form -->
    <div class="card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/queue">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Clinic</label>
                        <select name="clinicId" class="form-control">
                            <option value="">-- All Clinics --</option>
                            <c:forEach var="clinic" items="${clinics}">
                                <option value="${clinic.clinicId}" ${clinic.clinicId == selectedClinicId ? 'selected' : ''}>${fn:escapeXml(clinic.name)}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Date</label>
                        <input type="date" name="date" class="form-control" value="${selectedDate}">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary"><i class="fi fi-ss-search"></i> Filter</button>
            </form>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
    </c:if>

    <!-- Queue Table -->
    <div class="card">
        <div class="card-header">
            <h5>Queue List</h5>
            <span class="badge badge-primary">${queues.size()} patients</span>
        </div>
        <c:choose>
            <c:when test="${empty queues}">
                <div class="card-body text-center" style="padding: 2.5rem;">
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;"><i class="fi fi-ss-list"></i></div>
                    <p class="text-muted">No patients in queue for the selected filter.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container">
                    <table class="mediqueue-table">
                        <thead>
                            <tr>
                                <th>Pos</th>
                                <th>Patient</th>
                                <th>Clinic</th>
                                <th>Time Slot</th>
                                <th>Urgency</th>
                                <th>Est. Wait</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="q" items="${queues}">
                                <tr style="${q.urgencyLevel == 'emergency' ? 'background:#fff5f5;' : q.urgencyLevel == 'urgent' ? 'background:#fffdf0;' : ''}">
                                    <td><strong style="font-size:1.1rem;">${q.position}</strong></td>
                                    <td>${fn:escapeXml(q.patientName)}</td>
                                    <td style="font-size:0.85rem;">${fn:escapeXml(q.clinicName)}</td>
                                    <td>${q.timeSlot}</td>
                                    <td><span class="badge badge-${q.urgencyLevel == 'emergency' ? 'danger' : q.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${q.urgencyLevel}</span></td>
                                    <td>${q.estimatedWaitMins} min</td>
                                    <td><span class="badge ${q.statusBadgeClass}">${q.status}</span></td>
                                    <td>
                                        <div style="display:flex; gap:0.4rem; flex-wrap:wrap;">
                                            <c:if test="${q.status == 'waiting'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/queue" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="queueId" value="${q.queueId}">
                                                    <input type="hidden" name="apptId" value="${q.apptId}">
                                                    <input type="hidden" name="status" value="in_progress">
                                                    <button type="submit" class="btn btn-primary btn-sm"><i class="fi fi-ss-play"></i> Call</button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/queue" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="queueId" value="${q.queueId}">
                                                    <input type="hidden" name="apptId" value="${q.apptId}">
                                                    <input type="hidden" name="status" value="skipped">
                                                    <button type="submit" class="btn btn-warning btn-sm"><i class="fi fi-ss-step-forward"></i> Skip</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${q.status == 'in_progress'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/queue" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="queueId" value="${q.queueId}">
                                                    <input type="hidden" name="apptId" value="${q.apptId}">
                                                    <input type="hidden" name="status" value="done">
                                                    <button type="submit" class="btn btn-success btn-sm"><i class="fi fi-ss-check"></i> Done</button>
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
