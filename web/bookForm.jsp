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
    .book-form-container { padding: 20px; }
    .book-form-container .form-group { margin-bottom: 20px; }
    .book-form-container label { font-weight: 600; color: #1c140d; display: block; margin-bottom: 8px; font-size: 14px; }
    .book-form-container .form-control, .book-form-container .form-select {
        border: 1px solid #e8dbce; border-radius: 8px; padding: 10px 12px; font-size: 14px;
        transition: all 0.3s ease; background-color: #f8f7f5; width: 100%; box-sizing: border-box;
    }
    .book-form-container .form-control:focus, .book-form-container .form-select:focus {
        border-color: #f27c0d; box-shadow: 0 0 0 0.2rem rgba(242, 124, 13, 0.25); background-color: #fff; outline: none;
    }
    .book-form-container .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
    .book-form-container .form-row.full { grid-template-columns: 1fr; }
    .book-form-container .divider { border-top: 1px solid #f4ede7; margin: 20px 0; }
    .book-form-container .btn-submit {
        background: linear-gradient(135deg, #f27c0d 0%, #e07a0a 100%); color: white; padding: 12px 30px;
        border: none; border-radius: 8px; font-weight: 600; cursor: pointer; width: 100%; transition: all 0.3s ease; font-size: 16px;
    }
    .book-form-container .btn-submit:hover {
        background: linear-gradient(135deg, #e07a0a 0%, #d96809 100%); transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(242, 124, 13, 0.3);
    }
    .book-form-container .text-note { font-size: 12px; color: #5c4a3a; text-align: center; margin-top: 15px; line-height: 1.4; }
    .book-form-container .alert { margin-bottom: 15px; }
    @media (max-width: 768px) { .book-form-container .form-row { grid-template-columns: 1fr; } }
</style>

<div class="book-form-container">
    <% if ("1".equals(err) && msg != null && !msg.isEmpty()) { %>
    <div class="alert alert-danger" role="alert"><%= java.net.URLDecoder.decode(msg, "UTF-8") %></div>
    <% } %>
    <form id="appointmentForm" action="<%= ctx %>/book" method="post">
        <div class="form-row">
            <div class="form-group">
                <label for="ownerName">Owner Name *</label>
                <input type="text" class="form-control" id="ownerName" name="ownerName" placeholder="Enter full name" maxlength="100" pattern="[a-zA-Z\s]+" title="Letters and spaces only, 1-100 characters." required>
            </div>
            <div class="form-group">
                <label for="email">Email Address *</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="your@email.com" maxlength="255" required>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label for="phone">Phone Number *</label>
                <input type="tel" class="form-control" id="phone" name="phone" placeholder="0123456789 (10 digits, start with 0)" pattern="0[0-9]{9}" title="10 digits starting with 0." maxlength="10" required>
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
                <input type="text" class="form-control" id="petName" name="petName" placeholder="Your pet's name" maxlength="100" pattern="[a-zA-Z\s]+" title="Letters and spaces only, 1-100 characters." required>
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
        <div class="form-row full">
            <div class="form-group">
                <label for="notes">Additional Notes</label>
                <textarea class="form-control" id="notes" name="notes" placeholder="How can we help your pet today?" rows="3" maxlength="1000" style="resize: vertical;"></textarea>
            </div>
        </div>
        <button type="submit" class="btn-submit">Confirm Booking</button>
        <p class="text-note">By clicking confirm, you agree to our terms of service and privacy policy. We'll send a confirmation email shortly.</p>
    </form>
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
        dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(event) {
        var btn = document.getElementById('dropdownServiceBtn');
        var dropdown = document.getElementById('serviceDropdown');
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
