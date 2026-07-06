<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=5">
    <meta http-equiv="refresh" content="60">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container analytics-dashboard">
    <div class="analytics-hero mb-3">
        <div>
            <div class="analytics-eyebrow">MediQueue Analytics</div>
            <h1>Clinic operations at a glance</h1>
            <p>Monitor today's queue pressure, completion flow, and clinic activity from one control surface.</p>
        </div>
        <div class="analytics-hero-side">
            <div class="analytics-date-pill">${todayLabel}</div>
            <div class="analytics-actions">
                <a href="${pageContext.request.contextPath}/admin/queue?date=<%= new java.sql.Date(System.currentTimeMillis()) %>" class="analytics-action-card primary">
                    <div class="analytics-action-icon"><i class="fi fi-ss-list"></i></div>
                    <div class="analytics-action-copy">
                        <span class="analytics-action-title">Open Queue Desk</span>
                        <span class="analytics-action-text">Call, complete, and manage today's live patients.</span>
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/admin/appointments" class="analytics-action-card secondary">
                    <div class="analytics-action-icon"><i class="fi fi-ss-calendar"></i></div>
                    <div class="analytics-action-copy">
                        <span class="analytics-action-title">Moderate Appointments</span>
                        <span class="analytics-action-text">Review bookings, statuses, and clinic slot changes.</span>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger mb-3"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
    </c:if>

    <div class="analytics-kpi-grid mb-3">
        <div class="analytics-kpi-card">
            <div class="analytics-kpi-topline">
                <div class="analytics-kpi-label">Patients With Appointments Today</div>
                <div class="analytics-kpi-icon"><i class="fi fi-ss-users-alt"></i></div>
            </div>
            <div class="analytics-kpi-value">${totalToday}</div>
            <div class="analytics-kpi-meta">${completionRate}% completion rate so far</div>
        </div>
        <div class="analytics-kpi-card tone-warning">
            <div class="analytics-kpi-topline">
                <div class="analytics-kpi-label">Waiting Right Now</div>
                <div class="analytics-kpi-icon"><i class="fi fi-ss-hourglass-end"></i></div>
            </div>
            <div class="analytics-kpi-value">${waitingCount}</div>
            <div class="analytics-kpi-meta">${avgLiveWait} min average live wait</div>
        </div>
        <div class="analytics-kpi-card tone-info">
            <div class="analytics-kpi-topline">
                <div class="analytics-kpi-label">Currently Being Served</div>
                <div class="analytics-kpi-icon"><i class="fi fi-ss-stethoscope"></i></div>
            </div>
            <div class="analytics-kpi-value">${inProgressCount}</div>
            <div class="analytics-kpi-meta">${urgentCount} urgent or emergency in queue</div>
        </div>
        <div class="analytics-kpi-card tone-success">
            <div class="analytics-kpi-topline">
                <div class="analytics-kpi-label">Completed Today</div>
                <div class="analytics-kpi-icon"><i class="fi fi-ss-check-circle"></i></div>
            </div>
            <div class="analytics-kpi-value">${doneCount}</div>
            <div class="analytics-kpi-meta">${avgCompletedWait} min average completed wait</div>
        </div>
    </div>

    <div class="analytics-main-grid mb-3">
        <section class="analytics-panel analytics-panel-wide">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">30-day bookings vs completed visits</div>
                    <div class="analytics-panel-subtitle">A longer trend view of scheduled demand and completed care</div>
                </div>
                <div class="analytics-legend">
                    <span><i class="legend-dot purple"></i> Appointments booked</span>
                    <span><i class="legend-dot green"></i> Completed visits</span>
                </div>
            </div>
            <div class="analytics-chart-wrap analytics-chart-wrap-large">
                <c:out value="${operationsChartSvg}" escapeXml="false"/>
                <div class="analytics-chart-tooltip hidden" id="operationsChartTooltip" role="status" aria-live="polite">
                    <div class="analytics-chart-tooltip-date" id="operationsTooltipDate">-</div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key"><i class="legend-dot purple"></i>Appointments booked</span>
                        <strong id="operationsTooltipPrimary">0</strong>
                    </div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key"><i class="legend-dot green"></i>Completed visits</span>
                        <strong id="operationsTooltipSecondary">0</strong>
                    </div>
                    <div class="analytics-chart-tooltip-row analytics-chart-tooltip-row-muted">
                        <span>Completion rate</span>
                        <strong id="operationsTooltipRate">0%</strong>
                    </div>
                </div>
            </div>
            <div class="analytics-trend-summary">
                <div class="analytics-trend-card">
                    <span class="analytics-trend-label">Booked in 30 days</span>
                    <strong>${operationsOverview.bookedTotal}</strong>
                </div>
                <div class="analytics-trend-card">
                    <span class="analytics-trend-label">Completed in 30 days</span>
                    <strong>${operationsOverview.completedTotal}</strong>
                </div>
                <div class="analytics-trend-card">
                    <span class="analytics-trend-label">Peak booking day</span>
                    <strong>${operationsOverview.peakBookedValue}</strong>
                    <span class="analytics-trend-meta">${operationsOverview.peakBookedLabel}</span>
                </div>
                <div class="analytics-trend-card">
                    <span class="analytics-trend-label">Peak completion day</span>
                    <strong>${operationsOverview.peakCompletedValue}</strong>
                    <span class="analytics-trend-meta">${operationsOverview.peakCompletedLabel}</span>
                </div>
            </div>
        </section>

        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Queue status breakdown</div>
                    <div class="analytics-panel-subtitle">Today's queue mix across all clinics</div>
                </div>
                <div class="analytics-panel-chip">${activeQueueCount} active now</div>
            </div>
            <div class="analytics-status-stack">
                <c:forEach var="metric" items="${statusMetrics}">
                    <div class="analytics-status-row">
                        <div class="analytics-status-copy">
                            <div class="analytics-status-label">${metric.label}</div>
                            <div class="analytics-status-count">${metric.count} patients</div>
                        </div>
                        <div class="analytics-status-bar">
                            <div class="analytics-status-fill tone-${metric.tone}" style="width:${metric.percent}%"></div>
                        </div>
                        <div class="analytics-status-percent">${metric.percent}%</div>
                    </div>
                </c:forEach>
            </div>
        </section>

        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Average wait trend</div>
                    <div class="analytics-panel-subtitle">Based on recorded completed visits</div>
                </div>
                <div class="analytics-panel-chip">${avgCompletedWait} min today</div>
            </div>
            <div class="analytics-chart-wrap compact">
                <c:out value="${waitChartSvg}" escapeXml="false"/>
                <div class="analytics-chart-tooltip hidden" id="waitChartTooltip" role="status" aria-live="polite">
                    <div class="analytics-chart-tooltip-date" id="waitTooltipDate">-</div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key"><i class="legend-dot info"></i>Average wait</span>
                        <strong id="waitTooltipAvg">0 min</strong>
                    </div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key">Completed visits</span>
                        <strong id="waitTooltipVisits">0</strong>
                    </div>
                    <div class="analytics-chart-tooltip-row analytics-chart-tooltip-row-muted">
                        <span>Range</span>
                        <strong id="waitTooltipRange">0 - 0 min</strong>
                    </div>
                </div>
            </div>
            <div class="analytics-mini-labels">
                <c:forEach var="point" items="${waitTrend}">
                    <span>${point.label}</span>
                </c:forEach>
            </div>
        </section>
    </div>

    <div class="analytics-duo-grid mb-3">
        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Clinic queue pressure</div>
                    <div class="analytics-panel-subtitle">Current waiting load against clinic capacity</div>
                </div>
            </div>
            <div class="analytics-clinic-stack">
                <c:forEach var="metric" items="${clinicMetrics}">
                    <div class="analytics-clinic-row">
                        <div class="analytics-clinic-topline">
                            <div>
                                <div class="analytics-clinic-name">${fn:escapeXml(metric.clinicName)}</div>
                                <div class="analytics-clinic-meta">${fn:escapeXml(metric.district)} | Est. wait ${metric.estimatedWaitMins} min</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/queue?clinicId=${metric.clinicId}&date=<%= new java.sql.Date(System.currentTimeMillis()) %>" class="btn btn-outline btn-sm">View Queue</a>
                        </div>
                        <div class="analytics-load-bar">
                            <div class="analytics-load-fill" style="width:${metric.loadPercent}%"></div>
                        </div>
                        <div class="analytics-load-meta">
                            <span>${metric.waitingCount} waiting</span>
                            <span>${metric.inProgressCount} in progress</span>
                            <span>${metric.completedCount} done</span>
                            <span>${metric.capacity} capacity</span>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>

        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Priority worklist</div>
                    <div class="analytics-panel-subtitle">Live queue ordered by clinic queue feed</div>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty priorityQueue}">
                    <div class="analytics-empty-state">
                        <div class="compact-empty-icon"><i class="fi fi-ss-check-circle"></i></div>
                        <p>No live queue activity yet today.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="analytics-priority-stack">
                        <c:forEach var="q" items="${priorityQueue}">
                            <div class="analytics-priority-row ${q.urgencyLevel == 'emergency' ? 'priority-emergency' : q.urgencyLevel == 'urgent' ? 'priority-urgent' : ''}">
                                <div>
                                    <div class="analytics-priority-title">${fn:escapeXml(q.patientName)}</div>
                                    <div class="analytics-priority-meta">${fn:escapeXml(q.clinicName)} | Queue #${q.position} | ${q.timeSlot}</div>
                                </div>
                                <div class="analytics-priority-badges">
                                    <span class="badge ${q.statusBadgeClass}">${fn:escapeXml(q.status)}</span>
                                    <span class="badge badge-${q.urgencyLevel == 'emergency' ? 'danger' : q.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${fn:escapeXml(q.urgencyLevel)}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="analytics-duo-grid">
        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Active queue snapshot</div>
                    <div class="analytics-panel-subtitle">Current queue records for today</div>
                </div>
                <a href="${pageContext.request.contextPath}/admin/queue?date=<%= new java.sql.Date(System.currentTimeMillis()) %>" class="btn btn-outline btn-sm">Full Queue Panel</a>
            </div>
            <c:choose>
                <c:when test="${empty todayQueue}">
                    <div class="analytics-empty-state">
                        <div class="compact-empty-icon"><i class="fi fi-ss-list"></i></div>
                        <p>No patients in queue today.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="analytics-table-wrap">
                        <table class="mediqueue-table analytics-table">
                            <thead>
                                <tr><th>Queue</th><th>Patient</th><th>Clinic</th><th>Urgency</th><th>Status</th><th>Next Step</th></tr>
                            </thead>
                            <tbody>
                                <c:forEach var="q" items="${todayQueue}">
                                    <tr>
                                        <td><strong>#${q.position}</strong></td>
                                        <td>${fn:escapeXml(q.patientName)}</td>
                                        <td>${fn:escapeXml(q.clinicName)}</td>
                                        <td><span class="badge badge-${q.urgencyLevel == 'emergency' ? 'danger' : q.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${q.urgencyLevel}</span></td>
                                        <td><span class="badge ${q.statusBadgeClass}">${q.status}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${q.status == 'waiting'}">Ready to call</c:when>
                                                <c:when test="${q.status == 'in_progress'}">Ready to complete</c:when>
                                                <c:otherwise>Already processed</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <section class="analytics-panel">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Recent completed visits</div>
                    <div class="analytics-panel-subtitle">Latest entries from visit history</div>
                </div>
            </div>
            <c:choose>
                <c:when test="${empty recentVisits}">
                    <div class="analytics-empty-state">
                        <div class="compact-empty-icon"><i class="fi fi-ss-check-circle"></i></div>
                        <p>No completed visits recorded yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="analytics-visit-stack">
                        <c:forEach var="visit" items="${recentVisits}">
                            <div class="analytics-visit-row">
                                <div>
                                    <div class="analytics-visit-title">${fn:escapeXml(visit.patientName)}</div>
                                    <div class="analytics-visit-meta">${fn:escapeXml(visit.clinicName)} | ${visit.visitDate} | ${visit.actualWaitMins} min wait</div>
                                </div>
                                <span class="badge badge-success">Completed</span>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
