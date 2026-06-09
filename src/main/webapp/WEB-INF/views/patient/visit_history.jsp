<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visit History - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-clipboard-list"></i> Visit History</h1>
        <p>Your past clinic visits and AI-generated summaries</p>
    </div>

    <c:if test="${param.rated == '1'}">
        <div class="alert alert-success"><i class="fi fi-ss-star"></i> Thank you! Your rating has been saved.</div>
    </c:if>
    <c:if test="${param.error == '1'}">
        <div class="alert alert-danger">Sorry, we couldn't save your rating. Please try again.</div>
    </c:if>

    <c:choose>
        <c:when test="${empty visits}">
            <div class="card">
                <div class="card-body text-center" style="padding: 3rem;">
                    <div style="font-size: 3rem; margin-bottom: 1rem;"><i class="fi fi-ss-clipboard-list"></i></div>
                    <h3>No visit history yet</h3>
                    <p class="text-muted">Your completed clinic visits will appear here.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="visit" items="${visits}">
                <div class="card mb-2">
                    <div class="card-body">
                        <div class="d-flex justify-between align-center mb-2">
                            <div>
                                <strong>${fn:escapeXml(visit.clinicName)}</strong>
                                <span class="text-muted" style="margin-left: 0.5rem;">· ${visit.visitDate}</span>
                            </div>
                            <span class="text-muted" style="font-size:0.82rem;">Wait: ${visit.actualWaitMins} min</span>
                        </div>
                        <c:if test="${not empty visit.outcome}">
                            <p style="font-size:0.9rem; color:#555;"><strong>Outcome:</strong> ${fn:escapeXml(visit.outcome)}</p>
                        </c:if>
                        <c:if test="${not empty visit.aiSummary}">
                            <div style="background: linear-gradient(135deg, #667eea15, #764ba215); border-radius: 8px; padding: 0.75rem; margin-top: 0.5rem; border-left: 3px solid #667eea;">
                                <div style="font-size:0.75rem; color: #667eea; font-weight:700; margin-bottom:0.25rem;"><i class="fi fi-ss-robot"></i> AI Summary</div>
                                <p style="font-size:0.88rem; color:#555; margin:0;">${fn:escapeXml(visit.aiSummary)}</p>
                            </div>
                        </c:if>

                        <%-- Clinic rating: show given stars, or an interactive form to rate this completed visit --%>
                        <div style="margin-top: 0.75rem; padding-top: 0.75rem; border-top: 1px solid #eee;">
                            <c:choose>
                                <c:when test="${visit.userRating > 0}">
                                    <div style="font-size:0.85rem; color:#555;">
                                        <strong>Your rating:</strong>
                                        <span style="font-size:1rem; letter-spacing:2px;">
                                            <c:forEach begin="1" end="5" var="i"><i class="fi fi-ss-star" style="color:${i <= visit.userRating ? '#f5a623' : '#ccc'}"></i></c:forEach>
                                        </span>
                                    </div>
                                </c:when>
                                <c:when test="${visit.apptId > 0}">
                                    <form method="post" action="${pageContext.request.contextPath}/patient/history">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="hidden" name="apptId" value="${visit.apptId}">
                                        <input type="hidden" name="stars" id="stars-${visit.visitId}" value="0">
                                        <div style="font-size:0.85rem; color:#555; margin-bottom:0.35rem;"><strong>Rate this clinic:</strong></div>
                                        <div class="star-input" data-target="stars-${visit.visitId}" style="font-size:1.4rem; cursor:pointer; letter-spacing:3px; display:inline-block;">
                                            <span data-val="1"><i class="fi fi-ss-star"></i></span><span data-val="2"><i class="fi fi-ss-star"></i></span><span data-val="3"><i class="fi fi-ss-star"></i></span><span data-val="4"><i class="fi fi-ss-star"></i></span><span data-val="5"><i class="fi fi-ss-star"></i></span>
                                        </div>
                                        <div style="display:flex; gap:0.5rem; margin-top:0.5rem;">
                                            <input type="text" name="comment" class="form-control" placeholder="Optional comment..." style="font-size:0.85rem;">
                                            <button type="submit" class="btn btn-primary btn-sm">Submit</button>
                                        </div>
                                    </form>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>

<script>
(function () {
    function paint(widget, value) {
        var spans = widget.querySelectorAll('span');
        for (var i = 0; i < spans.length; i++) {
            spans[i].style.color = (i < value) ? '#f5a623' : '#ccc';
        }
    }
    document.querySelectorAll('.star-input').forEach(function (widget) {
        var hidden = document.getElementById(widget.getAttribute('data-target'));
        widget.querySelectorAll('span').forEach(function (star) {
            var val = parseInt(star.getAttribute('data-val'), 10);
            star.addEventListener('mouseover', function () { paint(widget, val); });
            star.addEventListener('click', function () {
                hidden.value = val;
                paint(widget, val);
            });
        });
        widget.addEventListener('mouseleave', function () {
            paint(widget, parseInt(hidden.value, 10) || 0);
        });
        paint(widget, parseInt(hidden.value, 10) || 0); // initialise unselected stars to grey
    });
})();
</script>
</body>
</html>
