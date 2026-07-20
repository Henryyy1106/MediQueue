<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=16">
    <meta http-equiv="refresh" content="60">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container analytics-dashboard">
    <div class="analytics-topbar mb-3">
        <div class="analytics-search-field">
            <i class="fi fi-ss-search"></i>
            <input type="search" id="dashboardSearchInput" class="form-control" placeholder="Search anything" autocomplete="off" aria-label="Search admin pages and dashboard sections" aria-controls="dashboardSearchResults" aria-expanded="false">
            <div class="analytics-search-results hidden" id="dashboardSearchResults" role="listbox" aria-label="Search results"></div>
        </div>
        <div class="analytics-date-pill">${todayLabel}</div>
    </div>

    <div class="analytics-hero mb-3">
        <div>
            <div class="analytics-eyebrow">MediQueue Analytics</div>
            <h1>Clinic operations at a glance</h1>
            <p>Monitor today's queue pressure, completion flow, and clinic activity from one control surface.</p>
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
        <section class="analytics-panel" data-dashboard-section="daily-volume">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Daily outpatient volume</div>
                    <div class="analytics-panel-subtitle">Visits completed over the past week</div>
                </div>
                <div class="analytics-panel-chip">${doneCount} completed today</div>
            </div>
            <div class="analytics-chart-wrap analytics-chart-wrap-large">
                <c:out value="${dailyVolumeChartSvg}" escapeXml="false"/>
                <div class="analytics-chart-tooltip hidden analytics-chart-tooltip-dark" id="dailyVolumeChartTooltip" role="status" aria-live="polite">
                    <div class="analytics-chart-tooltip-date" id="dailyVolumeTooltipDate">-</div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key"><i class="legend-dot green"></i>Completed consultations</span>
                        <strong id="dailyVolumeTooltipValue">0</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="analytics-panel" data-dashboard-section="status-breakdown">
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
                            <div class="analytics-status-fill tone-${metric.tone}" data-fill-percent="${metric.percent}"></div>
                        </div>
                        <div class="analytics-status-percent">${metric.percent}%</div>
                    </div>
                </c:forEach>
            </div>
        </section>

        <section class="analytics-panel" data-dashboard-section="wait-times">
            <div class="analytics-panel-header">
                <div>
                    <div class="analytics-panel-title">Average wait times</div>
                    <div class="analytics-panel-subtitle">Average clinic queuing duration (minutes)</div>
                </div>
                <div class="analytics-panel-chip">${avgLiveWait} min live wait</div>
            </div>
            <div class="analytics-chart-wrap compact">
                <c:out value="${clinicWaitChartSvg}" escapeXml="false"/>
                <div class="analytics-chart-tooltip hidden analytics-chart-tooltip-dark" id="clinicWaitChartTooltip" role="status" aria-live="polite">
                    <div class="analytics-chart-tooltip-date" id="clinicWaitTooltipLabel">-</div>
                    <div class="analytics-chart-tooltip-row">
                        <span class="analytics-chart-tooltip-key"><i class="legend-dot info"></i>Wait duration (mins)</span>
                        <strong id="clinicWaitTooltipValue">0</strong>
                    </div>
                </div>
            </div>
        </section>

        <section class="analytics-panel" data-dashboard-section="priority-worklist">
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
                            <c:set var="priorityToneClass" value=""/>
                            <c:if test="${q.urgencyLevel == 'emergency'}">
                                <c:set var="priorityToneClass" value="priority-emergency"/>
                            </c:if>
                            <c:if test="${q.urgencyLevel == 'urgent'}">
                                <c:set var="priorityToneClass" value="priority-urgent"/>
                            </c:if>
                            <div class="analytics-priority-row ${priorityToneClass}">
                                <div>
                                    <div class="analytics-priority-title">${fn:escapeXml(q.patientName)}</div>
                                    <div class="analytics-priority-meta">${fn:escapeXml(q.clinicName)} | Queue #${q.position} | ${q.timeSlot}</div>
                                </div>
                                <div class="analytics-priority-badges">
                                    <span class="badge ${q.statusBadgeClass}">${fn:escapeXml(q.status)}</span>
                                    <c:choose>
                                        <c:when test="${q.urgencyLevel == 'emergency'}">
                                            <span class="badge badge-danger">${fn:escapeXml(q.urgencyLevel)}</span>
                                        </c:when>
                                        <c:when test="${q.urgencyLevel == 'urgent'}">
                                            <span class="badge badge-warning">${fn:escapeXml(q.urgencyLevel)}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-success">${fn:escapeXml(q.urgencyLevel)}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <div class="analytics-duo-grid mb-3">
        <section class="analytics-panel" data-dashboard-section="clinic-pressure">
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
                            <a href="${pageContext.request.contextPath}/admin/queue?clinicId=${metric.clinicId}&date=${todayIso}" class="btn btn-outline btn-sm">View Queue</a>
                        </div>
                        <div class="analytics-load-bar">
                            <div class="analytics-load-fill" data-fill-percent="${metric.loadPercent}"></div>
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

        <section class="analytics-panel" data-dashboard-section="recent-visits">
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

    <section class="analytics-panel mb-3" data-dashboard-section="active-queue">
        <div class="analytics-panel-header">
            <div>
                <div class="analytics-panel-title">Active queue snapshot</div>
                <div class="analytics-panel-subtitle">Current queue records for today</div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/queue?date=${todayIso}" class="btn btn-outline btn-sm">Full Queue Panel</a>
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
                                    <td>
                                        <c:choose>
                                            <c:when test="${q.urgencyLevel == 'emergency'}">
                                                <span class="badge badge-danger">${fn:escapeXml(q.urgencyLevel)}</span>
                                            </c:when>
                                            <c:when test="${q.urgencyLevel == 'urgent'}">
                                                <span class="badge badge-warning">${fn:escapeXml(q.urgencyLevel)}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-success">${fn:escapeXml(q.urgencyLevel)}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
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
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
<script>
(function () {
    var dashboardSearchInput = document.getElementById('dashboardSearchInput');
    var dashboardSearchResults = document.getElementById('dashboardSearchResults');

    document.querySelectorAll('[data-fill-percent]').forEach(function (bar) {
        var percent = Number(bar.getAttribute('data-fill-percent')) || 0;
        bar.style.width = Math.max(0, Math.min(100, percent)) + '%';
    });

    if (dashboardSearchInput) {
        var searchItems = [
            {
                title: 'Dashboard',
                description: 'Clinic operations overview',
                icon: 'fi fi-ss-chart-histogram',
                keywords: 'dashboard analytics overview home operations',
                href: '${pageContext.request.contextPath}/admin/dashboard'
            },
            {
                title: 'Queue Panel',
                description: 'Call, skip, and complete live queue patients',
                icon: 'fi fi-ss-list',
                keywords: 'queue panel queue desk waiting in progress live patients',
                href: '${pageContext.request.contextPath}/admin/queue'
            },
            {
                title: 'Users',
                description: 'Search, create, and edit patient or admin accounts',
                icon: 'fi fi-ss-users-alt',
                keywords: 'users user management accounts patients admins create edit',
                href: '${pageContext.request.contextPath}/admin/users'
            },
            {
                title: 'Appointments',
                description: 'Review and moderate patient bookings',
                icon: 'fi fi-ss-calendar',
                keywords: 'appointments bookings schedule moderate status urgency',
                href: '${pageContext.request.contextPath}/admin/appointments'
            },
            {
                title: 'Reports',
                description: 'Clinic reporting and operational summaries',
                icon: 'fi fi-ss-chart-line-up',
                keywords: 'reports reporting summaries charts history',
                href: '${pageContext.request.contextPath}/admin/reports'
            },
            {
                title: 'Daily outpatient volume',
                description: 'Completed consultations over the past week',
                icon: 'fi fi-ss-chart-line-up',
                keywords: 'daily outpatient volume completed consultations graph chart',
                selector: '[data-dashboard-section="daily-volume"]'
            },
            {
                title: 'Queue status breakdown',
                description: 'Waiting, in progress, completed, and skipped mix',
                icon: 'fi fi-ss-chart-pie',
                keywords: 'queue status breakdown waiting in progress completed skipped',
                selector: '[data-dashboard-section="status-breakdown"]'
            },
            {
                title: 'Average wait times',
                description: 'Average clinic queuing duration',
                icon: 'fi fi-ss-clock',
                keywords: 'average wait times clinic duration graph chart',
                selector: '[data-dashboard-section="wait-times"]'
            },
            {
                title: 'Priority worklist',
                description: 'Live queue ordered by clinic feed',
                icon: 'fi fi-ss-list-check',
                keywords: 'priority worklist urgent emergency live queue',
                selector: '[data-dashboard-section="priority-worklist"]'
            },
            {
                title: 'Clinic queue pressure',
                description: 'Waiting load against clinic capacity',
                icon: 'fi fi-ss-hospital',
                keywords: 'clinic queue pressure capacity load waiting',
                selector: '[data-dashboard-section="clinic-pressure"]'
            },
            {
                title: 'Recent completed visits',
                description: 'Latest entries from visit history',
                icon: 'fi fi-ss-check-circle',
                keywords: 'recent completed visits history patients',
                selector: '[data-dashboard-section="recent-visits"]'
            },
            {
                title: 'Active queue snapshot',
                description: 'Current queue records for today',
                icon: 'fi fi-ss-table-list',
                keywords: 'active queue snapshot current records table',
                selector: '[data-dashboard-section="active-queue"]'
            }
        ];

        function normalize(value) {
            return (value || '').toLowerCase().trim();
        }

        function getMatches(query) {
            if (!query) return [];
            return searchItems.filter(function (item) {
                return normalize(item.title + ' ' + item.description + ' ' + item.keywords).indexOf(query) !== -1;
            }).slice(0, 6);
        }

        function closeSearchResults() {
            if (!dashboardSearchResults) return;
            dashboardSearchResults.classList.add('hidden');
            dashboardSearchResults.innerHTML = '';
            dashboardSearchInput.setAttribute('aria-expanded', 'false');
        }

        function activateSearchItem(item) {
            if (!item) return;
            if (item.href) {
                window.location.href = item.href;
                return;
            }
            var target = document.querySelector(item.selector);
            if (!target) return;
            closeSearchResults();
            target.scrollIntoView({ behavior: 'smooth', block: 'center' });
            target.classList.add('analytics-search-focus');
            window.setTimeout(function () {
                target.classList.remove('analytics-search-focus');
            }, 1400);
        }

        function renderSearchResults() {
            if (!dashboardSearchResults) return;

            var query = normalize(dashboardSearchInput.value);
            var matches = getMatches(query);
            dashboardSearchResults.innerHTML = '';

            if (!query) {
                closeSearchResults();
                return;
            }

            if (matches.length === 0) {
                var empty = document.createElement('div');
                empty.className = 'analytics-search-empty';
                empty.textContent = 'No matching admin page or dashboard section.';
                dashboardSearchResults.appendChild(empty);
                dashboardSearchResults.classList.remove('hidden');
                dashboardSearchInput.setAttribute('aria-expanded', 'true');
                return;
            }

            matches.forEach(function (item) {
                var button = document.createElement('button');
                button.type = 'button';
                button.className = 'analytics-search-result';
                button.setAttribute('role', 'option');
                button.innerHTML =
                    '<span class="analytics-search-result-icon"><i class="' + item.icon + '"></i></span>' +
                    '<span class="analytics-search-result-copy">' +
                    '<strong>' + item.title + '</strong>' +
                    '<small>' + item.description + '</small>' +
                    '</span>';
                button.addEventListener('click', function () {
                    activateSearchItem(item);
                });
                dashboardSearchResults.appendChild(button);
            });

            dashboardSearchResults.classList.remove('hidden');
            dashboardSearchInput.setAttribute('aria-expanded', 'true');
        }

        dashboardSearchInput.addEventListener('input', renderSearchResults);
        dashboardSearchInput.addEventListener('focus', renderSearchResults);
        dashboardSearchInput.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closeSearchResults();
                return;
            }
            if (event.key !== 'Enter') return;
            event.preventDefault();
            activateSearchItem(getMatches(normalize(dashboardSearchInput.value))[0]);
        });

        document.addEventListener('click', function (event) {
            if (!dashboardSearchInput.contains(event.target) && dashboardSearchResults && !dashboardSearchResults.contains(event.target)) {
                closeSearchResults();
            }
        });
    }

    function wireChart(options) {
        var chartWrap = document.querySelector(options.wrapSelector);
        var tooltip = document.getElementById(options.tooltipId);
        if (!chartWrap || !tooltip) return;

        var hitboxes = chartWrap.querySelectorAll(options.hitboxSelector);
        var focusLines = chartWrap.querySelectorAll(options.focusLineSelector);
        var focusDots = options.focusDotSelector ? chartWrap.querySelectorAll(options.focusDotSelector) : [];
        var focusBars = options.focusBarSelector ? chartWrap.querySelectorAll(options.focusBarSelector) : [];

        function clearActive() {
            focusLines.forEach(function (line) { line.classList.remove('active'); });
            focusDots.forEach(function (dot) { dot.classList.remove('active'); });
            focusBars.forEach(function (bar) { bar.classList.remove('active'); });
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

            if (focusLines[index]) focusLines[index].classList.add('active');
            if (focusDots[index]) focusDots[index].classList.add('active');
            if (focusBars[index]) focusBars[index].classList.add('active');

            options.populate(hitbox);
            tooltip.classList.remove('hidden');
            if (event) positionTooltip(event.clientX, event.clientY);
        }

        hitboxes.forEach(function (hitbox) {
            hitbox.addEventListener('mouseenter', function (event) { showTooltip(hitbox, event); });
            hitbox.addEventListener('mousemove', function (event) { showTooltip(hitbox, event); });
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
    }

    wireChart({
        wrapSelector: '.analytics-chart-wrap-large',
        tooltipId: 'dailyVolumeChartTooltip',
        hitboxSelector: '.analytics-chart-hitbox-volume',
        focusLineSelector: '.analytics-chart-focus-line-volume',
        focusDotSelector: '.analytics-chart-focus-dot-volume',
        populate: function (hitbox) {
            document.getElementById('dailyVolumeTooltipDate').textContent = hitbox.getAttribute('data-label') || '-';
            document.getElementById('dailyVolumeTooltipValue').textContent = hitbox.getAttribute('data-value') || '0';
        }
    });

    wireChart({
        wrapSelector: '.analytics-chart-wrap.compact',
        tooltipId: 'clinicWaitChartTooltip',
        hitboxSelector: '.analytics-chart-hitbox-bar',
        focusLineSelector: '.analytics-chart-focus-line-bar',
        focusBarSelector: '.analytics-chart-bar',
        populate: function (hitbox) {
            document.getElementById('clinicWaitTooltipLabel').textContent = hitbox.getAttribute('data-label') || '-';
            document.getElementById('clinicWaitTooltipValue').textContent = hitbox.getAttribute('data-value') || '0';
        }
    });
})();
</script>
</body>
</html>
