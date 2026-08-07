<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Queue Panel - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=12">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="admin-hero compact mb-3">
        <div>
            <div class="eyebrow">Queue Desk</div>
            <h1><i class="fi fi-ss-list"></i> Queue Management Panel</h1>
            <p>Work the live queue by clinic and date. Call, skip, and complete patients from one place.</p>
        </div>
        <div class="queue-scope-pill">${fn:escapeXml(scopeTitle)}</div>
    </div>

    <div class="queue-stat-grid mb-3">
        <div class="queue-stat-card">
            <span class="queue-stat-label">Waiting</span>
            <strong>${waitingCount}</strong>
        </div>
        <div class="queue-stat-card">
            <span class="queue-stat-label">In Progress</span>
            <strong>${inProgressCount}</strong>
        </div>
        <div class="queue-stat-card">
            <span class="queue-stat-label">Completed</span>
            <strong>${doneCount}</strong>
        </div>
        <div class="queue-stat-card">
            <span class="queue-stat-label">Skipped</span>
            <strong>${skippedCount}</strong>
        </div>
    </div>

    <section class="card users-filter-card mb-3">
        <div class="card-body">
            <div class="users-filter-form">
                <div class="users-filter-grid users-filter-grid-compact">
                    <div class="queue-filter-summary">
                        <div class="queue-filter-summary-icon"><i class="fi fi-ss-search"></i></div>
                        <div>
                            <div class="queue-filter-summary-title">Queue view</div>
                            <div class="queue-filter-summary-copy">${fn:escapeXml(scopeTitle)} | ${selectedDate}</div>
                        </div>
                    </div>
                    <div class="users-filter-actions">
                        <div class="users-filter-popover-wrap">
                            <button type="button" class="btn btn-outline" id="openQueueFilters">
                                <i class="fi fi-ss-settings-sliders"></i> Filter
                            </button>
                            <form method="get" action="${pageContext.request.contextPath}/admin/queue"
                                  class="users-filter-popover" id="queueFilterPopover" aria-hidden="true">
                                <div class="users-filter-popover-header">
                                    <strong>Filters</strong>
                                    <button type="button" class="users-filter-close" id="closeQueueFilters" aria-label="Close queue filters">
                                        <i class="fi fi-ss-cross-small"></i>
                                    </button>
                                </div>
                                <div class="users-filter-popover-body">
                                    <div class="users-filter-group">
                                        <span class="users-filter-label">Clinic</span>
                                        <select name="clinicId" class="form-control">
                                            <option value="">All clinics</option>
                                            <c:forEach var="clinic" items="${clinics}">
                                                <option value="${clinic.clinicId}" ${clinic.clinicId == selectedClinicId ? 'selected' : ''}>${fn:escapeXml(clinic.name)}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="users-filter-group">
                                        <span class="users-filter-label">Date</span>
                                        <input type="date" name="date" class="form-control" value="${selectedDate}">
                                    </div>
                                </div>
                                <div class="users-filter-popover-footer">
                                    <a href="${pageContext.request.contextPath}/admin/queue?date=<%= new java.sql.Date(System.currentTimeMillis()) %>" class="btn btn-outline btn-sm">Clear</a>
                                    <button type="submit" class="btn btn-primary btn-sm">Apply</button>
                                </div>
                            </form>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/queue?date=<%= new java.sql.Date(System.currentTimeMillis()) %>" class="btn btn-outline">
                            Reset to Today
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h5>Queue List</h5>
            <span class="badge badge-primary">${empty queues ? 0 : queues.size()} patients</span>
        </div>
        <c:choose>
            <c:when test="${empty queues}">
                <div class="card-body">
                    <div class="compact-empty-state large">
                        <div class="compact-empty-icon"><i class="fi fi-ss-list"></i></div>
                        <p>No patients in queue for this view.</p>
                        <span class="text-muted">Try another clinic, another date, or reset back to today.</span>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="queue-desk-list">
                    <c:forEach var="q" items="${queues}">
                        <div class="queue-desk-row ${q.urgencyLevel == 'emergency' ? 'priority-emergency' : q.urgencyLevel == 'urgent' ? 'priority-urgent' : ''}">
                            <div class="queue-desk-main">
                                <div class="queue-desk-rank">#${q.position}</div>
                                <div>
                                    <div class="queue-desk-title">${fn:escapeXml(q.patientName)}</div>
                                    <div class="queue-desk-meta">
                                        ${fn:escapeXml(q.clinicName)} · ${q.timeSlot} · ${q.estimatedWaitMins} min wait
                                    </div>
                                </div>
                            </div>
                            <div class="queue-desk-side">
                                <span class="badge badge-${q.urgencyLevel == 'emergency' ? 'danger' : q.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${q.urgencyLevel}</span>
                                <span class="badge ${q.statusBadgeClass}">${q.status}</span>
                            </div>
                            <div class="queue-desk-actions">
                                <c:if test="${q.status == 'waiting'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/queue">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="queueId" value="${q.queueId}">
                                        <input type="hidden" name="apptId" value="${q.apptId}">
                                        <input type="hidden" name="clinicId" value="${selectedClinicId}">
                                        <input type="hidden" name="date" value="${selectedDate}">
                                        <input type="hidden" name="status" value="in_progress">
                                        <button type="submit" class="btn btn-primary btn-sm"><i class="fi fi-ss-play"></i> Call Patient</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/queue">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="queueId" value="${q.queueId}">
                                        <input type="hidden" name="apptId" value="${q.apptId}">
                                        <input type="hidden" name="clinicId" value="${selectedClinicId}">
                                        <input type="hidden" name="date" value="${selectedDate}">
                                        <input type="hidden" name="status" value="skipped">
                                        <button type="submit" class="btn btn-warning btn-sm"><i class="fi fi-ss-step-forward"></i> Skip</button>
                                    </form>
                                </c:if>
                                <c:if test="${q.status == 'in_progress'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/queue">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="queueId" value="${q.queueId}">
                                        <input type="hidden" name="apptId" value="${q.apptId}">
                                        <input type="hidden" name="clinicId" value="${selectedClinicId}">
                                        <input type="hidden" name="date" value="${selectedDate}">
                                        <input type="hidden" name="status" value="done">
                                        <button type="submit" class="btn btn-success btn-sm"><i class="fi fi-ss-check"></i> Mark Done</button>
                                    </form>
                                </c:if>
                                <c:if test="${q.status == 'done' || q.status == 'skipped'}">
                                    <span class="text-muted">No further action</span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
<script>
(function () {
    var filterBtn = document.getElementById('openQueueFilters');
    var closeFilterBtn = document.getElementById('closeQueueFilters');
    var filterPopover = document.getElementById('queueFilterPopover');

    function setFilterPopover(open) {
        if (!filterPopover) return;
        filterPopover.classList.toggle('open', open);
        filterPopover.setAttribute('aria-hidden', open ? 'false' : 'true');
    }

    if (filterBtn) {
        filterBtn.addEventListener('click', function () {
            var isOpen = filterPopover && filterPopover.classList.contains('open');
            setFilterPopover(!isOpen);
        });
    }

    if (closeFilterBtn) {
        closeFilterBtn.addEventListener('click', function () {
            setFilterPopover(false);
        });
    }

    document.addEventListener('click', function (event) {
        if (!filterPopover || !filterBtn) return;
        if (!filterPopover.contains(event.target) && !filterBtn.contains(event.target)) {
            setFilterPopover(false);
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            setFilterPopover(false);
        }
    });
})();
</script>
</body>
</html>
