<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User,model.MedicalRecord,java.time.format.DateTimeFormatter" %>
<%
    User user = (User) request.getAttribute("user");
    MedicalRecord record = (MedicalRecord) request.getAttribute("medicalRecord");
    
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (record == null) {
        response.sendRedirect(request.getContextPath() + "/customer/medical-history");
        return;
    }
    
    String ctx = request.getContextPath();
    String visitDate = record.getVisitDate() != null
            ? record.getVisitDate().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' hh:mm a"))
            : "N/A";
    String petName = (record.getPet() != null && record.getPet().getName() != null)
            ? record.getPet().getName() : "N/A";
    String species = (record.getPet() != null && record.getPet().getSpecies() != null)
            ? record.getPet().getSpecies() : "N/A";
    String breed = (record.getPet() != null && record.getPet().getBreed() != null)
            ? record.getPet().getBreed() : "N/A";
    String vetName = (record.getVeterinarianName() != null && !record.getVeterinarianName().trim().isEmpty())
            ? record.getVeterinarianName() : "N/A";
    String diagnosis = (record.getDiagnosis() != null && !record.getDiagnosis().trim().isEmpty())
            ? record.getDiagnosis() : "No diagnosis recorded";
    String treatment = (record.getTreatment() != null && !record.getTreatment().trim().isEmpty())
            ? record.getTreatment() : "No treatment recorded";
    String note = (record.getNote() != null && !record.getNote().trim().isEmpty())
            ? record.getNote() : "No additional notes";
    String visitStatus = record.getVisitStatus() != null ? record.getVisitStatus() : "Unknown";
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Medical Record Details - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ff7b00",
                        "background-light": "#f8f7f5",
                        "background-dark": "#23190f",
                    },
                    fontFamily: { "display": ["Public Sans", "sans-serif"] },
                },
            },
        }
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark font-display text-[#181410] dark:text-[#f8f7f5]">
<div class="flex h-screen overflow-hidden">
    <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
    
    <main class="flex-1 flex flex-col overflow-y-auto">
        <header class="flex items-center justify-between bg-white dark:bg-[#2d2116] border-b border-[#f5f2f0] dark:border-[#3d2f23] px-8 py-4 sticky top-0 z-10">
            <div class="flex items-center gap-4">
                <a href="<%= ctx %>/customer/medical-history" class="p-2 hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] rounded-lg transition-colors">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <div>
                    <h2 class="text-xl font-bold tracking-tight">Medical Record Details</h2>
                    <p class="text-sm text-[#8d755e]">Record #<%= record.getRecordId() %></p>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <div class="text-right">
                    <p class="text-sm font-bold"><%= user.getFullName() != null ? user.getFullName() : user.getEmail() %></p>
                    <p class="text-xs text-[#8d755e]">Pet Parent</p>
                </div>
            </div>
        </header>

        <div class="p-8 max-w-5xl mx-auto w-full space-y-6">
            <!-- Visit Info Card -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-start justify-between mb-6">
                    <div>
                        <h3 class="text-lg font-bold mb-1">Visit Information</h3>
                        <p class="text-sm text-[#8d755e]"><%= visitDate %></p>
                    </div>
                    <span class="px-3 py-1.5 rounded-full text-xs font-bold <%= visitStatus.equals("Completed") ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400" %>">
                        <%= visitStatus %>
                    </span>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="flex items-start gap-3">
                        <div class="p-2 bg-primary/10 rounded-lg">
                            <span class="material-symbols-outlined text-primary">pets</span>
                        </div>
                        <div>
                            <p class="text-xs text-[#8d755e] uppercase font-bold mb-1">Patient</p>
                            <p class="font-semibold"><%= petName %></p>
                            <p class="text-sm text-[#8d755e]"><%= species %> • <%= breed %></p>
                        </div>
                    </div>
                    
                    <div class="flex items-start gap-3">
                        <div class="p-2 bg-primary/10 rounded-lg">
                            <span class="material-symbols-outlined text-primary">medical_services</span>
                        </div>
                        <div>
                            <p class="text-xs text-[#8d755e] uppercase font-bold mb-1">Veterinarian</p>
                            <p class="font-semibold"><%= vetName %></p>
                            <p class="text-sm text-[#8d755e]">Attending Doctor</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Diagnosis Card -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">diagnosis</span>
                    <h3 class="text-lg font-bold">Diagnosis</h3>
                </div>
                <div class="bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-900/30 rounded-lg p-4">
                    <p class="text-sm text-[#181410] dark:text-[#f8f7f5] leading-relaxed"><%= diagnosis %></p>
                </div>
            </div>

            <!-- Treatment Card -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">medication</span>
                    <h3 class="text-lg font-bold">Treatment & Procedures</h3>
                </div>
                <div class="bg-green-50 dark:bg-green-900/10 border border-green-200 dark:border-green-900/30 rounded-lg p-4">
                    <p class="text-sm text-[#181410] dark:text-[#f8f7f5] leading-relaxed whitespace-pre-line"><%= treatment %></p>
                </div>
            </div>

            <!-- Additional Notes Card -->
            <div class="bg-white dark:bg-[#2d2116] rounded-xl border border-[#f5f2f0] dark:border-[#3d2f23] p-6">
                <div class="flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary">note</span>
                    <h3 class="text-lg font-bold">Additional Notes</h3>
                </div>
                <div class="bg-[#fcfbf9] dark:bg-[#34281d] border border-[#f5f2f0] dark:border-[#3d2f23] rounded-lg p-4">
                    <p class="text-sm text-[#8d755e] leading-relaxed whitespace-pre-line"><%= note %></p>
                </div>
            </div>

            <!-- Actions -->
            <div class="flex justify-between items-center pt-4">
                <a href="<%= ctx %>/customer/medical-history" 
                   class="inline-flex items-center gap-2 px-6 py-3 bg-white dark:bg-[#2d2116] border border-[#f5f2f0] dark:border-[#3d2f23] rounded-xl hover:bg-[#f5f2f0] dark:hover:bg-[#3d2f23] transition-colors font-medium">
                    <span class="material-symbols-outlined">arrow_back</span>
                    Back to History
                </a>
                
                <button onclick="window.print()" 
                        class="inline-flex items-center gap-2 px-6 py-3 bg-primary text-white rounded-xl hover:bg-orange-600 transition-colors font-medium">
                    <span class="material-symbols-outlined">print</span>
                    Print Record
                </button>
            </div>
        </div>
    </main>
</div>
</body>
</html>
