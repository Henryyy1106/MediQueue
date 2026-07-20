<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Moderation - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=10">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-calendar"></i> Appointment Moderation</h1>
        <p>Review, filter, and safely update patient bookings.</p>
    </div>

    <div class="users-workspace">
        <c:if test="${param.updated == '1'}"><div class="alert alert-success">Appointment updated successfully.</div></c:if>
        <c:if test="${not empty param.error}"><div class="alert alert-danger">${fn:escapeXml(fn:replace(param.error, '_', ' '))}</div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger">${fn:escapeXml(error)}</div></c:if>

        <section class="card users-filter-card">
            <div class="card-body">
                <div class="users-filter-form">
                    <div class="users-filter-grid users-filter-grid-compact">
                        <div class="form-group mb-0">
                            <label class="form-label">Search</label>
                            <div class="users-search-field">
                                <i class="fi fi-ss-search"></i>
                                <input
                                    type="text"
                                    id="appointmentsSearchInput"
                                    class="form-control"
                                    value="${fn:escapeXml(filterPatient)}"
                                    placeholder="Search patient, clinic, reason, or appointment ID"
                                    autocomplete="off">
                            </div>
                        </div>
                        <div class="users-filter-actions">
                            <div class="users-filter-popover-wrap">
                                <button type="button" class="btn btn-outline" id="openAppointmentFilters">
                                    <i class="fi fi-ss-settings-sliders"></i> Filter
                                </button>
                                <div class="users-filter-popover" id="appointmentFilterPopover" aria-hidden="true">
                                    <div class="users-filter-popover-header">
                                        <strong>Filters</strong>
                                        <button type="button" class="users-filter-close" id="closeAppointmentFilters" aria-label="Close appointment filters">
                                            <i class="fi fi-ss-cross-small"></i>
                                        </button>
                                    </div>
                                    <div class="users-filter-popover-body">
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Status</span>
                                            <div class="users-filter-chip-row" id="appointmentStatusOptions">
                                                <button type="button" class="users-filter-chip ${empty filterStatus ? 'active' : ''}" data-appointment-status="">All statuses</button>
                                                <button type="button" class="users-filter-chip ${filterStatus == 'pending' ? 'active' : ''}" data-appointment-status="pending">Pending</button>
                                                <button type="button" class="users-filter-chip ${filterStatus == 'confirmed' ? 'active' : ''}" data-appointment-status="confirmed">Confirmed</button>
                                                <button type="button" class="users-filter-chip ${filterStatus == 'cancelled' ? 'active' : ''}" data-appointment-status="cancelled">Cancelled</button>
                                                <button type="button" class="users-filter-chip ${filterStatus == 'completed' ? 'active' : ''}" data-appointment-status="completed">Completed</button>
                                            </div>
                                        </div>
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Urgency</span>
                                            <div class="users-filter-chip-row" id="appointmentUrgencyOptions">
                                                <button type="button" class="users-filter-chip ${empty filterUrgency ? 'active' : ''}" data-appointment-urgency="">All urgency levels</button>
                                                <button type="button" class="users-filter-chip ${filterUrgency == 'routine' ? 'active' : ''}" data-appointment-urgency="routine">Routine</button>
                                                <button type="button" class="users-filter-chip ${filterUrgency == 'urgent' ? 'active' : ''}" data-appointment-urgency="urgent">Urgent</button>
                                                <button type="button" class="users-filter-chip ${filterUrgency == 'emergency' ? 'active' : ''}" data-appointment-urgency="emergency">Emergency</button>
                                            </div>
                                        </div>
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Clinic</span>
                                            <select id="appointmentClinicFilter" class="form-control">
                                                <option value="">All clinics</option>
                                                <c:forEach var="clinic" items="${clinics}">
                                                    <option value="${clinic.clinicId}" ${clinic.clinicId == filterClinicId ? 'selected' : ''}>${fn:escapeXml(clinic.name)}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Appointment Date</span>
                                            <input type="date" id="appointmentDateFilter" class="form-control" value="${filterApptDate}">
                                        </div>
                                    </div>
                                    <div class="users-filter-popover-footer">
                                        <button type="button" class="btn btn-outline btn-sm" id="clearAppointmentFilters">Clear</button>
                                        <button type="button" class="btn btn-primary btn-sm" id="applyAppointmentFilters">Apply</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="card users-table-card">
            <div class="card-header users-table-header">
                <div class="users-table-title">
                    <h5>Appointments</h5>
                    <div class="users-table-subtitle" id="appointmentsTableSubtitle">Showing appointments for the current filters.</div>
                </div>
                <span class="badge badge-primary" id="appointmentsCountBadge">${empty appointments ? 0 : appointments.size()} records</span>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty appointments}">
                        <div class="users-empty">
                            <div class="compact-empty-icon"><i class="fi fi-ss-calendar"></i></div>
                            <div class="section-heading">No appointments match the current filters</div>
                            <div class="section-copy">Adjust your search criteria or check again later.</div>
                        </div>
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
                                <tbody id="appointmentsTableBody">
                                    <c:forEach var="appt" items="${appointments}">
                                        <tr
                                            data-appointment-row
                                            data-appt-id="${appt.apptId}"
                                            data-user-id="${appt.userId}"
                                            data-patient-name="${fn:escapeXml(appt.patientName)}"
                                            data-clinic-id="${appt.clinicId}"
                                            data-clinic-name="${fn:escapeXml(appt.clinicName)}"
                                            data-appt-date="${appt.apptDate}"
                                            data-time-slot="${fn:escapeXml(appt.timeSlot)}"
                                            data-status="${fn:escapeXml(appt.status)}"
                                            data-urgency="${fn:escapeXml(appt.urgencyLevel)}"
                                            data-reason="${empty appt.reason ? '' : fn:escapeXml(appt.reason)}"
                                            data-symptoms="${empty appt.symptoms ? '' : fn:escapeXml(appt.symptoms)}"
                                            data-admin-notes="${empty appt.adminNotes ? '' : fn:escapeXml(appt.adminNotes)}"
                                            data-ai-notes="${empty appt.aiNotes ? '' : fn:escapeXml(appt.aiNotes)}"
                                            data-search="#${appt.apptId} ${fn:toLowerCase(fn:escapeXml(appt.patientName))} ${fn:toLowerCase(fn:escapeXml(appt.clinicName))} ${fn:toLowerCase(empty appt.reason ? '' : fn:escapeXml(appt.reason))}"
                                            data-filter-status="${fn:toLowerCase(fn:escapeXml(appt.status))}"
                                            data-filter-urgency="${fn:toLowerCase(fn:escapeXml(appt.urgencyLevel))}"
                                            data-filter-clinic-id="${appt.clinicId}"
                                            data-filter-date="${appt.apptDate}">
                                            <td>#${appt.apptId}</td>
                                            <td>${fn:escapeXml(appt.patientName)}</td>
                                            <td>${fn:escapeXml(appt.clinicName)}</td>
                                            <td>${appt.apptDate}</td>
                                            <td>${appt.timeSlot}</td>
                                            <td><span class="badge ${appt.statusBadgeClass}">${fn:escapeXml(appt.status)}</span></td>
                                            <td><span class="badge ${appt.urgencyBadgeClass}">${fn:escapeXml(appt.urgencyLevel)}</span></td>
                                            <td><button type="button" class="btn btn-outline btn-sm" data-open-moderate-appointment>Moderate</button></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="users-empty users-empty-inline hidden" id="appointmentsLiveEmptyState">
                            <div class="compact-empty-icon"><i class="fi fi-ss-search"></i></div>
                            <div class="section-heading">No appointments match your search</div>
                            <div class="section-copy">Try a different patient, clinic, date, status, or urgency filter.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </div>
