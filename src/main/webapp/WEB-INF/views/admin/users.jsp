<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=3">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-users-alt"></i> User Management</h1>
        <p>Create, edit, reset, and safely remove patient or admin accounts.</p>
    </div>

    <c:if test="${param.created == '1'}"><div class="alert alert-success">User created successfully.</div></c:if>
    <c:if test="${param.updated == '1'}"><div class="alert alert-success">User updated successfully.</div></c:if>
    <c:if test="${param.deleted == '1'}"><div class="alert alert-success">User deleted successfully.</div></c:if>
    <c:if test="${param.passwordReset == '1'}"><div class="alert alert-success">Password reset successfully.</div></c:if>
    <c:if test="${not empty param.error}"><div class="alert alert-danger">${fn:escapeXml(fn:replace(param.error, '_', ' '))}</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-danger">${fn:escapeXml(error)}</div></c:if>

    <div class="card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/users">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Search</label>
                        <input type="text" name="search" class="form-control" value="${fn:escapeXml(search)}" placeholder="Name or email">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Role</label>
                        <select name="role" class="form-control">
                            <option value="">All roles</option>
                            <option value="patient" ${role == 'patient' ? 'selected' : ''}>Patient</option>
                            <option value="admin" ${role == 'admin' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Filter Users</button>
            </form>
        </div>
    </div>

    <div class="card mb-3">
        <div class="card-header"><h5>Create User</h5></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/users">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="create">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Full Name *</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email *</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Password *</label>
                        <input type="password" name="password" class="form-control" required minlength="6">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Role *</label>
                        <select name="role" class="form-control" required>
                            <option value="patient">Patient</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Phone</label>
                        <input type="text" name="phone" class="form-control">
                    </div>
                    <div class="form-group">
                        <label class="form-label">IC Number</label>
                        <input type="text" name="icNumber" class="form-control">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Date of Birth</label>
                        <input type="date" name="dateOfBirth" class="form-control">
                    </div>
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
                    <textarea name="address" class="form-control" rows="2"></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Create User</button>
            </form>
        </div>
    </div>

    <c:if test="${not empty editingUser}">
        <div class="card mb-3">
            <div class="card-header"><h5>Edit User</h5></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/admin/users">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" value="${editingUser.userId}">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Full Name *</label>
                            <input type="text" name="name" class="form-control" value="${fn:escapeXml(editingUser.name)}" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email *</label>
                            <input type="email" name="email" class="form-control" value="${fn:escapeXml(editingUser.email)}" required>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Role *</label>
                            <select name="role" class="form-control" required>
                                <option value="patient" ${editingUser.role == 'patient' ? 'selected' : ''}>Patient</option>
                                <option value="admin" ${editingUser.role == 'admin' ? 'selected' : ''}>Admin</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" class="form-control" value="${fn:escapeXml(editingUser.phone)}">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">IC Number</label>
                            <input type="text" name="icNumber" class="form-control" value="${fn:escapeXml(editingUser.icNumber)}">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Date of Birth</label>
                            <input type="date" name="dateOfBirth" class="form-control" value="${editingUser.dateOfBirth}">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Gender</label>
                            <select name="gender" class="form-control">
                                <option value="">Select...</option>
                                <option value="male" ${editingUser.gender == 'male' ? 'selected' : ''}>Male</option>
                                <option value="female" ${editingUser.gender == 'female' ? 'selected' : ''}>Female</option>
                                <option value="other" ${editingUser.gender == 'other' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Address</label>
                            <textarea name="address" class="form-control" rows="2">${fn:escapeXml(editingUser.address)}</textarea>
                        </div>
                    </div>
                    <div style="display:flex; gap:0.75rem; flex-wrap:wrap;">
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline">Cancel</a>
                    </div>
                </form>

                <div style="margin-top:1.25rem; padding-top:1.25rem; border-top:1px solid #eee;">
                    <form method="post" action="${pageContext.request.contextPath}/admin/users">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="resetPassword">
                        <input type="hidden" name="userId" value="${editingUser.userId}">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Reset Password</label>
                                <input type="password" name="newPassword" class="form-control" minlength="6" required placeholder="New password">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-warning">Reset Password</button>
                    </form>
                </div>
            </div>
        </div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h5>Users</h5>
            <span class="badge badge-primary">${empty users ? 0 : users.size()} users</span>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty users}">
                    <p class="text-muted text-center">No users match the current filters.</p>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="mediqueue-table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Phone</th>
                                    <th>Created</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="user" items="${users}">
                                    <tr>
                                        <td><strong>${fn:escapeXml(user.name)}</strong></td>
                                        <td>${fn:escapeXml(user.email)}</td>
                                        <td><span class="badge ${user.role == 'admin' ? 'badge-warning' : 'badge-info'}">${fn:escapeXml(user.role)}</span></td>
                                        <td>${fn:escapeXml(user.phone)}</td>
                                        <td>${user.createdAt}</td>
                                        <td>
                                            <div style="display:flex; gap:0.4rem; flex-wrap:wrap;">
                                                <a href="${pageContext.request.contextPath}/admin/users/edit/${user.userId}" class="btn btn-outline btn-sm">Edit</a>
                                                <c:if test="${user.userId != currentAdminId}">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline;" onsubmit="return confirm('Delete this user and all related records?');">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="userId" value="${user.userId}">
                                                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
</body>
</html>
