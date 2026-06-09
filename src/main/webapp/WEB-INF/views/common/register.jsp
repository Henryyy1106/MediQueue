<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
</head>
<body>
<div class="auth-page" style="align-items: flex-start; padding-top: 2rem;">
    <div class="auth-card" style="max-width: 560px;">
        <div class="auth-logo">
            <h2><i class="fi fi-ss-hospital"></i> MediQueue</h2>
            <p>Create your patient account</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/register">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Full Name *</label>
                    <input type="text" name="name" class="form-control" placeholder="Ahmad bin Abdullah" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="tel" name="phone" class="form-control" placeholder="012-3456789">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Email Address *</label>
                <input type="email" name="email" class="form-control" placeholder="your@email.com" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <input type="password" name="password" class="form-control" placeholder="Min 6 characters" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Confirm Password *</label>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Re-enter password" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">IC Number</label>
                    <input type="text" name="icNumber" class="form-control" placeholder="000000-00-0000">
                </div>
                <div class="form-group">
                    <label class="form-label">Date of Birth</label>
                    <input type="date" name="dateOfBirth" class="form-control">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-control">
                        <option value="">Select...</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Address</label>
                <textarea name="address" class="form-control" rows="2" placeholder="Your home address"></textarea>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg">Create Account</button>
        </form>

        <div class="text-center mt-2">
            <p class="text-muted">Already have an account? <a href="${pageContext.request.contextPath}/login" style="color: var(--primary);">Sign In</a></p>
        </div>
    </div>
</div>
</body>
</html>
