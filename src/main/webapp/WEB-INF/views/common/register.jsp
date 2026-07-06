<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=4">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-shell">
        <section class="auth-showcase" aria-hidden="true">
            <div class="auth-showcase-inner">
                <div class="auth-kicker"><i class="fi fi-ss-user-add"></i> Patient Registration</div>
                <h1>Join<br>MediQueue</h1>
                <p class="auth-showcase-copy">Create your patient account once and use it to book appointments, monitor queue movement, and manage your clinic visits with less friction.</p>

                <div class="auth-feature-list">
                    <div class="auth-feature">
                        <div class="auth-feature-icon"><i class="fi fi-ss-address-book"></i></div>
                        <div>Store your patient details in one place so returning visits are quicker and easier to manage.</div>
                    </div>
                    <div class="auth-feature">
                        <div class="auth-feature-icon"><i class="fi fi-ss-time-forward"></i></div>
                        <div>Use the same account to book visits, review queue status, and keep track of past appointments.</div>
                    </div>
                </div>

                <div class="auth-footer-note">A simpler digital front door for public clinic access, designed to reduce waiting and improve clarity.</div>
            </div>
        </section>

        <section class="auth-card auth-card-register">
            <div class="auth-logo">
                <div class="auth-brand">
                    <span class="auth-brand-mark"><i class="fi fi-ss-hospital"></i></span>
                    <span>MediQueue</span>
                </div>
                <h2 class="auth-title">Create account</h2>
                <p class="auth-subtitle">Register as a patient to start booking appointments and checking clinic queues online.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/register" class="auth-form">
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
                        <div class="auth-password-field">
                            <input type="password" name="password" class="form-control" placeholder="Minimum 6 characters" required data-password-input>
                            <button type="button" class="auth-password-toggle" data-password-toggle aria-label="Show password"><i class="fi fi-ss-eye-crossed"></i></button>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Confirm Password *</label>
                        <div class="auth-password-field">
                            <input type="password" name="confirmPassword" class="form-control" placeholder="Re-enter password" required data-password-input>
                            <button type="button" class="auth-password-toggle" data-password-toggle aria-label="Show password"><i class="fi fi-ss-eye-crossed"></i></button>
                        </div>
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

            <div class="auth-divider">or</div>

            <div class="text-center">
                <p class="text-muted">Already have an account?</p>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline btn-block mt-1">Sign In</a>
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
