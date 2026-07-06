<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - MediQueue</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mediqueue.css?v=7">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/admin_nav.jsp"/>

<div class="page-container">
    <div class="page-header">
        <h1><i class="fi fi-ss-users-alt"></i> User Management</h1>
        <p>Create, edit, reset, and safely remove patient or admin accounts.</p>
    </div>

    <div class="users-workspace">
        <c:if test="${param.created == '1'}"><div class="alert alert-success">User created successfully.</div></c:if>
        <c:if test="${param.updated == '1'}"><div class="alert alert-success">User updated successfully.</div></c:if>
        <c:if test="${param.deleted == '1'}"><div class="alert alert-success">User deleted successfully.</div></c:if>
        <c:if test="${param.passwordReset == '1'}"><div class="alert alert-success">Password reset successfully.</div></c:if>
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
                                    id="usersSearchInput"
                                    class="form-control"
                                    value="${fn:escapeXml(search)}"
                                    placeholder="Search by name or email"
                                    autocomplete="off">
                            </div>
                        </div>
                        <div class="users-filter-actions">
                            <div class="users-filter-popover-wrap">
                                <button type="button" class="btn btn-outline" id="openUsersFilters">
                                    <i class="fi fi-ss-settings-sliders"></i> Filter
                                </button>
                                <div class="users-filter-popover" id="usersFilterPopover" aria-hidden="true">
                                    <div class="users-filter-popover-header">
                                        <strong>Filters</strong>
                                        <button type="button" class="users-filter-close" id="closeUsersFilters" aria-label="Close filters">
                                            <i class="fi fi-ss-cross-small"></i>
                                        </button>
                                    </div>
                                    <div class="users-filter-popover-body">
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Role</span>
                                            <div class="users-filter-chip-row" id="usersRoleOptions">
                                                <button type="button" class="users-filter-chip ${empty role ? 'active' : ''}" data-role-filter="">All roles</button>
                                                <button type="button" class="users-filter-chip ${role == 'patient' ? 'active' : ''}" data-role-filter="patient">Patient</button>
                                                <button type="button" class="users-filter-chip ${role == 'admin' ? 'active' : ''}" data-role-filter="admin">Admin</button>
                                            </div>
                                        </div>
                                        <div class="users-filter-group">
                                            <span class="users-filter-label">Search</span>
                                            <input type="text" id="usersPopoverSearchInput" class="form-control" value="${fn:escapeXml(search)}" placeholder="Search...">
                                        </div>
                                    </div>
                                    <div class="users-filter-popover-footer">
                                        <button type="button" class="btn btn-outline btn-sm" id="clearUsersFilters">Clear</button>
                                        <button type="button" class="btn btn-primary btn-sm" id="applyUsersFilters">Apply</button>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-primary" id="openCreateUserModal"><i class="fi fi-ss-user-add"></i> Create New User</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="card users-table-card">
            <div class="card-header users-table-header">
                <div class="users-table-title">
                    <h5>Users Directory</h5>
                    <div class="users-table-subtitle" id="usersTableSubtitle">Showing patient and admin accounts for the current filters.</div>
                </div>
                <span class="badge badge-primary" id="usersCountBadge">${empty users ? 0 : users.size()} users</span>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${empty users}">
                        <div class="users-empty">
                            <div class="compact-empty-icon"><i class="fi fi-ss-users-alt"></i></div>
                            <div class="section-heading">No users match the current filters</div>
                            <div class="section-copy">Adjust your search criteria or create a new user to get started.</div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-container">
                            <table class="mediqueue-table">
                                <thead>
                                    <tr>
                                        <th>User</th>
                                        <th>Role</th>
                                        <th>Phone</th>
                                        <th>IC Number</th>
                                        <th>Gender</th>
                                        <th>Created</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="usersTableBody">
                                    <c:forEach var="user" items="${users}">
                                        <tr
                                            data-user-row
                                            data-user-id="${user.userId}"
                                            data-user-name="${fn:escapeXml(user.name)}"
                                            data-user-email="${fn:escapeXml(user.email)}"
                                            data-user-role="${fn:escapeXml(user.role)}"
                                            data-user-phone="${empty user.phone ? '' : fn:escapeXml(user.phone)}"
                                            data-user-ic-number="${empty user.icNumber ? '' : fn:escapeXml(user.icNumber)}"
                                            data-user-gender="${empty user.gender ? '' : fn:escapeXml(user.gender)}"
                                            data-user-address="${empty user.address ? '' : fn:escapeXml(user.address)}"
                                            data-user-date-of-birth="${empty user.dateOfBirth ? '' : user.dateOfBirth}"
                                            data-search="${fn:toLowerCase(fn:escapeXml(user.name))} ${fn:toLowerCase(fn:escapeXml(user.email))}"
                                            data-role="${fn:toLowerCase(fn:escapeXml(user.role))}">
                                            <td>
                                                <div class="user-name-cell">
                                                    <div class="user-avatar-chip">${fn:escapeXml(fn:substring(user.name, 0, 1))}</div>
                                                    <div class="user-name-copy">
                                                        <strong>${fn:escapeXml(user.name)}</strong>
                                                        <span>${fn:escapeXml(user.email)}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><span class="badge ${user.role == 'admin' ? 'badge-warning' : 'badge-info'}">${fn:escapeXml(user.role)}</span></td>
                                            <td>${empty user.phone ? '-' : fn:escapeXml(user.phone)}</td>
                                            <td>${empty user.icNumber ? '-' : fn:escapeXml(user.icNumber)}</td>
                                            <td>${empty user.gender ? '-' : fn:escapeXml(user.gender)}</td>
                                            <td>${user.createdAt}</td>
                                            <td>
                                                <div class="users-actions">
                                                    <button type="button" class="btn btn-outline btn-sm" data-open-edit-user>Edit</button>
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
                        <div class="users-empty users-empty-inline hidden" id="usersLiveEmptyState">
                            <div class="compact-empty-icon"><i class="fi fi-ss-search"></i></div>
                            <div class="section-heading">No users match your search</div>
                            <div class="section-copy">Try a different name, email, or filter combination.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

    </div>
