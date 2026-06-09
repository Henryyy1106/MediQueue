<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Find a Clinic - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-hospital"></i> Find a Clinic</h1>
        <p>Search for nearby clinics and get AI-powered recommendations</p>
    </div>

    <!-- AI Search Form -->
    <div class="card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/patient/clinics">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Search by District / Clinic Name</label>
                        <input type="text" name="search" class="form-control" placeholder="e.g. Petaling Jaya, Subang..." value="${fn:escapeXml(param.search)}">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Describe Your Symptoms (AI Recommendation)</label>
                        <input type="text" name="symptoms" class="form-control" placeholder="e.g. fever, sore throat..." value="${fn:escapeXml(symptoms)}">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary"><i class="fi fi-ss-search"></i> Search & Get AI Recommendation</button>
            </form>
        </div>
    </div>

    <!-- AI Recommendation -->
    <c:if test="${not empty aiRecommendation}">
        <div class="ai-card mb-3">
            <h4><i class="fi fi-ss-robot"></i> AI Recommendation</h4>
            <p>${aiRecommendation.message}</p>
            <c:if test="${aiRecommendation.recommendEr}">
                <div style="background: rgba(255,255,255,0.2); border-radius: 8px; padding: 0.75rem; margin-top: 0.5rem;">
                    <i class="fi fi-ss-light-emergency-on"></i> <strong>Emergency Alert:</strong> Your symptoms may require immediate emergency care. Please proceed to the nearest A&E department.
                </div>
            </c:if>
            <div style="margin-top: 0.75rem; font-size: 0.8rem; opacity: 0.8;">
                <i class="fi fi-ss-triangle-warning"></i> AI guidance only. Not a medical diagnosis. Consult a qualified doctor.
                <c:if test="${aiRecommendation.fallback}"> (Running in fallback mode)</c:if>
            </div>
        </div>
    </c:if>

    <!-- Clinic Grid -->
    <c:choose>
        <c:when test="${empty clinics}">
            <div class="card">
                <div class="card-body text-center" style="padding: 3rem;">
                    <div style="font-size: 3rem; margin-bottom: 1rem;"><i class="fi fi-ss-hospital"></i></div>
                    <p>No clinics found. Try a different search.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="clinic-grid">
                <c:forEach var="clinic" items="${clinics}">
                    <div class="clinic-card ${clinic.clinicId == aiRecommendation.recommendedClinicId ? 'recommended' : ''}">
                        <c:if test="${clinic.clinicId == aiRecommendation.recommendedClinicId}">
                            <div style="font-size: 0.78rem; color: var(--success); font-weight: 700; margin-bottom: 0.5rem;"><i class="fi fi-ss-star"></i> AI RECOMMENDED</div>
                        </c:if>
                        <div class="clinic-name">${fn:escapeXml(clinic.name)}</div>
                        <div style="margin: 0.25rem 0; font-size: 0.85rem;">
                            <span style="letter-spacing:1px;"><c:forEach begin="1" end="5" var="s"><i class="fi fi-ss-star" style="color:${s <= clinic.rating ? '#f5a623' : '#ccc'}"></i></c:forEach></span>
                            <span class="text-muted" style="margin-left:0.35rem;">${clinic.ratingLabel}</span>
                        </div>
                        <div class="clinic-address"><i class="fi fi-ss-marker"></i> ${fn:escapeXml(clinic.address)}</div>
                        <div class="clinic-meta">
                            <div class="clinic-meta-item"><i class="fi fi-ss-stopwatch"></i> <span class="badge ${clinic.waitBadgeClass}">${clinic.estimatedWaitMins} min wait</span></div>
                            <div class="clinic-meta-item"><i class="fi fi-ss-users-alt"></i> ${clinic.currentQueueCount} waiting</div>
                            <div class="clinic-meta-item"><i class="fi fi-ss-phone-call"></i> ${fn:escapeXml(clinic.phone)}</div>
                        </div>
                        <div class="clinic-meta" style="margin-top: 0.75rem;">
                            <div class="clinic-meta-item"><i class="fi fi-ss-clock"></i> ${clinic.operatingHours}</div>
                        </div>
                        <div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
                            <a href="${pageContext.request.contextPath}/patient/appointments/book?clinicId=${clinic.clinicId}" class="btn btn-primary btn-sm"><i class="fi fi-ss-calendar"></i> Book Here</a>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
