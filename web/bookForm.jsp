<%--
Document   : bookForm.jsp
Booking form fragment - included in index.jsp modal.
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String err = request.getParameter("bookError");
    String msg = request.getParameter("bookMessage");
%>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@500;600;700;800&display=swap');
    
    .book-form-container {
        --brand: #c64212;
        --brand-soft: #fdeae2;
        --ink: #1f2126;
        --muted-ink: #6d6f76;
        --surface: #fff;
        --field-bg: #f6f6f7;
        --field-border: #ececee;
        --section-surface: #f8f8f9;
        --divider: #efeff1;
        font-family: 'Nunito', 'Tahoma', sans-serif;
        padding: 0;
        background: var(--surface);
        border-radius: 20px;
        overflow: hidden;
        box-shadow: 0 26px 50px rgba(33, 23, 19, 0.11);
    }
    
    .book-form-body {
        padding: 14px;
        background:
        radial-gradient(circle at 88% 8%, rgba(198, 66, 18, 0.06), transparent 34%),
        radial-gradient(circle at 98% 16%, rgba(198, 66, 18, 0.08), transparent 20%),
        #fff;
    }
    
    .book-form-container .form-group { margin-bottom: 12px; }
    
    .book-form-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 12px;
    }
    
    .book-form-section.wide {
        grid-column: 1 / -1;
    }
    
    .book-form-container label {
        display: block;
        margin-bottom: 6px;
        letter-spacing: 0.01em;
        font-size: 13px;
        font-weight: 700;
        color: #4c4f56;
    }
    
    .book-form-container .form-control,
    .book-form-container .form-select {
        border: 1px solid var(--field-border);
        border-radius: 10px;
        padding: 10px 13px;
        font-size: 14px;
        color: var(--ink);
        background: var(--field-bg);
        transition: border-color 0.25s ease, box-shadow 0.25s ease, background-color 0.25s ease;
        width: 100%;
        box-sizing: border-box;
        min-height: 42px;
    }
    
    .book-form-container textarea.form-control {
        border-radius: 10px;
        min-height: 112px;
        resize: vertical;
    }
    
    .book-form-container .form-control::placeholder {
        color: #b19884;
    }
    
    .book-form-container .form-control:focus,
    .book-form-container .form-select:focus {
        border-color: var(--brand);
        box-shadow: 0 0 0 4px rgba(198, 66, 18, 0.12);
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
        gap: 10px;
    }
    
    .book-form-container .form-row.full { grid-template-columns: 1fr; }
    
    .book-form-section {
        background: var(--section-surface);
        border: 1px solid var(--divider);
        border-radius: 18px;
        padding: 12px;
        margin-bottom: 0;
    }
    
    .book-form-section-title {
        display: flex;
        align-items: center;
        gap: 8px;
        margin: 0 0 10px;
        color: #44474f;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        font-size: 12px;
        font-weight: 800;
    }
    
    .book-form-section-title .section-icon {
        width: 20px;
        height: 20px;
        border-radius: 999px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: var(--brand-soft);
        color: var(--brand);
        font-size: 12px;
        font-weight: 800;
    }
    
    .service-pills {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
    }
    
    .service-pill-option {
        position: relative;
    }
    
    .service-pill-input {
        position: absolute;
        opacity: 0;
        pointer-events: none;
    }
    
    .service-pill {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid #dddde0;
        border-radius: 999px;
        background: #ececef;
        color: #44474f;
        font-size: 14px;
        font-weight: 700;
        line-height: 1;
        padding: 8px 14px;
        cursor: pointer;
        user-select: none;
        transition: all 0.2s ease;
    }
    
    .service-pill-input:checked + .service-pill {
        background: #f8d8cb;
        border-color: #f0a98f;
        color: #74270e;
        box-shadow: 0 6px 14px rgba(198, 66, 18, 0.15);
    }
    
    .service-pill:hover {
        background: #e3e3e6;
    }
    
    .book-form-helper {
        margin: 6px 0 0;
        color: var(--muted-ink);
        font-size: 12px;
    }
    
    .book-form-container .alert {
        margin: 0 0 12px;
        border-radius: 12px;
    }
    
    .book-form-container .text-note {
        font-size: 12px;
        color: var(--muted-ink);
        text-align: center;
        margin-top: 10px;
        line-height: 1.45;
    }
    
    .book-form-actions {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        margin-top: 12px;
        padding-top: 12px;
        border-top: 1px solid var(--divider);
    }
    
    .book-form-container .btn-cancel {
        border: none;
        background: transparent;
        color: #6e6f75;
        font-weight: 700;
        padding: 10px 6px;
    }
    
    .book-form-container .btn-submit {
        background: linear-gradient(135deg, #ef7a0b 0%, #d86109 100%);
        color: #fff;
        border: none;
        border-radius: 999px;
        font-weight: 800;
        cursor: pointer;
        transition: transform 0.2s ease, box-shadow 0.2s ease, filter 0.2s ease;
        font-size: 15px;
        min-width: 180px;
        padding: 11px 20px;
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
    
    @media (max-width: 768px) {
        .book-form-body {
            padding: 12px;
        }
        
        .book-form-grid {
            grid-template-columns: 1fr;
            gap: 10px;
        }
        
        .book-form-section {
            padding: 11px;
        }
        
        .book-form-container .form-row {
            grid-template-columns: 1fr;
            gap: 12px;
        }
        
        .service-pill {
            font-size: 14px;
            padding: 8px 12px;
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
            <div class="book-form-grid">
                <section class="book-form-section">
                    <h3 class="book-form-section-title"><span class="section-icon">O</span>Owner Information</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="ownerName">Full Name</label>
                            <input type="text" class="form-control" id="ownerName" name="ownerName" value="${fn:escapeXml(param.ownerName)}" placeholder="e.g. Nguyen Van A" maxlength="100" title="1-100 characters. Letters (including Vietnamese), spaces, apostrophes, hyphens, and dots are allowed." required>
                        </div>
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" class="form-control" id="email" name="email" value="${fn:escapeXml(param.email)}" placeholder="name@example.com" maxlength="255" required>
                        </div>
                    </div>
                    <div class="form-row full">
                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" class="form-control" id="phone" name="phone" value="${fn:escapeXml(param.phone)}" placeholder="0123456789" pattern="0[0-9]{9}" title="10 digits starting with 0." maxlength="10" required>
                            <small id="phoneLookupStatus" class="book-form-helper">Phone is used to identify existing customer.</small>
                        </div>
                    </div>
                </section>

                <section class="book-form-section">
                    <h3 class="book-form-section-title"><span class="section-icon">P</span>Pet Information</h3>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="petName">Pet Name</label>
                            <input type="text" class="form-control" id="petName" name="petName" value="${fn:escapeXml(param.petName)}" placeholder="e.g. Luna" maxlength="100" title="1-100 characters. Letters (including Vietnamese), spaces, apostrophes, hyphens, and dots are allowed." required>
                        </div>
                        <div class="form-group">
                            <label for="petType">Pet Type</label>
                            <select class="form-control form-select" id="petType" name="petType" required>
                                <option value="" ${empty param.petType ? 'selected' : ''}>Select pet type</option>
                                <option value="Dog" ${param.petType eq 'Dog' ? 'selected' : ''}>Dog</option>
                                <option value="Cat" ${param.petType eq 'Cat' ? 'selected' : ''}>Cat</option>
                                <option value="Bird" ${param.petType eq 'Bird' ? 'selected' : ''}>Bird</option>
                                <option value="Rabbit" ${param.petType eq 'Rabbit' ? 'selected' : ''}>Rabbit</option>
                                <option value="Other" ${param.petType eq 'Other' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                    </div>
                </section>

                <section class="book-form-section wide">
                    <h3 class="book-form-section-title"><span class="section-icon">S</span>Service Selection</h3>
                    <div class="service-pills">
                        <c:if test="${not empty services}">
                            <c:forEach var="service" items="${services}">
                                <div class="service-pill-option">
                                    <input class="service-pill-input" type="checkbox" id="service_${service.serviceId}" name="serviceIds" value="${service.serviceId}"
                                    <c:forEach var="selectedServiceId" items="${paramValues.serviceIds}">
                                        <c:if test="${selectedServiceId eq service.serviceId}">checked</c:if>
                                        </c:forEach>>
                                        <label class="service-pill" for="service_${service.serviceId}">${service.name}</label>
                                    </div>
                                </c:forEach>
                            </c:if>
                        </div>
                        <p class="book-form-helper">Choose one or more services for this appointment.</p>
                    </section>

                    <section class="book-form-section wide">
                        <h3 class="book-form-section-title"><span class="section-icon">T</span>Scheduling</h3>
                        <div class="form-row">
                            <div class="form-group">
                                <label for="appointmentDate">Preferred Date</label>
                                <input type="date" class="form-control" id="appointmentDate" name="appointmentDate" value="${fn:escapeXml(param.appointmentDate)}" required>
                            </div>
                            <div class="form-group">
                                <label for="timeSlot">Preferred Slot</label>
                                <select class="form-control form-select" id="timeSlot" name="timeSlot" required>
                                    <option value="" ${empty param.timeSlot ? 'selected' : ''}>Choose a slot</option>
                                    <option value="morning" ${param.timeSlot eq 'morning' ? 'selected' : ''}>Morning </option>
                                    <option value="afternoon" ${param.timeSlot eq 'afternoon' ? 'selected' : ''}>Afternoon </option>
                                </select>
                            </div>
                        </div>
                    </section>
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
        // Service choices are always visible as selectable pills.
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
                    if ((phoneInput.value || '').trim().length >= 10) {
                        runLookup();
                    }
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
