<%--
    Document   : bookForm.jsp
    Booking form fragment - included in index.jsp modal.
--%>
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
                <input type="text" class="form-control" id="ownerName" name="ownerName" placeholder="Enter full name" required>
            </div>
            <div class="form-group">
                <label for="email">Email Address *</label>
                <input type="email" class="form-control" id="email" name="email" placeholder="your@email.com" required>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label for="phone">Phone Number *</label>
                <input type="tel" class="form-control" id="phone" name="phone" placeholder="+1 (555) 000-0000" required>
            </div>
            <div class="form-group">
                <label for="service">Select Service *</label>
                <select class="form-control form-select" id="service" name="service" required>
                    <option value="">Choose a service</option>
                    <option value="Health Checkups">Health Checkups</option>
                    <option value="Vaccinations">Vaccinations</option>
                    <option value="Pet Boarding">Pet Boarding</option>
                    <option value="Healthy Meals">Healthy Meals</option>
                    <option value="Pet Spa & Grooming">Pet Spa & Grooming</option>
                    <option value="Dental Care">Dental Care</option>
                    <option value="Emergency Services">Emergency Services</option>
                </select>
            </div>
        </div>
        <div class="divider"></div>
        <div class="form-row">
            <div class="form-group">
                <label for="petName">Pet Name *</label>
                <input type="text" class="form-control" id="petName" name="petName" placeholder="Your pet's name" required>
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
                <label for="appointmentTime">Preferred Time *</label>
                <input type="time" class="form-control" id="appointmentTime" name="appointmentTime" required>
            </div>
        </div>
        <div class="form-row full">
            <div class="form-group">
                <label for="notes">Additional Notes</label>
                <textarea class="form-control" id="notes" name="notes" placeholder="How can we help your pet today?" rows="3" style="resize: vertical;"></textarea>
            </div>
        </div>
        <button type="submit" class="btn-submit">Confirm Booking</button>
        <p class="text-note">By clicking confirm, you agree to our terms of service and privacy policy. We'll send a confirmation email shortly.</p>
    </form>
</div>