</div>

<c:if test="${not empty selectedAppointment}">
    <div
        id="selectedAppointmentData"
        class="hidden"
        data-appt-id="${selectedAppointment.apptId}"
        data-clinic-id="${selectedAppointment.clinicId}"
        data-clinic-name="${fn:escapeXml(selectedAppointment.clinicName)}"
        data-patient-name="${fn:escapeXml(selectedAppointment.patientName)}"
        data-appt-date="${selectedAppointment.apptDate}"
        data-time-slot="${fn:escapeXml(selectedAppointment.timeSlot)}"
        data-status="${fn:escapeXml(selectedAppointment.status)}"
        data-urgency="${fn:escapeXml(selectedAppointment.urgencyLevel)}"
        data-reason="${empty selectedAppointment.reason ? '' : fn:escapeXml(selectedAppointment.reason)}"
        data-symptoms="${empty selectedAppointment.symptoms ? '' : fn:escapeXml(selectedAppointment.symptoms)}"
        data-admin-notes="${empty selectedAppointment.adminNotes ? '' : fn:escapeXml(selectedAppointment.adminNotes)}"
        data-ai-notes="${empty selectedAppointment.aiNotes ? '' : fn:escapeXml(selectedAppointment.aiNotes)}"></div>
</c:if>

<div class="users-modal" id="moderateAppointmentModal" aria-hidden="true" data-auto-open="${not empty selectedAppointment}">
    <div class="users-modal-backdrop" data-close-appointment-modal></div>
    <div class="users-modal-panel users-modal-panel-edit" role="dialog" aria-modal="true" aria-labelledby="moderateAppointmentModalTitle">
        <div class="users-modal-header">
            <div>
                <h4 id="moderateAppointmentModalTitle">Moderate Appointment</h4>
                <p>Review booking details and update the appointment safely.</p>
            </div>
            <button type="button" class="users-modal-close" data-close-appointment-modal aria-label="Close moderation form"><i class="fi fi-ss-cross-small"></i></button>
        </div>
        <div class="users-modal-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/appointments" id="moderateAppointmentForm" class="users-stacked-form">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="apptId" id="moderateApptId">
                <div class="users-form-intro">
                    <h5 id="moderateAppointmentIntro">Update Appointment Details</h5>
                    <p id="moderateAppointmentMeta">Review the booking information and apply changes below.</p>
                </div>
                <div class="form-group">
                    <label class="form-label">Clinic *</label>
                    <select name="clinicId" id="moderateClinicId" class="form-control" required>
                        <c:forEach var="clinic" items="${clinics}">
                            <option value="${clinic.clinicId}">${fn:escapeXml(clinic.name)}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Date *</label>
                    <input type="date" name="apptDate" id="moderateApptDate" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Time Slot *</label>
                    <select name="timeSlot" id="moderateTimeSlot" class="form-control" required>
                        <option value="08:00">08:00</option>
                        <option value="08:30">08:30</option>
                        <option value="09:00">09:00</option>
                        <option value="09:30">09:30</option>
                        <option value="10:00">10:00</option>
                        <option value="10:30">10:30</option>
                        <option value="11:00">11:00</option>
                        <option value="11:30">11:30</option>
                        <option value="14:00">14:00</option>
                        <option value="14:30">14:30</option>
                        <option value="15:00">15:00</option>
                        <option value="15:30">15:30</option>
                        <option value="16:00">16:00</option>
                        <option value="16:30">16:30</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Status *</label>
                    <select name="status" id="moderateStatus" class="form-control" required>
                        <option value="pending">Pending</option>
                        <option value="confirmed">Confirmed</option>
                        <option value="cancelled">Cancelled</option>
                        <option value="completed">Completed</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Urgency *</label>
                    <select name="urgencyLevel" id="moderateUrgencyLevel" class="form-control" required>
                        <option value="routine">Routine</option>
                        <option value="urgent">Urgent</option>
                        <option value="emergency">Emergency</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Reason *</label>
                    <input type="text" name="reason" id="moderateReason" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Symptoms</label>
                    <textarea name="symptoms" id="moderateSymptoms" class="form-control users-stacked-textarea" rows="4"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Internal Admin Notes</label>
                    <textarea name="adminNotes" id="moderateAdminNotes" class="form-control users-stacked-textarea" rows="4"></textarea>
                </div>
                <div class="ai-card mb-2 hidden" id="moderateAiNotesCard">
                    <h4><i class="fi fi-ss-robot"></i> Existing AI Notes</h4>
                    <p id="moderateAiNotesText"></p>
                </div>
                <div class="users-stacked-actions">
                    <button type="button" class="btn btn-outline" data-close-appointment-modal>Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Appointment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
