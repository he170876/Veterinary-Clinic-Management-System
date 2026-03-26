<%!
    String esc(String s) {
    if (s == null) return "";
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    if (c == '&') sb.append("&amp;");
    else if (c == '<') sb.append("&lt;");
    else if (c == '>') sb.append("&gt;");
    else if (c == '"') sb.append("&quot;");
    else sb.append(c);
    }
    return sb.toString();
    }
%>
<%
    Object userObj = request.getAttribute("user");
    model.User user = (userObj instanceof model.User) ? (model.User) userObj : null;
    if (user == null && session != null) {
        Object sessionUserObj = session.getAttribute("currentUser");
        if (sessionUserObj instanceof model.User) {
            user = (model.User) sessionUserObj;
        }
    }
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String ctx = request.getContextPath();
    String roleName = (user.getRole() != null && user.getRole().getRoleName() != null) ? user.getRole().getRoleName().trim() : "";
    String normalizedRole = roleName.toLowerCase().replace(" ", "").replace("_", "").replace("-", "");
    
    String roleSegment = "customer";
    if ("veterinarian".equals(normalizedRole) || "vet".equals(normalizedRole) || "veterinary".equals(normalizedRole)) {
        roleSegment = "vet";
        } else if ("receptionist".equals(normalizedRole) || "frontdesk".equals(normalizedRole)) {
            roleSegment = "Receptionist";
            } else if ("labstaff".equals(normalizedRole) || "lab".equals(normalizedRole) || "laboratory".equals(normalizedRole) || "labtechnician".equals(normalizedRole)) {
                roleSegment = "lab";
                } else if ("admin".equals(normalizedRole) || "clinicowner".equals(normalizedRole) || "owner".equals(normalizedRole) || "administrator".equals(normalizedRole)) {
                    roleSegment = "admin";
                }
                
                String basePath = "/" + roleSegment;
                boolean isCustomerRole = "customer".equalsIgnoreCase(roleSegment);
                boolean isVetRole = "vet".equalsIgnoreCase(roleSegment);
                boolean isLabRole = "lab".equalsIgnoreCase(roleSegment);
                boolean isReceptionistRole = "Receptionist".equals(roleSegment);
                boolean isAdminRole = "admin".equalsIgnoreCase(roleSegment);
                
                String dashboardUrl = ctx + "/customer/dashboard";
                if ("vet".equalsIgnoreCase(roleSegment)) {
                    dashboardUrl = ctx + "/vet/dashboard";
                    } else if ("Receptionist".equals(roleSegment)) {
                        dashboardUrl = ctx + "/Receptionist/Dashboard";
                        } else if ("lab".equalsIgnoreCase(roleSegment)) {
                            dashboardUrl = ctx + "/lab/labqueue";
                            } else if ("admin".equalsIgnoreCase(roleSegment)) {
                                dashboardUrl = ctx + "/owner/dashboard";
                            }
                            
                            String displayName = (user.getFullName() != null && !user.getFullName().isEmpty()) ? user.getFullName() : user.getEmail();
                            String err = request.getParameter("error");
                            String requiredParam = request.getParameter("required");
                            boolean requiredPhone = "phone".equals(requiredParam);
                            
                            request.setAttribute("customerCurrentPage", "edit-profile");
                            request.setAttribute("customerHeaderTitle", "Edit Profile");
                            request.setAttribute("customerHeaderSubtitle", "Update your personal info and contact details.");
                            request.setAttribute("customerHeaderDisplayName", displayName);
                            request.setAttribute("customerHeaderRoleText", (roleName == null || roleName.isEmpty()) ? "User" : roleName);
                            request.setAttribute("customerHeaderShowAvatar", "true");
                            request.setAttribute("profileBasePath", basePath);
                            request.setAttribute("customerHeaderActionUrl", dashboardUrl);
                            request.setAttribute("customerHeaderActionLabel", "Back to Dashboard");
                            request.setAttribute("customerHeaderActionIcon", "arrow_back");
                            
                            String profilePicUrl = user.getProfilePictureUrl();
                            boolean hasProfilePic = (profilePicUrl != null && !profilePicUrl.isEmpty());
                            if (hasProfilePic) {
                                request.setAttribute("customerHeaderAvatarUrl", ctx + profilePicUrl);
                            }
                            request.setAttribute("customerHeaderAvatarInitial", displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?");
                            
                            String editProfileAction = ctx + basePath + "/edit-profile";
                            String profileUrl = ctx + basePath + "/profile";
                        %>
                        <body class="<%= isLabRole ? "bg-surface text-on-surface antialiased" : "bg-background-light dark:bg-background-dark text-[#181111] dark:text-white font-display" %>">
                            <div class="flex min-h-screen overflow-hidden">
                                <% if (isCustomerRole) { %>
                                <jsp:include page="/WEB-INF/includes/customer-sidebar.jsp"/>
                                <% } else if (isVetRole) { %>
                                <%@ include file="/WEB-INF/views/vet/_sidebar.jspf" %>
                                <% } else if (isLabRole) {
                                    request.setAttribute("labSidebarActive", "profile");
                                %>
                                <%@ include file="/WEB-INF/views/lab/_lab-sidebar.jspf" %>
                                <% } else if (isReceptionistRole) { %>
                                <aside class="w-64 border-r border-slate-200 bg-white flex flex-col h-screen sticky top-0">
                                    <div class="p-6 flex items-center gap-3">
                                        <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
                                            <span class="material-symbols-outlined text-white">pets</span>
                                        </div>
                                        <span class="text-2xl font-bold tracking-tight">Anipat</span>
                                    </div>
                                    <nav class="flex-1 px-4 mt-4 space-y-1">
                                        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/Dashboard">
                                            <span class="material-symbols-outlined">dashboard</span>
                                            <span class="font-medium">Dashboard</span>
                                        </a>
                                        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/ViewListAppointment">
                                            <span class="material-symbols-outlined">calendar_today</span>
                                            <span class="font-medium">Schedule</span>
                                        </a>
                                        <a class="flex items-center gap-3 px-4 py-3 rounded-xl text-slate-500 hover:bg-slate-50 transition-colors" href="<%= ctx %>/Receptionist/ManageAppointmentRequests">
                                            <span class="material-symbols-outlined">pending_actions</span>
                                            <span class="font-medium">Request Center</span>
                                        </a>
                                        <a class="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-lg shadow-primary/20" href="<%= ctx %>/Receptionist/profile">
                                            <span class="material-symbols-outlined">person</span>
                                            <span class="font-medium">My Profile</span>
                                        </a>
                                    </nav>
                                </aside>
                                <% } else if (isAdminRole) { %>
                                <aside class="w-72 bg-white border-r border-[#e9d9ce] flex flex-col h-full">
                                    <div class="p-6 flex flex-col h-full">
                                        <div class="space-y-8">
                                            <div class="flex items-center gap-3 mb-8">
                                                <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                                                    <span class="material-symbols-outlined">pets</span>
                                                </div>
                                                <div class="flex flex-col">
                                                    <h1 class="text-lg font-bold leading-tight">Anipat</h1>
                                                    <p class="text-[#a17145] text-xs font-medium">Veterinary Clinic</p>
                                                </div>
                                            </div>
                                            <nav class="flex flex-col gap-2">
                                                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/dashboard">
                                                    <span class="material-symbols-outlined">dashboard</span>
                                                    <span class="text-sm font-semibold">Dashboard</span>
                                                </a>
                                                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/user-management">
                                                    <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">group</span>
                                                    <span class="text-sm font-semibold">User Management</span>
                                                </a>
                                                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/services">
                                                    <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">medical_services</span>
                                                    <span class="text-sm font-semibold">Services</span>
                                                </a>
                                                <a class="flex items-center gap-3 px-3 py-2.5 text-[#a17145] hover:bg-[#f4ede6] rounded-xl transition-all" href="<%= ctx %>/owner/images">
                                                    <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">image</span>
                                                    <span class="text-sm font-semibold">Images</span>
                                                </a>
                                                <a class="flex items-center gap-3 px-4 py-3 rounded-full bg-primary text-white transition-all" href="<%= ctx %>/owner/profile">
                                                    <span class="material-symbols-outlined">person</span>
                                                    <span class="text-sm font-bold">My Profile</span>
                                                </a>
                                            </nav>
                                        </div>
                                    </div>
                                </aside>
                                <% } %>

                                <main class="flex-1 flex flex-col overflow-y-auto<%= isLabRole ? " ml-64" : "" %>">
                                    <% if (isCustomerRole) { %>
                                    <jsp:include page="/WEB-INF/includes/customer-header.jsp"/>
                                    <% } else if (isVetRole) { %>
                                    <header class="h-16 flex items-center justify-between px-8 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 z-10">
                                        <div class="flex items-center gap-2 min-w-0">
                                            <span class="material-symbols-outlined text-primary shrink-0">stethoscope</span>
                                            <div class="min-w-0">
                                                <h2 class="text-lg font-bold text-slate-900 dark:text-slate-100 truncate">Edit Profile</h2>
                                                <p class="text-xs text-slate-500 dark:text-slate-400 truncate"><%= roleName == null || roleName.isEmpty() ? "Veterinarian" : roleName %></p>
                                            </div>
                                        </div>
                                        <%@ include file="/WEB-INF/includes/vet-header-right.jspf" %>
                                    </header>
                                    <% } else if (isLabRole) { %>
                                    <header class="fixed top-0 right-0 left-64 h-16 z-40 bg-stone-50/80 dark:bg-stone-950/80 backdrop-blur-md flex justify-between items-center px-8 border-b border-stone-100/80">
                                        <div class="flex items-center gap-6 min-w-0">
                                            <h1 class="text-lg font-black uppercase tracking-widest text-stone-900 dark:text-stone-50 font-headline truncate">Edit Profile</h1>
                                            <div class="h-4 w-px bg-stone-300 shrink-0"></div>
                                            <span class="text-xs font-bold text-stone-500 truncate max-w-[200px]"><%= roleName == null || roleName.isEmpty() ? "Lab Technician" : roleName %></span>
                                        </div>
                                        <div class="flex items-center gap-6 shrink-0">
                                            <%@ include file="/WEB-INF/includes/lab-header-right.jspf" %>
                                        </div>
                                    </header>
                                    <% } else { %>
                                    <header class="h-16 border-b border-slate-200 bg-white flex items-center justify-between px-8 sticky top-0 z-10">
                                        <div>
                                            <h2 class="text-lg font-bold text-slate-800">Edit Profile</h2>
                                            <p class="text-xs text-slate-500"><%= roleName == null || roleName.isEmpty() ? "User" : roleName %></p>
                                        </div>
                                        <div class="flex items-center gap-4">
                                            <%@ include file="/WEB-INF/includes/notifications-dropdown.jsp" %>
                                            <div class="relative">
                                                <button type="button" id="role-profile-toggle" class="w-10 h-10 rounded-full overflow-hidden focus:outline-none bg-primary/10 text-primary flex items-center justify-center">
                                                    <% if (hasProfilePic) { %>
                                                    <img alt="Profile" class="w-full h-full object-cover" src="<%= ctx %><%= profilePicUrl %>"/>
                                                    <% } else { %>
                                                    <span class="font-semibold"><%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %></span>
                                                    <% } %>
                                                </button>
                                                <div id="role-profile-menu" class="absolute right-0 mt-2 w-48 origin-top-right rounded-xl bg-white shadow-lg border border-slate-200 z-50" style="display:none;">
                                                    <a href="<%= ctx %><%= basePath %>/profile" class="block px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 rounded-t-xl">My Profile</a>
                                                    <a href="<%= ctx %>/logout" class="block px-4 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 rounded-b-xl">Sign out</a>
                                                </div>
                                            </div>
                                        </div>
                                    </header>
                                    <% } %>
                                    <div class="<%= isLabRole ? "pt-24 px-8 pb-12 max-w-5xl mx-auto w-full flex-1 overflow-y-auto" : "p-8 max-w-5xl mx-auto w-full" %>">
                                        <div class="flex items-center gap-2 mb-6">
                                            <a class="text-[#896461] text-sm font-medium hover:text-primary transition-colors" href="<%= dashboardUrl %>">Dashboard</a>
                                            <span class="material-symbols-outlined text-[#896461] text-base leading-none">chevron_right</span>
                                            <a class="text-[#896461] text-sm font-medium hover:text-primary transition-colors" href="<%= profileUrl %>">My Profile</a>
                                            <span class="material-symbols-outlined text-[#896461] text-base leading-none">chevron_right</span>
                                            <span class="text-[#181111] dark:text-white text-sm font-bold">Edit Profile</span>
                                        </div>

                                        <% if (requiredPhone) { %>
                                        <div class="mb-6 p-4 rounded-xl bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 text-amber-800 dark:text-amber-200 text-sm font-semibold flex items-center gap-2">
                                            <span class="material-symbols-outlined">warning</span>
                                            You must add your phone number to continue. Phone is required for all accounts.
                                        </div>
                                        <% } %>

                                        <% if (err != null && !err.isEmpty()) { %>
                                        <div class="mb-6 p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 text-sm">
                                            <%= java.net.URLDecoder.decode(err, "UTF-8") %>
                                        </div>
                                        <% } %>

                                        <div class="bg-white dark:bg-[#1a0d0c] rounded-2xl border border-[#e6dcdb] dark:border-[#3d2a29] overflow-hidden shadow-sm">
                                            <div class="p-8">
                                                <form method="post" action="<%= editProfileAction %>" enctype="multipart/form-data" class="space-y-6">
                                                    <div class="flex flex-col md:flex-row md:items-center gap-6 mb-10 pb-10 border-b border-[#f4f0f0] dark:border-[#2d1a19]">
                                                        <div class="relative group">
                                                            <div id="profilePhotoPreview" class="w-32 h-32 rounded-full ring-4 ring-background-light dark:ring-[#2d1a19] overflow-hidden flex items-center justify-center bg-primary/10 text-primary font-bold text-4xl shrink-0">
                                                                <% if (hasProfilePic) { %>
                                                                <img src="<%= ctx %><%= esc(profilePicUrl) %>" alt="Profile" class="w-full h-full object-cover" id="profilePhotoImg"/>
                                                                <% } else { %>
                                                                <span id="profilePhotoInitial"><%= displayName.length() > 0 ? displayName.substring(0, 1).toUpperCase() : "?" %></span>
                                                                <% } %>
                                                            </div>
                                                            <label class="absolute bottom-0 right-0 flex items-center justify-center size-10 rounded-full bg-primary text-white cursor-pointer shadow-lg hover:bg-primary/90 transition-colors" title="Change photo">
                                                                <span class="material-symbols-outlined text-xl">photo_camera</span>
                                                                <input type="file" name="profilePicture" id="profilePictureInput" accept="image/jpeg,image/png,image/gif" class="hidden"/>
                                                            </label>
                                                        </div>
                                                        <div class="flex-1 space-y-2">
                                                            <h3 class="text-xl font-bold text-[#181111] dark:text-white">Profile Photo</h3>
                                                            <p class="text-[#896461] text-sm">JPG, PNG or GIF. Max 2 MB.</p>
                                                            <% if (hasProfilePic) { %>
                                                            <label class="inline-flex items-center gap-2 text-sm text-[#896461] hover:text-red-600 cursor-pointer mt-2">
                                                                <input type="checkbox" name="removePhoto" value="1" class="rounded border-[#e6dcdb] text-primary focus:ring-primary"/>
                                                                <span>Remove current photo</span>
                                                            </label>
                                                            <% } %>
                                                        </div>
                                                    </div>

                                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                                        <div class="flex flex-col gap-2">
                                                            <label class="text-[#181111] dark:text-white text-sm font-bold">Full Name <span class="text-red-500">*</span></label>
                                                            <div class="relative">
                                                                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">person</span>
                                                                <input name="fullName" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="text" value="<%= esc(user.getFullName() != null ? user.getFullName() : "") %>" minlength="1" maxlength="30" pattern="[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF\s]{1,30}" title="1-30 characters, letters and spaces only (any language)." required/>
                                                            </div>
                                                            <p class="text-xs text-[#896461]">1-30 characters, letters and spaces only.</p>
                                                        </div>

                                                        <div class="flex flex-col gap-2">
                                                            <label class="text-[#181111] dark:text-white text-sm font-bold">Phone Number <%= requiredPhone ? "<span class=\"text-red-500\">*</span>" : "" %></label>
                                                            <div class="relative">
                                                                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">call</span>
                                                                <input name="phone" class="w-full h-12 pl-10 pr-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white" type="tel" value="<%= esc(user.getPhone() != null ? user.getPhone() : "") %>" pattern="0[0-9]{9}" title="10 digits starting with 0 (e.g. 0123456789)." placeholder="0123456789" <%= requiredPhone ? "required" : "" %>/>
                                                            </div>
                                                            <p class="text-xs text-[#896461]">10 digits, must start with 0.<%= requiredPhone ? " Required to continue." : "" %></p>
                                                        </div>

                                                        <div class="flex flex-col gap-2 md:col-span-2">
                                                            <label class="text-[#181111] dark:text-white text-sm font-bold">Email Address</label>
                                                            <div class="relative">
                                                                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#896461] text-xl">mail</span>
                                                                <input class="w-full h-12 pl-10 pr-4 bg-[#f8f6f6] dark:bg-[#2d1a19] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl text-[#896461] cursor-not-allowed" type="email" value="<%= esc(user.getEmail() != null ? user.getEmail() : "") %>" readonly/>
                                                            </div>
                                                            <p class="text-[#896461] text-xs">Email cannot be changed.</p>
                                                        </div>

                                                        <div class="flex flex-col gap-2 md:col-span-2">
                                                            <label class="text-[#181111] dark:text-white text-sm font-bold">Address</label>
                                                            <textarea name="address" class="w-full p-4 bg-white dark:bg-[#1a0d0c] border border-[#e6dcdb] dark:border-[#3d2a29] rounded-xl focus:ring-2 focus:ring-primary focus:border-primary transition-all text-[#181111] dark:text-white resize-none" rows="3" maxlength="500"><%= esc(user.getAddress() != null ? user.getAddress() : "") %></textarea>
                                                            <p class="text-xs text-[#896461]">Optional. Max 500 characters.</p>
                                                        </div>
                                                    </div>

                                                    <div class="flex items-center justify-end gap-3 pt-4 border-t border-[#f4f0f0] dark:border-[#2d1a19]">
                                                        <a href="<%= profileUrl %>" class="px-6 h-11 border border-[#e6dcdb] dark:border-[#3d2a29] text-[#181111] dark:text-white font-bold rounded-xl hover:bg-white dark:hover:bg-[#2d1a19] transition-all inline-flex items-center justify-center">Cancel</a>
                                                        <button type="submit" class="px-8 h-11 bg-primary text-white font-bold rounded-xl hover:bg-primary/90 shadow-lg shadow-primary/20 transition-all">Save Changes</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </main>
                            </div>

                            <script>
                                (function() {
                                    var input = document.getElementById('profilePictureInput');
                                    var preview = document.getElementById('profilePhotoPreview');
                                    if (!input || !preview) return;
                                    
                                    input.addEventListener('change', function() {
                                        var file = this.files && this.files[0];
                                        if (!file || !file.type.match(/^image\/(jpeg|png|gif)$/)) return;
                                        
                                        var img = preview.querySelector('#profilePhotoImg');
                                        var initial = preview.querySelector('#profilePhotoInitial');
                                        var reader = new FileReader();
                                        
                                        reader.onload = function(e) {
                                            if (img) {
                                                img.src = e.target.result;
                                                } else {
                                                    img = document.createElement('img');
                                                    img.id = 'profilePhotoImg';
                                                    img.alt = 'Profile';
                                                    img.className = 'w-full h-full object-cover';
                                                    img.src = e.target.result;
                                                    if (initial) initial.remove();
                                                    preview.appendChild(img);
                                                }
                                                if (initial) initial.style.display = 'none';
                                            };
                                            
                                            reader.readAsDataURL(file);
                                        });
                                    })();
                                </script>
                                <% if (isVetRole) { %>
                                <%@ include file="/WEB-INF/includes/vet-header-right-script.jspf" %>
                                <% } else if (isLabRole) { %>
                                <%@ include file="/WEB-INF/includes/lab-header-right-script.jspf" %>
                                <% } else if (!isCustomerRole) { %>
                                <script>
                                    (function() {
                                        var toggle = document.getElementById('role-profile-toggle');
                                        var menu = document.getElementById('role-profile-menu');
                                        if (!toggle || !menu) return;
                                        toggle.addEventListener('click', function(e) {
                                            e.stopPropagation();
                                            menu.style.display = (menu.style.display === 'none' || menu.style.display === '') ? 'block' : 'none';
                                        });
                                        document.addEventListener('click', function(e) {
                                            if (!menu.contains(e.target) && !toggle.contains(e.target)) {
                                                menu.style.display = 'none';
                                            }
                                        });
                                    })();
                                </script>
                                <% } %>
                            </body>