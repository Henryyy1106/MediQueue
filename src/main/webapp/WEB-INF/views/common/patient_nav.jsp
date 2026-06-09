<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- Flaticon UIcons (solid straight) for nav icons -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/uicons/uicons-solid-straight.css">
<nav class="navbar-mediqueue">
    <a href="${pageContext.request.contextPath}/patient/dashboard" class="navbar-brand">
        <div class="brand-icon"><i class="fi fi-ss-hospital"></i></div>
        <div>
            <span class="brand-name">MediQueue</span>
            <span class="brand-tagline">Smart Clinic Queue System</span>
        </div>
    </a>

    <button class="navbar-toggle" type="button" aria-label="Toggle navigation menu"
            onclick="this.closest('.navbar-mediqueue').querySelector('.navbar-nav').classList.toggle('open')">
        <i class="fi fi-ss-menu-burger"></i>
    </button>

    <ul class="navbar-nav">
        <li><a href="${pageContext.request.contextPath}/patient/dashboard" class="nav-link"><i class="fi fi-ss-house-chimney"></i> Dashboard</a></li>
        <li><a href="${pageContext.request.contextPath}/patient/clinics" class="nav-link"><i class="fi fi-ss-search-location"></i> Find Clinic</a></li>
        <li><a href="${pageContext.request.contextPath}/patient/appointments/book" class="nav-link"><i class="fi fi-ss-calendar-plus"></i> Book</a></li>
        <li><a href="${pageContext.request.contextPath}/patient/queue" class="nav-link"><i class="fi fi-ss-users-alt"></i> My Queue</a></li>
        <li><a href="${pageContext.request.contextPath}/patient/history" class="nav-link"><i class="fi fi-ss-time-past"></i> History</a></li>
    </ul>

    <div class="navbar-user">
        <div class="user-avatar">${fn:escapeXml(not empty sessionScope.userName ? sessionScope.userName.substring(0,1).toUpperCase() : 'P')}</div>
        <div>
            <div style="font-size:0.85rem; font-weight:600;">${fn:escapeXml(sessionScope.userName)}</div>
            <div style="font-size:0.7rem; opacity:0.7;">Patient</div>
        </div>
        <a href="${pageContext.request.contextPath}/patient/profile" class="nav-link" aria-label="Profile settings" title="Profile settings"><i class="fi fi-ss-settings"></i></a>
        <a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fi fi-ss-sign-out-alt"></i> Logout</a>
    </div>
</nav>

<!-- Floating AI Chat Widget (shown on all patient pages) -->
<!-- Styles are inline (not only in mediqueue.css) so the widget renders
     correctly even when a browser has the old stylesheet cached. -->
