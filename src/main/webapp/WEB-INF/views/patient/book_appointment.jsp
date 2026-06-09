<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container" style="max-width: 700px;">
    <div class="page-header">
        <h1><i class="fi fi-ss-calendar"></i> Book Appointment</h1>
        <p>Select your clinic, date, and time. AI will assess urgency.</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/patient/appointments/book" id="bookingForm">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                <div class="form-group">
                    <label class="form-label">Select Clinic *</label>
                    <select name="clinicId" class="form-control" required id="clinicSelect">
                        <option value="">-- Choose a clinic --</option>
                        <c:forEach var="clinic" items="${clinics}">
                            <option value="${clinic.clinicId}"
                                ${clinic.clinicId == param.clinicId || clinic.clinicId == preClinicId ? 'selected' : ''}>
                                ${fn:escapeXml(clinic.name)} — ${fn:escapeXml(clinic.district)} (Est. ${clinic.estimatedWaitMins} min wait)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Appointment Date *</label>
                        <input type="date" name="apptDate" class="form-control" required
                               min="${pageContext.request.contextPath}" id="apptDate">
                        <div class="form-hint">Select today or a future date</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Time Slot *</label>
                        <select name="timeSlot" class="form-control" required>
                            <option value="">-- Select time --</option>
                            <option value="08:00">08:00 AM</option>
                            <option value="08:30">08:30 AM</option>
                            <option value="09:00">09:00 AM</option>
                            <option value="09:30">09:30 AM</option>
                            <option value="10:00">10:00 AM</option>
                            <option value="10:30">10:30 AM</option>
                            <option value="11:00">11:00 AM</option>
                            <option value="11:30">11:30 AM</option>
                            <option value="14:00">02:00 PM</option>
                            <option value="14:30">02:30 PM</option>
                            <option value="15:00">03:00 PM</option>
                            <option value="15:30">03:30 PM</option>
                            <option value="16:00">04:00 PM</option>
                            <option value="16:30">04:30 PM</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Reason for Visit *</label>
                    <input type="text" name="reason" class="form-control" placeholder="e.g. General checkup, fever, follow-up..." required>
                </div>

                <div class="form-group">
                    <label class="form-label">Describe Your Symptoms</label>
                    <textarea name="symptoms" class="form-control" rows="3"
                        placeholder="Describe your symptoms here. The AI Helper will assess urgency and provide guidance..."
                        id="symptomsInput"></textarea>
                    <div class="form-hint">Optional — helps our AI assess your case priority</div>
                </div>

                <!-- AI Urgency Preview (populated via AJAX) -->
                <div id="aiUrgencyPreview" class="hidden">
                    <div class="card" style="background: #f8f9fa; margin-bottom: 1rem;">
                        <div class="card-body">
                            <div class="d-flex align-center gap-1 mb-1">
                                <span><i class="fi fi-ss-robot"></i> <strong>AI Assessment</strong></span>
                                <span id="urgencyBadge" class="badge"></span>
                            </div>
                            <p id="urgencyAdvice" style="font-size: 0.9rem; color: #555;"></p>
                            <p id="erWarning" class="hidden" style="color: #dc3545; font-weight: 600; margin-top: 0.5rem;">
                                <i class="fi fi-ss-light-emergency-on"></i> Your symptoms may require emergency care. Please go to the nearest A&E immediately.
                            </p>
                            <p style="font-size: 0.75rem; color: #aaa; margin-top: 0.5rem;">
                                This is AI guidance only. Not a medical diagnosis.
                            </p>
                        </div>
                    </div>
                </div>

                <div style="display: flex; gap: 1rem;">
                    <button type="submit" class="btn btn-primary btn-lg"><i class="fi fi-ss-check"></i> Confirm Booking</button>
                    <a href="${pageContext.request.contextPath}/patient/appointments" class="btn btn-outline btn-lg">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Set min date to today
document.getElementById('apptDate').min = new Date().toISOString().split('T')[0];

// AI urgency check on symptoms input (debounced)
let aiTimer;
document.getElementById('symptomsInput').addEventListener('input', function() {
    clearTimeout(aiTimer);
    const symptoms = this.value.trim();
    if (symptoms.length < 10) {
        document.getElementById('aiUrgencyPreview').classList.add('hidden');
        return;
    }
    aiTimer = setTimeout(() => checkUrgency(symptoms), 800);
});

async function checkUrgency(symptoms) {
    try {
        const formData = new FormData();
        formData.append('symptoms', symptoms);
        const resp = await fetch('${pageContext.request.contextPath}/ai/classify', {method:'POST', body: formData});
        const data = await resp.json();

        const preview = document.getElementById('aiUrgencyPreview');
        const badge = document.getElementById('urgencyBadge');
        const advice = document.getElementById('urgencyAdvice');
        const erWarn = document.getElementById('erWarning');

        badge.textContent = data.urgency ? data.urgency.toUpperCase() : 'ROUTINE';
        badge.className = 'badge ' + (data.urgency === 'emergency' ? 'badge-danger' : data.urgency === 'urgent' ? 'badge-warning' : 'badge-success');
        advice.textContent = data.advice || '';
        erWarn.classList.toggle('hidden', !data.recommend_er);
        preview.classList.remove('hidden');
    } catch(e) {
        console.log('AI check failed:', e);
    }
}
</script>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
