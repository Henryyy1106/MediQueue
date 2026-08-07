<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=4">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-shell">
        <section class="auth-showcase" aria-hidden="true">
            <div class="auth-showcase-inner">
                <div class="auth-kicker"><i class="fi fi-ss-heart"></i> Smart Public Clinic Access</div>
                <h1>Welcome<br>Back</h1>
                <p class="auth-showcase-copy">MediQueue helps patients book appointments, follow live queue progress, and spend less time waiting at public clinics.</p>

                <div class="auth-feature-list">
                    <div class="auth-feature">
                        <div class="auth-feature-icon"><i class="fi fi-ss-calendar-clock"></i></div>
                        <div>Track appointments and check estimated queue wait times before you arrive.</div>
                    </div>
                    <div class="auth-feature">
                        <div class="auth-feature-icon"><i class="fi fi-ss-hospital"></i></div>
                        <div>Find the right clinic faster with a patient-friendly system built for everyday visits.</div>
                    </div>
                </div>

                <div class="auth-footer-note">Built for a smoother clinic experience with clearer scheduling, queue visibility, and patient access.</div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-logo">
                <div class="auth-brand">
                    <span class="auth-brand-mark"><i class="fi fi-ss-hospital"></i></span>
                    <span>MediQueue</span>
                </div>
                <h2 class="auth-title">Sign in</h2>
                <p class="auth-subtitle">Access your appointments, queue status, and booking tools from one place.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success"><i class="fi fi-ss-check"></i> ${success}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login" class="auth-form">
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="your@email.com" required autofocus>
                </div>
                <div class="form-group">
                    <div class="auth-label-row">
                        <label class="form-label">Password</label>
                    </div>
                    <div class="auth-password-field">
                        <input type="password" name="password" class="form-control" placeholder="Enter your password" required data-password-input>
                        <button type="button" class="auth-password-toggle" data-password-toggle aria-label="Show password"><i class="fi fi-ss-eye-crossed"></i></button>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block btn-lg">Sign in now</button>
            </form>

            <div class="auth-divider">or</div>

            <div class="text-center">
                <p class="text-muted">Don't have an account?</p>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-outline btn-block mt-1">Create Account</a>
            </div>

            <div class="auth-support-note">
                <strong>Demo access</strong>
                Patient: patient@mediqueue.my / patient123<br>
                Admin: admin@mediqueue.my / admin123
            </div>
        </section>
    </div>
</div>
<script>
(function () {
    var toggles = document.querySelectorAll('[data-password-toggle]');
    toggles.forEach(function (toggle) {
        toggle.addEventListener('click', function () {
            var wrapper = toggle.closest('.auth-password-field');
            var input = wrapper ? wrapper.querySelector('[data-password-input]') : null;
            if (!input) return;
            var isHidden = input.type === 'password';
            input.type = isHidden ? 'text' : 'password';
            toggle.innerHTML = isHidden ? '<i class="fi fi-ss-eye"></i>' : '<i class="fi fi-ss-eye-crossed"></i>';
            toggle.setAttribute('aria-label', isHidden ? 'Hide password' : 'Show password');
        });
    });
})();
</script>
</body>
</html>