<style>
.ai-fab{position:fixed;bottom:24px;right:24px;width:60px;height:60px;border-radius:50%;border:none;background:#0066CC;color:#fff;font-size:1.6rem;line-height:1;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 4px 16px rgba(0,0,0,0.25);z-index:1100;transition:transform .15s ease, background .15s ease;}
.ai-fab:hover{transform:scale(1.08);background:#004499;}
.ai-chat-widget{position:fixed;bottom:96px;right:24px;width:360px;max-width:calc(100vw - 48px);height:480px;max-height:calc(100vh - 120px);background:#fff;border-radius:14px;box-shadow:0 8px 30px rgba(0,0,0,0.25);z-index:1100;display:none;flex-direction:column;overflow:hidden;}
.ai-chat-widget.open{display:flex;}
.ai-chat-widget-header{background:linear-gradient(135deg,#004499 0%,#0066CC 100%);color:#fff;padding:1rem;display:flex;justify-content:space-between;align-items:center;flex:0 0 auto;}
.ai-chat-widget-close{background:none;border:none;color:#fff;font-size:1.2rem;line-height:1;cursor:pointer;opacity:.85;padding:0;}
.ai-chat-widget-close:hover{opacity:1;}
.ai-chat-widget .ai-chat-box{flex:1 1 auto;margin:0;border-radius:0;max-height:none;min-height:0;overflow-y:auto;}
.ai-chat-input-row{display:flex;gap:.5rem;padding:.75rem;border-top:1px solid #eee;flex:0 0 auto;}
.ai-chat-input-row .form-control{flex:1;}
.ai-typing span{display:inline-block;width:7px;height:7px;margin:0 1px;background:#aaa;border-radius:50%;animation:aiTypingBounce 1.2s infinite ease-in-out;}
.ai-typing span:nth-child(2){animation-delay:.2s;}
.ai-typing span:nth-child(3){animation-delay:.4s;}
@keyframes aiTypingBounce{0%,80%,100%{transform:translateY(0);opacity:.4;}40%{transform:translateY(-5px);opacity:1;}}
</style>
<button id="aiChatFab" class="ai-fab" type="button" aria-label="Open AI assistant" title="Ask MediQueue Assistant"><i class="fi fi-ss-comment"></i></button>
<div id="aiChatWidget" class="ai-chat-widget" role="dialog" aria-label="MediQueue AI Assistant">
    <div class="ai-chat-widget-header">
        <div>
            <strong><i class="fi fi-ss-robot"></i> MediQueue Assistant</strong>
            <div style="font-size:0.72rem; opacity:0.85;">Ask about clinics, hours &amp; queues</div>
        </div>
        <button id="aiChatClose" class="ai-chat-widget-close" type="button" aria-label="Close chat"><i class="fi fi-ss-cross-small"></i></button>
    </div>
    <div id="aiChatBox" class="ai-chat-box">
        <div class="ai-message ai-msg">
            <div class="ai-label">Assistant</div>
            Hi! I can help with questions like clinic opening hours or which clinic is least busy. What would you like to know?
        </div>
    </div>
    <form id="aiChatForm" class="ai-chat-input-row" autocomplete="off">
        <input id="aiChatInput" type="text" class="form-control" placeholder="Type your question..." required>
        <button type="submit" class="btn btn-primary btn-sm" id="aiChatSend">Send</button>
    </form>
</div>

<script>
(function () {
    var fab = document.getElementById('aiChatFab');
    var widget = document.getElementById('aiChatWidget');
    var closeBtn = document.getElementById('aiChatClose');
    var box = document.getElementById('aiChatBox');
    var form = document.getElementById('aiChatForm');
    var input = document.getElementById('aiChatInput');
    var sendBtn = document.getElementById('aiChatSend');
    var endpoint = '${pageContext.request.contextPath}/ai/chat';

    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // Inline Markdown: code, bold, italic. Input must already be HTML-escaped.
    function renderInline(s) {
        return s
            .replace(/`([^`]+)`/g, '<code style="background:#eee;padding:0 3px;border-radius:3px;font-size:0.85em;">$1</code>')
            .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
            .replace(/\*([^*]+)\*/g, '<em>$1</em>');
    }

    // Lightweight block-level Markdown -> HTML (headings, lists, rules, paragraphs).
    function renderMarkdown(text) {
        var lines = escapeHtml(text).split('\n');
        var html = '';
        var listType = null;
        function closeList() { if (listType) { html += '</' + listType + '>'; listType = null; } }
        for (var i = 0; i < lines.length; i++) {
            var raw = lines[i].trim();
            if (raw === '') { closeList(); continue; }
            if (/^(-{3,}|\*{3,}|_{3,})$/.test(raw)) {
                closeList();
                html += '<hr style="border:none;border-top:1px solid #eee;margin:0.5rem 0;">';
                continue;
            }
            var h = raw.match(/^([#]{1,6})\s+(.*)$/);
            if (h) {
                closeList();
                var size = h[1].length <= 1 ? '1rem' : (h[1].length === 2 ? '0.95rem' : '0.9rem');
                html += '<div style="font-weight:700;font-size:' + size + ';margin:0.45rem 0 0.2rem;">' + renderInline(h[2]) + '</div>';
                continue;
            }
            var ul = raw.match(/^[-*•✓✔]\s+(.*)$/);
            if (ul) {
                if (listType !== 'ul') { closeList(); html += '<ul style="margin:0.25rem 0 0.25rem 1.1rem;padding:0;">'; listType = 'ul'; }
                html += '<li style="margin:0.15rem 0;">' + renderInline(ul[1]) + '</li>';
                continue;
            }
            var ol = raw.match(/^\d+\.\s+(.*)$/);
            if (ol) {
                if (listType !== 'ol') { closeList(); html += '<ol style="margin:0.25rem 0 0.25rem 1.3rem;padding:0;">'; listType = 'ol'; }
                html += '<li style="margin:0.15rem 0;">' + renderInline(ol[1]) + '</li>';
                continue;
            }
            closeList();
            html += '<div>' + renderInline(raw) + '</div>';
        }
        closeList();
        return html;
    }

    function scrollDown() { box.scrollTop = box.scrollHeight; }

    function addMessage(text, who) {
        var msg = document.createElement('div');
        msg.className = 'ai-message ' + (who === 'user' ? 'user-msg' : 'ai-msg');
        if (who === 'ai') {
            msg.innerHTML = '<div class="ai-label">Assistant</div>' + renderMarkdown(text);
        } else {
            msg.innerHTML = escapeHtml(text).replace(/\n/g, '<br>');
        }
        box.appendChild(msg);
        scrollDown();
    }

    function showTyping() {
        var t = document.createElement('div');
        t.className = 'ai-message ai-msg';
        t.id = 'aiChatTyping';
        t.innerHTML = '<div class="ai-label">Assistant</div><div class="ai-typing"><span></span><span></span><span></span></div>';
        box.appendChild(t);
        scrollDown();
    }

    function hideTyping() {
        var t = document.getElementById('aiChatTyping');
        if (t) t.remove();
    }

    function toggle(open) {
        widget.classList.toggle('open', open);
        if (open) input.focus();
    }

    fab.addEventListener('click', function () { toggle(!widget.classList.contains('open')); });
    closeBtn.addEventListener('click', function () { toggle(false); });

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var text = input.value.trim();
        if (!text) return;
        addMessage(text, 'user');
        input.value = '';
        input.disabled = true;
        sendBtn.disabled = true;
        showTyping();

        fetch(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'message=' + encodeURIComponent(text)
        })
        .then(function (r) { return r.json(); })
        .then(function (data) {
            hideTyping();
            addMessage(data && data.reply ? data.reply : (data && data.error ? data.error : 'Sorry, I could not respond right now.'), 'ai');
        })
        .catch(function () {
            hideTyping();
            addMessage('Sorry, the assistant is unavailable right now. Please contact clinic staff for help.', 'ai');
        })
        .finally(function () {
            input.disabled = false;
            sendBtn.disabled = false;
            input.focus();
        });
    });
})();
</script>
