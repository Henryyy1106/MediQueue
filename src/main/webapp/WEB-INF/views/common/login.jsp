<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card">
        <div class="auth-logo">
            <h2><i class="fi fi-ss-hospital"></i> MediQueue</h2>
            <p>AI-Powered Smart Public Clinic Queue System</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="fi fi-ss-triangle-warning"></i> ${fn:escapeXml(error)}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success"><i class="fi fi-ss-check"></i> ${success}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" placeholder="your@email.com" required autofocus>
            </div>
            <div class="form-group">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block btn-lg">Sign In</button>
        </form>

        <div class="auth-divider">or</div>

        <div class="text-center">
            <p class="text-muted">Don't have an account?</p>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-outline btn-block mt-1">Create Account</a>
        </div>

        <div class="text-center mt-3">
            <p class="text-muted" style="font-size:0.75rem;">
                Demo: patient@mediqueue.my / patient123<br>
                Admin: admin@mediqueue.my / admin123
            </p>
        </div>
    </div>
</div>
</body>
</html>
