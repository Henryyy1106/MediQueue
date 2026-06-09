<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/patient_nav.jsp"/>

<div class="page-container" style="max-width: 700px;">
    <div class="page-header"><h1><i class="fi fi-ss-settings"></i> My Profile</h1></div>

    <c:if test="${not empty success}"><div class="alert alert-success"><i class="fi fi-ss-check"></i> ${success}</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div></c:if>

    <div class="card mb-3">
        <div class="card-header"><h5>Personal Information</h5></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/patient/profile">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="updateProfile">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Full Name *</label>
                        <input type="text" name="name" class="form-control" value="${fn:escapeXml(user.name)}" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phone</label>
                        <input type="tel" name="phone" class="form-control" value="${fn:escapeXml(user.phone)}">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" value="${fn:escapeXml(user.email)}" disabled style="background:#f5f5f5;">
                    <div class="form-hint">Email cannot be changed</div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">IC Number</label>
                        <input type="text" name="icNumber" class="form-control" value="${fn:escapeXml(user.icNumber)}">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Date of Birth</label>
                        <input type="date" name="dateOfBirth" class="form-control" value="${fn:escapeXml(user.dateOfBirth)}">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-control">
                        <option value="">Select...</option>
                        <option value="male" ${user.gender == 'male' ? 'selected' : ''}>Male</option>
                        <option value="female" ${user.gender == 'female' ? 'selected' : ''}>Female</option>
                        <option value="other" ${user.gender == 'other' ? 'selected' : ''}>Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea name="address" class="form-control" rows="2">${fn:escapeXml(user.address)}</textarea>
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h5>Change Password</h5></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/patient/profile">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="changePassword">
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <input type="password" name="currentPassword" class="form-control" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">New Password</label>
                        <input type="password" name="newPassword" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" name="confirmPassword" class="form-control" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-warning">Update Password</button>
            </form>
        </div>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
