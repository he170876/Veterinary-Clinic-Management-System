<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.MedicalRecord, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    List<MedicalRecord> recentMedicalRecords = (List<MedicalRecord>) request.getAttribute("recentMedicalRecords");
    Integer petCount = (Integer) request.getAttribute("petCount");
    Integer appointmentCount = (Integer) request.getAttribute("appointmentCount");
    Integer medicalRecordCount = (Integer) request.getAttribute("medicalRecordCount");
    if (petCount == null) petCount = 0;
    if (appointmentCount == null) appointmentCount = 0;
    if (medicalRecordCount == null) medicalRecordCount = 0;
    if (recentMedicalRecords == null) recentMedicalRecords = new java.util.ArrayList<>();
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("customerCurrentPage", "dashboard");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Dashboard - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "primary-dark": "#d6362b",
                        "background-light": "#f8f7f5",
                        "background-dark": "#23190f",
                    },
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                },
            },
        }
    </script>
    <style>
        body { font-family: 'Manrope', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark font-display min-h-screen">
<div class="flex min-h-screen">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-w-0 overflow-y-auto">
    <div class="max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        <!-- Welcome Banner -->
        <div class="bg-gradient-to-r from-primary to-red-400 rounded-2xl p-8 text-white mb-8">
            <h1 class="text-3xl font-bold mb-2">Welcome back, <%= user.getFullName() %>!</h1>
            <p class="text-white/90">Manage your pets, appointments, and medical records all in one place.</p>
        </div>

        <!-- Quick Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">pets</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900"><%= petCount %></p>
                        <p class="text-sm text-gray-500">My Pets</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-green-100 text-green-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">calendar_month</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900"><%= appointmentCount %></p>
                        <p class="text-sm text-gray-500">Appointments</p>
                    </div>
                </div>
            </div>
            <div class="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                <div class="flex items-center gap-4">
                    <div class="size-12 bg-purple-100 text-purple-600 rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">medical_information</span>
                    </div>
                    <div>
                        <p class="text-2xl font-bold text-gray-900"><%= medicalRecordCount %></p>
                        <p class="text-sm text-gray-500">Medical Records</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <h2 class="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <a href="<%= ctx %>/pets?action=create" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">add</span>
                </div>
                <span class="font-semibold text-gray-700">Add Pet</span>
            </a>
            <a href="<%= ctx %>/customer/appointments/book" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">event</span>
                </div>
                <span class="font-semibold text-gray-700">Book Appointment</span>
            </a>
            <a href="<%= ctx %>/customer/medical-history" class="flex items-center gap-3 bg-white rounded-xl p-4 shadow-sm border border-gray-100 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">history</span>
                </div>
                <span class="font-semibold text-gray-700">Medical Records</span>
            </a>
            <a href="<%= ctx %>/customer/profile" class="flex items-center gap-3 bg-white dark:bg-white/5 rounded-xl p-4 shadow-sm border border-gray-100 dark:border-white/10 hover:border-primary hover:shadow-md transition-all">
                <div class="size-10 bg-primary/10 text-primary rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">person</span>
                </div>
                <span class="font-semibold text-gray-700">My Profile</span>
            </a>
        </div>

        <!-- Recent Medical Records -->
        <% if (!recentMedicalRecords.isEmpty()) { %>
        <div class="mb-8">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-xl font-bold text-gray-900">Recent Medical Records</h2>
                <a href="<%= ctx %>/customer/medical-history" class="text-primary hover:text-primary/80 text-sm font-semibold">View All →</a>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <% 
                    int recordCount = 0;
                    for (MedicalRecord record : recentMedicalRecords) {
                        if (recordCount >= 4) break;
                        String visitDate = record.getVisitDate() != null ? 
                            record.getVisitDate().format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) : "N/A";
                %>
                <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
                    <div class="flex items-start justify-between mb-3">
                        <div>
                            <p class="text-sm font-semibold text-gray-900"><%= record.getPet() != null ? record.getPet().getName() : "Pet" %></p>
                            <p class="text-xs text-gray-500"><%= visitDate %></p>
                        </div>
                        <span class="px-2 py-1 bg-green-100 text-green-700 text-xs font-medium rounded">
                            <%= record.getVisitStatus() != null ? record.getVisitStatus() : "Completed" %>
                        </span>
                    </div>
                    <% if (record.getDiagnosis() != null && !record.getDiagnosis().isEmpty()) { %>
                    <p class="text-xs text-gray-600 mb-2"><strong>Diagnosis:</strong> <%= record.getDiagnosis() %></p>
                    <% } %>
                    <% if (record.getVeterinarianName() != null && !record.getVeterinarianName().isEmpty()) { %>
                    <p class="text-xs text-gray-500">Dr. <%= record.getVeterinarianName() %></p>
                    <% } %>
                </div>
                <% 
                        recordCount++;
                    }
                %>
            </div>
        </div>
        <% } %>

        <!-- Account Info -->
        <div class="mt-8 bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <h2 class="text-lg font-bold text-gray-900 mb-4">Account Information</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="text-sm text-gray-500">Full Name</label>
                    <p class="font-medium text-gray-900"><%= user.getFullName() %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Email</label>
                    <p class="font-medium text-gray-900"><%= user.getEmail() %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Phone</label>
                    <p class="font-medium text-gray-900"><%= user.getPhone() != null ? user.getPhone() : "Not set" %></p>
                </div>
                <div>
                    <label class="text-sm text-gray-500">Account Status</label>
                    <p class="font-medium text-green-600"><%= user.getStatus() %></p>
                </div>
            </div>
        </div>
    </div>
    </main>
</div>
</body>
</html>
