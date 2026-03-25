<%--
Document   : bookForm.jsp
Booking form fragment - included in index.jsp modal.
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String err = request.getParameter("bookError");
    String msg = request.getParameter("bookMessage");
%>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@500;600;700;800&display=swap');
    
    .book-form-container {
        --brand-orange: #f27c0d;
        --brand-orange-deep: #d96809;
        --ink: #2f2319;
        --muted-ink: #826752;
        --surface: #fff;
        --field-bg: #f6f2ee;
        --field-border: #ecdfd2;
        --divider: #f1e8df;
        font-family: 'Nunito', 'Tahoma', sans-serif;
        padding: 0;
        background: var(--surface);
        border-radius: 22px;
        overflow: hidden;
        box-shadow: 0 24px 48px rgba(49, 26, 7, 0.12);
    }
    
    .book-form-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 22px 28px;
        border-bottom: 1px solid var(--divider);
        background: linear-gradient(180deg, #fff 0%, #fffbf7 100%);
    }
    
    .book-form-title {
        margin: 0;
        font-weight: 800;
        font-size: 30px;
        color: var(--brand-orange-deep);
        line-height: 1;
        letter-spacing: -0.03em;
    }
    
    .book-form-brand {
        font-size: 28px;
        font-weight: 800;
        color: #ba3b07;
        line-height: 1;
    }
    
    .book-form-body {
        padding: 26px 28px 20px;
        background:
        radial-gradient(circle at 92% 14%, rgba(242, 124, 13, 0.08), transparent 28%),
        radial-gradient(circle at 98% 8%, rgba(242, 124, 13, 0.1), transparent 16%),
        #fff;
    }
    
    .book-form-container .form-group { margin-bottom: 20px; }
    
    .book-form-container label {
        display: block;
        margin-bottom: 9px;
        text-transform: uppercase;
        letter-spacing: 0.045em;
        font-size: 11px;
        font-weight: 800;
        color: #5f4a39;
    }
    
    .book-form-container .form-control,
    .book-form-container .form-select {
        border: 1px solid var(--field-border);
        border-radius: 999px;
        padding: 12px 16px;
        font-size: 15px;
        color: var(--ink);
        background: var(--field-bg);
        transition: border-color 0.25s ease, box-shadow 0.25s ease, background-color 0.25s ease;
        width: 100%;
        box-sizing: border-box;
        min-height: 48px;
    }
    
    .book-form-container textarea.form-control {
        border-radius: 16px;
        min-height: 112px;
        resize: vertical;
    }
    
    .book-form-container .form-control::placeholder {
        color: #b19884;
    }
    
    .book-form-container .form-control:focus,
    .book-form-container .form-select:focus {
        border-color: var(--brand-orange);
        box-shadow: 0 0 0 4px rgba(242, 124, 13, 0.14);
        background-color: #fff;
        outline: none;
    }
    
    .book-form-container .field-locked {
        background-color: #ebe5df !important;
        color: #6f5a48;
        cursor: not-allowed;
    }
    
    .book-form-container .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 18px;
    }
    
    .book-form-container .form-row.full { grid-template-columns: 1fr; }
    
    .book-form-container .divider {
        border-top: 1px solid var(--divider);
        margin: 8px 0 20px;
    }
    
    .book-form-container .alert {
        margin: 0 0 16px;
        border-radius: 12px;
    }
    
    .book-form-container .text-note {
        font-size: 12px;
        color: var(--muted-ink);
        text-align: center;
        margin-top: 14px;
        line-height: 1.45;
    }
    
    .book-form-actions {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        margin-top: 10px;
        padding-top: 16px;
        border-top: 1px solid var(--divider);
    }
    
    .book-form-container .btn-cancel {
        border: none;
        background: transparent;
        color: #6e5a4a;
        font-weight: 700;
        padding: 10px 6px;
    }
    
    .book-form-container .btn-submit {
        background: linear-gradient(135deg, var(--brand-orange) 0%, var(--brand-orange-deep) 100%);
        color: #fff;
        border: none;
        border-radius: 999px;
        font-weight: 800;
        cursor: pointer;
        transition: transform 0.2s ease, box-shadow 0.2s ease, filter 0.2s ease;
        font-size: 16px;
        min-width: 198px;
        padding: 13px 24px;
        box-shadow: 0 10px 20px rgba(217, 104, 9, 0.28);
    }
    
    .book-form-container .btn-submit:hover {
        transform: translateY(-2px);
        filter: brightness(1.02);
        box-shadow: 0 14px 26px rgba(217, 104, 9, 0.34);
    }
    
    .book-form-container .btn-submit:active {
        transform: translateY(0);
    }
    
    #serviceDropdown {
        background: #fff;
        border: 1px solid var(--field-border);
        border-radius: 16px;
        margin-top: 6px;
    }
    
    #serviceDropdown > div:hover {
        background: #fff7ef;
    }
    
    @media (max-width: 900px) {
        .book-form-title,
        .book-form-brand {
            font-size: 24px;
        }
    }
    
    @media (max-width: 768px) {
        .book-form-header,
        .book-form-body {
            padding: 18px;
        }
        
        .book-form-container .form-row {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        
        .book-form-actions {
            flex-direction: column-reverse;
            align-items: stretch;
        }
        
        .book-form-container .btn-submit {
            width: 100%;
        }
        
        .book-form-container .btn-cancel {
            text-align: center;
            width: 100%;
        }
    }
</style>

<div class="book-form-container">

    <div class="book-form-body">
        <% if ("1".equals(err) && msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-danger" role="alert"><%= java.net.URLDecoder.decode(msg, "UTF-8") %></div>
        <% } %>
        <form id="appointmentForm" action="<%= ctx %>/book" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label for="ownerName">Owner Name *</label>
                    <input type="text" class="form-control" id="ownerName" name="ownerName" placeholder="e.g. Nguyen Van A" maxlength="100" title="1-100 characters. Letters (including Vietnamese), spaces, apostrophes, hyphens, and dots are allowed." required>
                </div>
                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="tel" class="form-control" id="phone" name="phone" placeholder="0123456789" pattern="0[0-9]{9}" title="10 digits starting with 0." maxlength="10" required>
                    <small id="phoneLookupStatus" style="display:block;margin-top:6px;color:#8e7b6a;">Phone is used to identify existing customer.</small>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" class="form-control" id="email" name="email" placeholder="alexander@domain.com" maxlength="255" required>
                </div>
                <div class="form-group">
                    <label>Select Service(s) *</label>
                    <div class="dropdown-service-multi" style="position: relative;">
                        <button type="button" id="dropdownServiceBtn" class="form-control form-select" style="text-align: left; cursor: pointer;" onclick="toggleServiceDropdown()">
                            <span id="dropdownServiceText">Chọn dịch vụ</span>
                            <span style="float: right;">&#9660;</span>
                        </button>
                        <div id="serviceDropdown" style="display: none; position: absolute; z-index: 10; background: #fff; border: 1px solid #e8dbce; border-radius: 8px; width: 100%; max-height: 200px; overflow-y: auto; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-top: 2px;">
                            <c:if test="${not empty services}">
                                <c:forEach var="service" items="${services}">
                                    <div style="padding: 8px 12px;">
                                        <input type="checkbox" id="service_${service.serviceId}" name="serviceIds" value="${service.serviceId}" style="margin-right: 6px;">
                                        <label for="service_${service.serviceId}" style="font-weight: normal; cursor: pointer;">${service.name}</label>
                                    </div>
                                </c:forEach>
                            </c:if>
                        </div>
                    </div>
                    <small style="color:#888;">Chọn một hoặc nhiều dịch vụ.</small>
                </div>
            </div>
            <div class="divider"></div>
            <div class="form-row">
                <div class="form-group">
                    <label for="petName">Pet Name *</label>
                    <input type="text" class="form-control" id="petName" name="petName" placeholder="e.g. Luna" maxlength="100" title="1-100 characters. Letters (including Vietnamese), spaces, apostrophes, hyphens, and dots are allowed." required>
                </div>
                <div class="form-group">
                    <label for="petType">Pet Type *</label>
                    <select class="form-control form-select" id="petType" name="petType" required>
                        <option value="">Select pet type</option>
                        <option value="Dog">Dog</option>
                        <option value="Cat">Cat</option>
                        <option value="Bird">Bird</option>
                        <option value="Rabbit">Rabbit</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="appointmentDate">Preferred Date *</label>
                    <input type="date" class="form-control" id="appointmentDate" name="appointmentDate" required>
                </div>
                <div class="form-group">
                    <label for="timeSlot">Preferred Slot *</label>
                    <select class="form-control form-select" id="timeSlot" name="timeSlot" required>
                        <option value="">Choose a slot</option>
                        <option value="morning">Morning (08:00)</option>
                        <option value="afternoon">Afternoon (14:00)</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label for="timeSlot">Preferred Slot *</label>
                <select class="form-control form-select" id="timeSlot" name="timeSlot" required>
                    <option value="">Choose a slot</option>
                    <option value="morning">in the Morning</option>
                    <option value="afternoon">in the Afternoon</option>
                </select>
            </div>
            <div class="book-form-actions">
                <button type="button" class="btn-cancel" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-submit">Confirm Booking</button>
            </div>
            <p class="text-note">By clicking confirm, you agree to our terms of service and privacy policy. We will send a confirmation shortly.</p>
        </form>
    </div>
</div>
<script>
    (function() {
        var dateEl = document.getElementById('appointmentDate');
        if (dateEl) {
            var today = new Date().toISOString().split('T')[0];
            dateEl.setAttribute('min', today);
        }
    })();
</script>
<script>
    function toggleServiceDropdown() {
        var dropdown = document.getElementById('serviceDropdown');
        if (!dropdown) return;
        dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(event) {
        var btn = document.getElementById('dropdownServiceBtn');
        var dropdown = document.getElementById('serviceDropdown');
        if (!btn || !dropdown) return;
        if (!btn.contains(event.target) && !dropdown.contains(event.target)) {
            dropdown.style.display = 'none';
        }
    });
    // Hiển thị tên dịch vụ đã chọn
    var serviceDropdown = document.getElementById('serviceDropdown');
    if (serviceDropdown) {
        serviceDropdown.addEventListener('change', function() {
            var checked = serviceDropdown.querySelectorAll('input[type=checkbox]:checked');
            var names = Array.from(checked).map(function(cb) {
                return cb.nextElementSibling.textContent;
            });
            document.getElementById('dropdownServiceText').textContent = names.length ? names.join(', ') : 'Chọn dịch vụ';
        });
    }
</script>
<script>
    (function() {
        var phoneInput = document.getElementById('phone');
        var ownerInput = document.getElementById('ownerName');
        var emailInput = document.getElementById('email');
        var statusEl = document.getElementById('phoneLookupStatus');
        var ctx = '<%= ctx %>';
        var timerId;
        
        function setStatus(text, color) {
            if (!statusEl) return;
            statusEl.textContent = text;
            statusEl.style.color = color || '#8e7b6a';
        }
        
        function setIdentityLocked(locked) {
            if (ownerInput) {
                ownerInput.readOnly = !!locked;
                ownerInput.classList.toggle('field-locked', !!locked);
            }
            if (emailInput) {
                emailInput.readOnly = !!locked;
                emailInput.classList.toggle('field-locked', !!locked);
            }
        }
        
        function runLookup() {
            if (!phoneInput) return;
            var phone = (phoneInput.value || '').trim();
            
            if (phone.length < 10) {
                setIdentityLocked(false);
                setStatus('Phone is used to identify existing customer.', '#8e7b6a');
                return;
            }
            
            fetch(ctx + '/book/lookup-phone?phone=' + encodeURIComponent(phone))
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data && data.found && data.customer) {
                    if (ownerInput && data.customer.fullName) ownerInput.value = data.customer.fullName;
                    if (emailInput && data.customer.email) emailInput.value = data.customer.email;
                    setIdentityLocked(true);
                    setStatus('Existing customer found by phone. Owner Name and Email are locked.', '#1a8f3f');
                    } else {
                        setIdentityLocked(false);
                        setStatus('New phone number. Please continue entering customer info.', '#8e7b6a');
                    }
                })
                .catch(function() {
                    setIdentityLocked(false);
                    setStatus('Could not verify phone right now. You can continue manually.', '#9a572e');
                });
            }
            
            function scheduleLookup() {
                clearTimeout(timerId);
                timerId = setTimeout(runLookup, 350);
            }
            
            if (phoneInput) {
                phoneInput.addEventListener('input', scheduleLookup);
                phoneInput.addEventListener('blur', runLookup);
            }
        })();
    </script>
    <script>
        // AJAX submit cho form booking
        const form = document.getElementById('appointmentForm');
        if (form) {
            form.addEventListener('submit', function(e) {
                var selectedServices = form.querySelectorAll('input[name="serviceIds"]:checked');
                if (selectedServices.length === 0) {
                    e.preventDefault();
                    alert('Vui long chon it nhat 1 dich vu.');
                    return;
                }
                
                e.preventDefault();
                const formData = new FormData(form);
                const encoded = new URLSearchParams(formData);
                
                // DEBUG: log payload before sending.
                var pairs = [];
                encoded.forEach(function(value, key) {
                    pairs.push(key + '=' + value);
                });
                console.log('[BOOK_DEBUG][client] payload:', pairs.join(' | '));
                
                fetch(form.action, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                    },
                    body: encoded.toString()
                })
                .then(response => {
                    if (response.redirected) {
                        window.location.href = response.url;
                        return null;
                    }
                    return response.text();
                })
                .then(data => {
                    if (data && !window.location.href.includes('index.jsp')) {
                        alert('Đặt lịch thất bại hoặc có lỗi xảy ra!');
                    }
                })
                .catch(function() {
                    alert('Đặt lịch thất bại hoặc có lỗi xảy ra!');
                });
            });
        }
    </script>