</div>

<div class="users-modal" id="createUserModal" aria-hidden="true">
    <div class="users-modal-backdrop" data-close-users-modal></div>
    <div class="users-modal-panel users-modal-panel-edit" role="dialog" aria-modal="true" aria-labelledby="createUserModalTitle">
        <div class="users-modal-header">
            <div>
                <h4 id="createUserModalTitle">Create New User</h4>
                <p>Add a patient or admin account without leaving the directory view.</p>
            </div>
            <button type="button" class="users-modal-close" data-close-users-modal aria-label="Close create user form"><i class="fi fi-ss-cross-small"></i></button>
        </div>
        <div class="users-modal-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/users" class="users-stacked-form">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="create">
                <div class="users-form-intro">
                    <h5>Create New User</h5>
                    <p>Add a patient or admin account and fill in their profile information below.</p>
                </div>
                <div class="form-group">
                    <label class="form-label">Full Name *</label>
                    <input type="text" name="name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email *</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <div class="auth-password-field">
                        <input type="password" name="password" class="form-control" required minlength="6" data-password-input>
                        <button type="button" class="auth-password-toggle" data-password-toggle aria-label="Show password"><i class="fi fi-ss-eye-crossed"></i></button>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Role *</label>
                    <select name="role" class="form-control" required>
                        <option value="patient">Patient</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="text" name="phone" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">IC Number</label>
                    <input type="text" name="icNumber" class="form-control">
                </div>
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
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea name="address" class="form-control users-stacked-textarea" rows="4"></textarea>
                </div>
                <div class="users-stacked-actions">
                    <button type="button" class="btn btn-outline" data-close-users-modal>Cancel</button>
                    <button type="submit" class="btn btn-primary">Create User</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="users-modal" id="editUserModal" aria-hidden="true">
    <div class="users-modal-backdrop" data-close-users-modal></div>
    <div class="users-modal-panel users-modal-panel-edit" role="dialog" aria-modal="true" aria-labelledby="editUserModalTitle">
        <div class="users-modal-header">
            <div>
                <h4 id="editUserModalTitle">Edit User</h4>
                <p>Update account details and profile information securely.</p>
            </div>
            <button type="button" class="users-modal-close" data-close-users-modal aria-label="Close edit user form"><i class="fi fi-ss-cross-small"></i></button>
        </div>
        <div class="users-modal-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/users" id="editUserForm" class="users-stacked-form">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="editUserId">
                <div class="users-form-intro">
                    <h5>Update Account Details</h5>
                    <p>Update user credentials and profile information securely.</p>
                </div>
                <div class="form-group">
                    <label class="form-label">Full Name *</label>
                    <input type="text" name="name" id="editUserName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email *</label>
                    <input type="email" name="email" id="editUserEmail" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Role *</label>
                    <select name="role" id="editUserRole" class="form-control" required>
                        <option value="patient">Patient</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="text" name="phone" id="editUserPhone" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">IC Number</label>
                    <input type="text" name="icNumber" id="editUserIcNumber" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Date of Birth</label>
                    <input type="date" name="dateOfBirth" id="editUserDateOfBirth" class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">Gender</label>
                    <select name="gender" id="editUserGender" class="form-control">
                        <option value="">Select...</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Address</label>
                    <textarea name="address" id="editUserAddress" class="form-control users-stacked-textarea" rows="4"></textarea>
                </div>
                <div class="users-stacked-actions">
                    <button type="button" class="btn btn-outline" data-close-users-modal>Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="page-footer">MediQueue | SWE3024 Code Camp | Sunway University</div>
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

    var createModal = document.getElementById('createUserModal');
    var editModal = document.getElementById('editUserModal');
    var openBtn = document.getElementById('openCreateUserModal');
    var closeBtns = document.querySelectorAll('[data-close-users-modal]');
    var searchInput = document.getElementById('usersSearchInput');
    var popoverSearchInput = document.getElementById('usersPopoverSearchInput');
    var filterBtn = document.getElementById('openUsersFilters');
    var closeFilterBtn = document.getElementById('closeUsersFilters');
    var applyFilterBtn = document.getElementById('applyUsersFilters');
    var clearFilterBtn = document.getElementById('clearUsersFilters');
    var filterPopover = document.getElementById('usersFilterPopover');
    var roleOptions = document.querySelectorAll('[data-role-filter]');
    var rows = document.querySelectorAll('[data-user-row]');
    var countBadge = document.getElementById('usersCountBadge');
    var subtitle = document.getElementById('usersTableSubtitle');
    var liveEmptyState = document.getElementById('usersLiveEmptyState');
    var activeRole = '${fn:escapeXml(role)}' || '';
    var editButtons = document.querySelectorAll('[data-open-edit-user]');
    var editUserId = document.getElementById('editUserId');
    var editUserName = document.getElementById('editUserName');
    var editUserEmail = document.getElementById('editUserEmail');
    var editUserRole = document.getElementById('editUserRole');
    var editUserPhone = document.getElementById('editUserPhone');
    var editUserIcNumber = document.getElementById('editUserIcNumber');
    var editUserDateOfBirth = document.getElementById('editUserDateOfBirth');
    var editUserGender = document.getElementById('editUserGender');
    var editUserAddress = document.getElementById('editUserAddress');

    function syncModalOverflow() {
        var anyOpen =
            (createModal && createModal.classList.contains('open')) ||
            (editModal && editModal.classList.contains('open'));
        document.body.style.overflow = anyOpen ? 'hidden' : '';
    }

    function setModalState(modal, open) {
        if (!modal) return;
        modal.classList.toggle('open', open);
        modal.setAttribute('aria-hidden', open ? 'false' : 'true');
        syncModalOverflow();
    }

    function closeAllModals() {
        setModalState(createModal, false);
        setModalState(editModal, false);
    }

    if (openBtn) {
        openBtn.addEventListener('click', function () {
            closeAllModals();
            setModalState(createModal, true);
        });
    }

    closeBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            closeAllModals();
        });
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeAllModals();
            setFilterPopover(false);
        }
    });

    function setFilterPopover(open) {
        if (!filterPopover) return;
        filterPopover.classList.toggle('open', open);
        filterPopover.setAttribute('aria-hidden', open ? 'false' : 'true');
    }

    function syncSearchInputs(value) {
        if (searchInput && searchInput.value !== value) searchInput.value = value;
        if (popoverSearchInput && popoverSearchInput.value !== value) popoverSearchInput.value = value;
    }

    function setActiveRole(roleValue) {
        activeRole = roleValue || '';
        roleOptions.forEach(function (option) {
            option.classList.toggle('active', option.getAttribute('data-role-filter') === activeRole);
        });
    }

    function updateUsersTable() {
        var query = (searchInput ? searchInput.value : '').toLowerCase().trim();
        var visibleCount = 0;

        rows.forEach(function (row) {
            var rowSearch = row.getAttribute('data-search') || '';
            var rowRole = row.getAttribute('data-role') || '';
            var matchesSearch = !query || rowSearch.indexOf(query) !== -1;
            var matchesRole = !activeRole || rowRole === activeRole;
            var show = matchesSearch && matchesRole;
            row.style.display = show ? '' : 'none';
            if (show) visibleCount += 1;
        });

        if (countBadge) {
            countBadge.textContent = visibleCount + (visibleCount === 1 ? ' user' : ' users');
        }

        if (subtitle) {
            if (query && activeRole) {
                subtitle.textContent = 'Showing users matching "' + query + '" in ' + activeRole + ' role.';
            } else if (query) {
                subtitle.textContent = 'Showing users matching "' + query + '".';
            } else if (activeRole) {
                subtitle.textContent = 'Showing users in the ' + activeRole + ' role.';
            } else {
                subtitle.textContent = 'Showing patient and admin accounts for the current filters.';
            }
        }

        if (liveEmptyState) {
            liveEmptyState.classList.toggle('hidden', visibleCount !== 0);
        }
    }

    function populateEditModal(row) {
        if (!row) return;
        if (editUserId) editUserId.value = row.getAttribute('data-user-id') || '';
        if (editUserName) editUserName.value = row.getAttribute('data-user-name') || '';
        if (editUserEmail) editUserEmail.value = row.getAttribute('data-user-email') || '';
        if (editUserRole) editUserRole.value = (row.getAttribute('data-user-role') || '').toLowerCase();
        if (editUserPhone) editUserPhone.value = row.getAttribute('data-user-phone') || '';
        if (editUserIcNumber) editUserIcNumber.value = row.getAttribute('data-user-ic-number') || '';
        if (editUserDateOfBirth) editUserDateOfBirth.value = row.getAttribute('data-user-date-of-birth') || '';
        if (editUserGender) editUserGender.value = (row.getAttribute('data-user-gender') || '').toLowerCase();
        if (editUserAddress) editUserAddress.value = row.getAttribute('data-user-address') || '';
    }

    if (searchInput) {
        searchInput.addEventListener('input', function () {
            syncSearchInputs(searchInput.value);
            updateUsersTable();
        });
    }

    if (popoverSearchInput) {
        popoverSearchInput.addEventListener('input', function () {
            syncSearchInputs(popoverSearchInput.value);
        });
    }

    roleOptions.forEach(function (option) {
        option.addEventListener('click', function () {
            setActiveRole(option.getAttribute('data-role-filter') || '');
        });
    });

    editButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            var row = button.closest('[data-user-row]');
            populateEditModal(row);
            closeAllModals();
            setModalState(editModal, true);
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
            syncSearchInputs(popoverSearchInput ? popoverSearchInput.value : '');
            updateUsersTable();
            setFilterPopover(false);
        });
    }

    if (clearFilterBtn) {
        clearFilterBtn.addEventListener('click', function () {
            setActiveRole('');
            syncSearchInputs('');
            updateUsersTable();
        });
    }

    document.addEventListener('click', function (event) {
        if (!filterPopover || !filterBtn) return;
        if (!filterPopover.contains(event.target) && !filterBtn.contains(event.target)) {
            setFilterPopover(false);
        }
    });

    setActiveRole(activeRole);
    updateUsersTable();
})();
</script>
</body>
</html>