<script>
(function () {
    var chartWrap = document.querySelector('.analytics-chart-wrap-large');
    var tooltip = document.getElementById('operationsChartTooltip');
    if (!chartWrap || !tooltip) return;

    var hitboxes = chartWrap.querySelectorAll('.analytics-chart-hitbox');
    var focusLines = chartWrap.querySelectorAll('.analytics-chart-focus-line');
    var focusDots = chartWrap.querySelectorAll('.analytics-chart-focus-dot');
    var tooltipDate = document.getElementById('operationsTooltipDate');
    var tooltipPrimary = document.getElementById('operationsTooltipPrimary');
    var tooltipSecondary = document.getElementById('operationsTooltipSecondary');
    var tooltipRate = document.getElementById('operationsTooltipRate');

    function clearActive() {
        focusLines.forEach(function (line) { line.classList.remove('active'); });
        focusDots.forEach(function (dot) { dot.classList.remove('active'); });
    }

    function positionTooltip(clientX, clientY) {
        var wrapRect = chartWrap.getBoundingClientRect();
        var tooltipRect = tooltip.getBoundingClientRect();
        var left = clientX - wrapRect.left + 18;
        var top = clientY - wrapRect.top - tooltipRect.height - 14;

        if (left + tooltipRect.width > wrapRect.width - 12) {
            left = wrapRect.width - tooltipRect.width - 12;
        }
        if (left < 12) {
            left = 12;
        }
        if (top < 12) {
            top = clientY - wrapRect.top + 16;
        }

        tooltip.style.left = left + 'px';
        tooltip.style.top = top + 'px';
    }

    function showTooltip(hitbox, event) {
        var index = Array.prototype.indexOf.call(hitboxes, hitbox);
        clearActive();

        if (focusLines[index]) {
            focusLines[index].classList.add('active');
        }
        var primaryDot = focusDots[index * 2];
        var secondaryDot = focusDots[index * 2 + 1];
        if (primaryDot) primaryDot.classList.add('active');
        if (secondaryDot) secondaryDot.classList.add('active');

        tooltipDate.textContent = hitbox.getAttribute('data-label') || '-';
        tooltipPrimary.textContent = hitbox.getAttribute('data-primary') || '0';
        tooltipSecondary.textContent = hitbox.getAttribute('data-secondary') || '0';
        tooltipRate.textContent = (hitbox.getAttribute('data-rate') || '0') + '%';
        tooltip.classList.remove('hidden');

        if (event) {
            positionTooltip(event.clientX, event.clientY);
        }
    }

    hitboxes.forEach(function (hitbox) {
        hitbox.addEventListener('mouseenter', function (event) {
            showTooltip(hitbox, event);
        });
        hitbox.addEventListener('mousemove', function (event) {
            showTooltip(hitbox, event);
        });
        hitbox.addEventListener('focus', function () {
            var rect = hitbox.getBoundingClientRect();
            showTooltip(hitbox, { clientX: rect.left + rect.width / 2, clientY: rect.top + 24 });
        });
        hitbox.addEventListener('mouseleave', function () {
            tooltip.classList.add('hidden');
            clearActive();
        });
        hitbox.addEventListener('blur', function () {
            tooltip.classList.add('hidden');
            clearActive();
        });
    });

    var waitWrap = document.querySelector('.analytics-chart-wrap.compact');
    var waitTooltip = document.getElementById('waitChartTooltip');
    if (!waitWrap || !waitTooltip) return;

    var waitHitboxes = waitWrap.querySelectorAll('.analytics-chart-hitbox-wait');
    var waitFocusLines = waitWrap.querySelectorAll('.analytics-chart-focus-line-wait');
    var waitFocusDots = waitWrap.querySelectorAll('.analytics-chart-focus-dot-wait');
    var waitTooltipDate = document.getElementById('waitTooltipDate');
    var waitTooltipAvg = document.getElementById('waitTooltipAvg');
    var waitTooltipVisits = document.getElementById('waitTooltipVisits');
    var waitTooltipRange = document.getElementById('waitTooltipRange');

    function clearWaitActive() {
        waitFocusLines.forEach(function (line) { line.classList.remove('active'); });
        waitFocusDots.forEach(function (dot) { dot.classList.remove('active'); });
    }

    function positionWaitTooltip(clientX, clientY) {
        var wrapRect = waitWrap.getBoundingClientRect();
        var tooltipRect = waitTooltip.getBoundingClientRect();
        var left = clientX - wrapRect.left + 16;
        var top = clientY - wrapRect.top - tooltipRect.height - 12;

        if (left + tooltipRect.width > wrapRect.width - 12) {
            left = wrapRect.width - tooltipRect.width - 12;
        }
        if (left < 12) {
            left = 12;
        }
        if (top < 12) {
            top = clientY - wrapRect.top + 16;
        }

        waitTooltip.style.left = left + 'px';
        waitTooltip.style.top = top + 'px';
    }

    function showWaitTooltip(hitbox, event) {
        var index = Array.prototype.indexOf.call(waitHitboxes, hitbox);
        clearWaitActive();
        if (waitFocusLines[index]) waitFocusLines[index].classList.add('active');
        if (waitFocusDots[index]) waitFocusDots[index].classList.add('active');

        waitTooltipDate.textContent = hitbox.getAttribute('data-label') || '-';
        waitTooltipAvg.textContent = (hitbox.getAttribute('data-value') || '0') + ' min';
        waitTooltipVisits.textContent = hitbox.getAttribute('data-visits') || '0';
        waitTooltipRange.textContent = (hitbox.getAttribute('data-min') || '0') + ' - ' + (hitbox.getAttribute('data-max') || '0') + ' min';
        waitTooltip.classList.remove('hidden');

        if (event) {
            positionWaitTooltip(event.clientX, event.clientY);
        }
    }

    waitHitboxes.forEach(function (hitbox) {
        hitbox.addEventListener('mouseenter', function (event) {
            showWaitTooltip(hitbox, event);
        });
        hitbox.addEventListener('mousemove', function (event) {
            showWaitTooltip(hitbox, event);
        });
        hitbox.addEventListener('focus', function () {
            var rect = hitbox.getBoundingClientRect();
            showWaitTooltip(hitbox, { clientX: rect.left + rect.width / 2, clientY: rect.top + 20 });
        });
        hitbox.addEventListener('mouseleave', function () {
            waitTooltip.classList.add('hidden');
            clearWaitActive();
        });
        hitbox.addEventListener('blur', function () {
            waitTooltip.classList.add('hidden');
            clearWaitActive();
        });
    });
})();
</script>
</body>
</html>