<script>
(function () {
    var searchInput = document.getElementById('appointmentsSearchInput');
    var filterBtn = document.getElementById('openAppointmentFilters');
    var closeFilterBtn = document.getElementById('closeAppointmentFilters');
    var applyFilterBtn = document.getElementById('applyAppointmentFilters');
    var clearFilterBtn = document.getElementById('clearAppointmentFilters');
    var filterPopover = document.getElementById('appointmentFilterPopover');
    var statusOptions = document.querySelectorAll('[data-appointment-status]');
    var urgencyOptions = document.querySelectorAll('[data-appointment-urgency]');
    var clinicFilter = document.getElementById('appointmentClinicFilter');
    var dateFilter = document.getElementById('appointmentDateFilter');
    var rows = document.querySelectorAll('[data-appointment-row]');
    var countBadge = document.getElementById('appointmentsCountBadge');
    var subtitle = document.getElementById('appointmentsTableSubtitle');
    var liveEmptyState = document.getElementById('appointmentsLiveEmptyState');
    var moderateButtons = document.querySelectorAll('[data-open-moderate-appointment]');
    var moderateModal = document.getElementById('moderateAppointmentModal');
    var moderateCloseBtns = document.querySelectorAll('[data-close-appointment-modal]');
    var activeStatus = '${fn:escapeXml(filterStatus)}' || '';
    var activeUrgency = '${fn:escapeXml(filterUrgency)}' || '';

    var moderateApptId = document.getElementById('moderateApptId');
    var moderateClinicId = document.getElementById('moderateClinicId');
    var moderateApptDate = document.getElementById('moderateApptDate');
    var moderateTimeSlot = document.getElementById('moderateTimeSlot');
    var moderateStatus = document.getElementById('moderateStatus');
    var moderateUrgencyLevel = document.getElementById('moderateUrgencyLevel');
    var moderateReason = document.getElementById('moderateReason');
    var moderateSymptoms = document.getElementById('moderateSymptoms');
    var moderateAdminNotes = document.getElementById('moderateAdminNotes');
    var moderateAiNotesCard = document.getElementById('moderateAiNotesCard');
    var moderateAiNotesText = document.getElementById('moderateAiNotesText');
    var moderateAppointmentTitle = document.getElementById('moderateAppointmentModalTitle');
    var moderateAppointmentIntro = document.getElementById('moderateAppointmentIntro');
    var moderateAppointmentMeta = document.getElementById('moderateAppointmentMeta');
    var shouldAutoOpen = moderateModal && moderateModal.getAttribute('data-auto-open') === 'true';
    var selectedAppointmentData = document.getElementById('selectedAppointmentData');

    function setFilterPopover(open) {
        if (!filterPopover) return;
        filterPopover.classList.toggle('open', open);
        filterPopover.setAttribute('aria-hidden', open ? 'false' : 'true');
    }

    function setActiveStatus(value) {
        activeStatus = value || '';
        statusOptions.forEach(function (option) {
            option.classList.toggle('active', option.getAttribute('data-appointment-status') === activeStatus);
        });
    }

    function setActiveUrgency(value) {
        activeUrgency = value || '';
        urgencyOptions.forEach(function (option) {
            option.classList.toggle('active', option.getAttribute('data-appointment-urgency') === activeUrgency);
        });
    }

    function updateAppointmentsTable() {
        var query = (searchInput ? searchInput.value : '').toLowerCase().trim();
        var activeClinic = clinicFilter ? clinicFilter.value : '';
        var activeDate = dateFilter ? dateFilter.value : '';
        var visibleCount = 0;

        rows.forEach(function (row) {
            var rowSearch = row.getAttribute('data-search') || '';
            var rowStatus = row.getAttribute('data-filter-status') || '';
            var rowUrgency = row.getAttribute('data-filter-urgency') || '';
            var rowClinic = row.getAttribute('data-filter-clinic-id') || '';
            var rowDate = row.getAttribute('data-filter-date') || '';
            var matchesSearch = !query || rowSearch.indexOf(query) !== -1;
            var matchesStatus = !activeStatus || rowStatus === activeStatus;
            var matchesUrgency = !activeUrgency || rowUrgency === activeUrgency;
            var matchesClinic = !activeClinic || rowClinic === activeClinic;
            var matchesDate = !activeDate || rowDate === activeDate;
            var show = matchesSearch && matchesStatus && matchesUrgency && matchesClinic && matchesDate;
            row.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (countBadge) {
            countBadge.textContent = visibleCount + (visibleCount === 1 ? ' record' : ' records');
        }

        if (subtitle) {
            if (query) {
                subtitle.textContent = 'Showing appointments matching "' + query + '" with the active filters.';
            } else if (activeStatus || activeUrgency || activeClinic || activeDate) {
                subtitle.textContent = 'Showing appointments for the active filters.';
            } else {
                subtitle.textContent = 'Showing appointments for the current filters.';
            }
        }

        if (liveEmptyState) {
            liveEmptyState.classList.toggle('hidden', visibleCount !== 0);
        }
    }

    function setModerateModal(open) {
        if (!moderateModal) return;
        moderateModal.classList.toggle('open', open);
        moderateModal.setAttribute('aria-hidden', open ? 'false' : 'true');
        document.body.style.overflow = open ? 'hidden' : '';
    }

    function populateModerationForm(payload) {
        if (!payload) return;
        if (moderateApptId) moderateApptId.value = payload.apptId || '';
        if (moderateClinicId) moderateClinicId.value = payload.clinicId || '';
        if (moderateApptDate) moderateApptDate.value = payload.apptDate || '';
        if (moderateTimeSlot) moderateTimeSlot.value = payload.timeSlot || '';
        if (moderateStatus) moderateStatus.value = (payload.status || '').toLowerCase();
        if (moderateUrgencyLevel) moderateUrgencyLevel.value = (payload.urgency || '').toLowerCase();
        if (moderateReason) moderateReason.value = payload.reason || '';
        if (moderateSymptoms) moderateSymptoms.value = payload.symptoms || '';
        if (moderateAdminNotes) moderateAdminNotes.value = payload.adminNotes || '';

        if (moderateAppointmentTitle) {
            moderateAppointmentTitle.textContent = 'Moderate Appointment #' + (payload.apptId || '');
        }
        if (moderateAppointmentIntro) {
            moderateAppointmentIntro.textContent = 'Appointment #' + (payload.apptId || '') + ' moderation';
        }
        if (moderateAppointmentMeta) {
            moderateAppointmentMeta.textContent = (payload.patientName || 'Patient') + ' at ' + (payload.clinicName || 'selected clinic') + '.';
        }

        if (moderateAiNotesCard && moderateAiNotesText) {
            var aiNotes = payload.aiNotes || '';
            moderateAiNotesText.textContent = aiNotes;
            moderateAiNotesCard.classList.toggle('hidden', !aiNotes);
        }
    }

    if (searchInput) {
        searchInput.addEventListener('input', updateAppointmentsTable);
    }

    statusOptions.forEach(function (option) {
        option.addEventListener('click', function () {
            setActiveStatus(option.getAttribute('data-appointment-status') || '');
        });
    });

    urgencyOptions.forEach(function (option) {
        option.addEventListener('click', function () {
            setActiveUrgency(option.getAttribute('data-appointment-urgency') || '');
        });
    });

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

    if (applyFilterBtn) {
        applyFilterBtn.addEventListener('click', function () {
            updateAppointmentsTable();
            setFilterPopover(false);
        });
    }

    if (clearFilterBtn) {
        clearFilterBtn.addEventListener('click', function () {
            setActiveStatus('');
            setActiveUrgency('');
            if (clinicFilter) clinicFilter.value = '';
            if (dateFilter) dateFilter.value = '';
            if (searchInput) searchInput.value = '';
            updateAppointmentsTable();
        });
    }

    moderateButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var row = button.closest('[data-appointment-row]');
            if (!row) return;
            populateModerationForm({
                apptId: row.getAttribute('data-appt-id') || '',
                clinicId: row.getAttribute('data-clinic-id') || '',
                clinicName: row.getAttribute('data-clinic-name') || '',
                patientName: row.getAttribute('data-patient-name') || '',
                apptDate: row.getAttribute('data-appt-date') || '',
                timeSlot: row.getAttribute('data-time-slot') || '',
                status: row.getAttribute('data-status') || '',
                urgency: row.getAttribute('data-urgency') || '',
                reason: row.getAttribute('data-reason') || '',
                symptoms: row.getAttribute('data-symptoms') || '',
                adminNotes: row.getAttribute('data-admin-notes') || '',
                aiNotes: row.getAttribute('data-ai-notes') || ''
            });
            setModerateModal(true);
        });
    });

    moderateCloseBtns.forEach(function (button) {
        button.addEventListener('click', function () {
            setModerateModal(false);
        });
    });

    document.addEventListener('click', function (event) {
        if (filterPopover && filterBtn && !filterPopover.contains(event.target) && !filterBtn.contains(event.target)) {
            setFilterPopover(false);
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            setFilterPopover(false);
            setModerateModal(false);
        }
    });

    setActiveStatus(activeStatus);
    setActiveUrgency(activeUrgency);
    updateAppointmentsTable();

    if (shouldAutoOpen) {
        populateModerationForm({
            apptId: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-appt-id') || '') : '',
            clinicId: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-clinic-id') || '') : '',
            clinicName: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-clinic-name') || '') : '',
            patientName: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-patient-name') || '') : '',
            apptDate: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-appt-date') || '') : '',
            timeSlot: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-time-slot') || '') : '',
            status: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-status') || '') : '',
            urgency: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-urgency') || '') : '',
            reason: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-reason') || '') : '',
            symptoms: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-symptoms') || '') : '',
            adminNotes: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-admin-notes') || '') : '',
            aiNotes: selectedAppointmentData ? (selectedAppointmentData.getAttribute('data-ai-notes') || '') : ''
        });
        setModerateModal(true);
    }
})();
</script>
</body>
</html>
