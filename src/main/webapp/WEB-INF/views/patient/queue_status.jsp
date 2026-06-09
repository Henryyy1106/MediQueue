<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Queue - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
    <meta http-equiv="refresh" content="30">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container" style="max-width: 600px;">
    <div class="page-header text-center">
        <h1><i class="fi fi-ss-list"></i> My Queue Status</h1>
        <p class="text-muted">Page refreshes every 30 seconds</p>
    </div>

    <c:choose>
        <c:when test="${not empty queue}">
            <div class="card mb-3">
                <div class="card-body queue-status-card">
                    <div style="font-size:0.85rem; color:#888; margin-bottom:0.5rem;">${fn:escapeXml(queue.clinicName)}</div>

                    <c:choose>
                        <c:when test="${queue.status == 'in_progress'}">
                            <div style="font-size: 3rem;"><i class="fi fi-ss-circle" style="color:#28a745"></i></div>
                            <div style="font-size: 1.5rem; font-weight: 800; color: var(--success); margin: 0.5rem 0;">IT'S YOUR TURN!</div>
                            <p>Please proceed to the consultation room.</p>
                        </c:when>
                        <c:when test="${queue.status == 'done'}">
                            <div style="font-size: 3rem;"><i class="fi fi-ss-check-circle"></i></div>
                            <div style="font-size: 1.5rem; font-weight: 800; color: var(--success); margin: 0.5rem 0;">Visit Completed</div>
                            <p class="text-muted">Your visit has been completed.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="queue-position">#${queue.position}</div>
                            <p style="font-size:1.1rem; color:#555;">Your queue position at ${fn:escapeXml(queue.clinicName)}</p>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${queue.status == 'waiting'}">
                        <div class="queue-progress" style="margin: 1.5rem 0;">
                            <div class="queue-progress-bar" style="width: ${queue.position <= 1 ? 90 : queue.position <= 3 ? 70 : queue.position <= 5 ? 50 : 20}%"></div>
                        </div>
                        <div style="display: flex; gap: 2rem; justify-content: center; font-size: 1.1rem;">
                            <div class="text-center">
                                <strong style="font-size:1.8rem; color: var(--primary);">${queue.waitLabel}</strong>
                                <div class="text-muted">Estimated Wait</div>
                            </div>
                            <div class="text-center">
                                <span class="badge ${queue.statusBadgeClass}" style="font-size:0.85rem; padding: 0.4rem 0.8rem;">${queue.status}</span>
                                <div class="text-muted mt-1">Status</div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <div class="card">
                <div class="card-body">
                    <p class="text-muted" style="font-size:0.85rem; text-align:center;">
                        Appointment: ${queue.timeSlot} · ${queue.queueDate}<br>
                        <c:if test="${not empty queue.urgencyLevel}">
                            Priority: <span class="badge badge-${queue.urgencyLevel == 'emergency' ? 'danger' : queue.urgencyLevel == 'urgent' ? 'warning' : 'success'}">${queue.urgencyLevel}</span>
                        </c:if>
                    </p>
                </div>
            </div>

            <%-- AI Pre-Visit Care Tips: safe self-care guidance while waiting --%>
            <c:if test="${queue.status != 'done' && not empty queue.symptoms}">
                <div class="card mt-3" id="careTipsCard" data-symptoms="<c:out value='${queue.symptoms}'/>">
                    <div class="card-body">
                        <h4 style="margin-top:0;"><i class="fi fi-ss-stethoscope"></i> While You Wait</h4>
                        <div id="careTipsBody">
                            <p class="text-muted" style="font-size:0.9rem;">Loading self-care tips…</p>
                        </div>
                    </div>
                </div>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="card">
                <div class="card-body text-center" style="padding: 3rem;">
                    <div style="font-size: 3rem; margin-bottom: 1rem;"><i class="fi fi-ss-list"></i></div>
                    <h3>No active queue</h3>
                    <p class="text-muted">You are not currently in any clinic queue for today.</p>
                    <a href="${pageContext.request.contextPath}/patient/appointments/book" class="btn btn-primary mt-2">Book an Appointment</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>

<script>
(function () {
    var card = document.getElementById('careTipsCard');
    if (!card) return;
    var body = document.getElementById('careTipsBody');
    var symptoms = card.getAttribute('data-symptoms') || '';
    var disclaimer = 'This is general guidance only — see the doctor at your appointment.';

    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    fetch('${pageContext.request.contextPath}/ai/caretips', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'symptoms=' + encodeURIComponent(symptoms)
    })
    .then(function (r) { return r.json(); })
    .then(function (data) {
        if (!data || !data.tips) {
            body.innerHTML = '<p class="text-muted" style="font-size:0.9rem;">Self-care tips are unavailable right now. Please wait for the doctor at your appointment.</p>';
            return;
        }
        // Split the standard safety disclaimer out so it keeps the existing muted styling.
        var tips = data.tips;
        var note = '';
        var idx = tips.indexOf(disclaimer);
        if (idx >= 0) {
            note = disclaimer;
            tips = tips.substring(0, idx).trim();
        }
        var html = '<p style="font-size:0.95rem; line-height:1.5;">' + escapeHtml(tips).replace(/\n+/g, '<br>') + '</p>';
        if (note) {
            html += '<p class="text-muted" style="font-size:0.8rem; font-style:italic; margin-top:0.5rem;"><i class="fi fi-ss-triangle-warning"></i> ' + escapeHtml(note) + '</p>';
        }
        body.innerHTML = html;
    })
    .catch(function () {
        body.innerHTML = '<p class="text-muted" style="font-size:0.9rem;">Self-care tips are unavailable right now. Please wait for the doctor at your appointment.</p>';
    });
})();
</script>
</body>
</html>
