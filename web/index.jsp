<%--
Document   : index.jsp
Anipats landing page - VCMS (Tailwind design)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="service.ContentService"%>
<%@page import="service.ImageService"%>
<%@page import="dao.ServiceDAO"%>
<%@page import="dao.impl.ServiceJdbcDAO"%>
<%@page import="service.impl.ContentServiceImpl"%>
<%@page import="service.impl.ImageServiceImpl"%>
<%@page import="model.Image"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%!
    private String esc(String value) {
    if (value == null) {
    return "";
    }
    return value.replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("\"", "&quot;")
    .replace("'", "&#39;");
    }
    
    private boolean isOwnerOrAdminRole(Integer roleId) {
    return roleId != null && (roleId == 5 || roleId == 6);
    }
    
    private String toPageUrl(String contextPath, String rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty()) {
    return "";
    }
    if (rawUrl.startsWith("http://") || rawUrl.startsWith("https://")) {
    return rawUrl;
    }
    if (rawUrl.startsWith("/")) {
    return contextPath + rawUrl;
    }
    return contextPath + "/" + rawUrl;
    }
%>
<%
    String ctx = request.getContextPath();
    Object currentUser = (session == null) ? null : session.getAttribute("currentUser");
    boolean loggedIn = (currentUser != null);
    String userDisplayName = null;
    String roleDashboardUrl = null;
    Integer currentRoleId = null;
    if (currentUser != null && currentUser instanceof model.User) {
        model.User loggedUser = (model.User) currentUser;
        String fn = loggedUser.getFullName();
        if (fn != null && !fn.isEmpty()) userDisplayName = fn; else userDisplayName = loggedUser.getEmail();
        
        int roleId = (loggedUser.getRole() != null) ? loggedUser.getRole().getRoleId() : 0;
        currentRoleId = roleId;
        switch (roleId) {
            case 5: // Admin
            case 6: // ClinicOwner
            roleDashboardUrl = ctx + "/owner/dashboard";
            break;
            case 2: // Veterinarian
            roleDashboardUrl = ctx + "/vet/dashboard";
            break;
        case 3: // Receptionist
            roleDashboardUrl = ctx + "/Receptionist/Dashboard";
            break;
            case 4: // LabStaff
            roleDashboardUrl = ctx + "/lab/labqueue";
            break;
            case 1: // Customer
            default:
            roleDashboardUrl = ctx + "/customer/dashboard";
            break;
        }
    }
    String booked = request.getParameter("booked");
    String bookErr = request.getParameter("bookError");
    String bookMsg = request.getParameter("bookMessage");
    String forbidden = request.getParameter("forbidden");
    
    ContentService contentService = new ContentServiceImpl();
    String contentLocaleParam = request.getParameter("contentLocale");
    final String contentLocale = (contentLocaleParam == null || contentLocaleParam.trim().isEmpty())
    ? ContentService.DEFAULT_LOCALE
    : contentLocaleParam.trim().toLowerCase();
    boolean contentDraftMode = "draft".equalsIgnoreCase(request.getParameter("contentMode"))
    && isOwnerOrAdminRole(currentRoleId);
    java.util.function.BiFunction<String, String, String> txt = (key, fallback)
    -> contentService.getTextValue(key, contentLocale, contentDraftMode, fallback);
    
    // Load images from database
    ImageService imageService = new ImageServiceImpl();
    List<Image> aboutImages = imageService.getImagesBySection("about");
    Image aboutImage1 = null, aboutImage2 = null;
    if (!aboutImages.isEmpty()) {
        if (aboutImages.size() >= 1) aboutImage1 = aboutImages.get(0);
        if (aboutImages.size() >= 2) aboutImage2 = aboutImages.get(1);
    }
    
    List<Image> teamMembers = imageService.getImagesBySection("team");
    if (teamMembers == null) {
        teamMembers = java.util.Collections.emptyList();
    }
    
    String[] fallbackTeamUrls = new String[] {
        "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=900&q=80",
        "https://images.unsplash.com/photo-1594824476967-48c8b964273f?auto=format&fit=crop&w=900&q=80",
        "https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=900&q=80",
        "https://images.unsplash.com/photo-1612531385446-f7b6b8f2b2c3?auto=format&fit=crop&w=900&q=80"
    };
    
    List<Map<String, String>> teamCards = new ArrayList<>();
    for (int i = 0; i < 4; i++) {
        Image member = i < teamMembers.size() ? teamMembers.get(i) : null;
        
        String fallbackUrl = (member != null && member.getUrl() != null && !member.getUrl().isEmpty())
        ? member.getUrl()
        : fallbackTeamUrls[i];
        
        String fallbackAlt = (member != null && member.getAltText() != null && !member.getAltText().trim().isEmpty())
        ? member.getAltText().trim()
        : "Veterinary specialist";
        
        String fallbackName = (member != null && member.getTitle() != null && !member.getTitle().trim().isEmpty())
        ? member.getTitle().trim()
        : "Team Member " + (i + 1);
        
        String fallbackRole = (member != null && member.getAltText() != null && !member.getAltText().trim().isEmpty())
        ? member.getAltText().trim()
        : "Veterinary Specialist";
        
        String nameKey = "home.team.card" + (i + 1) + ".name";
        String roleKey = "home.team.card" + (i + 1) + ".role";
        String cardName = txt.apply(nameKey, fallbackName);
        String cardRole = txt.apply(roleKey, fallbackRole);
        
        String imageKey = "home.team.card" + (i + 1) + ".image";
        String resolvedUrl = contentService.getImageUrl(imageKey, contentLocale, contentDraftMode, fallbackUrl);
        String resolvedAlt = contentService.getImageAlt(imageKey, contentLocale, contentDraftMode, fallbackAlt);
        
        Map<String, String> card = new HashMap<>();
        card.put("url", toPageUrl(ctx, resolvedUrl));
        card.put("alt", resolvedAlt == null ? "" : resolvedAlt);
        card.put("name", cardName);
        card.put("role", cardRole == null ? "" : cardRole);
        teamCards.add(card);
    }
    pageContext.setAttribute("teamCards", teamCards);
    
    // Load banner image
    List<Image> bannerImages = imageService.getImagesBySection("banner");
    Image bannerImage = null;
    if (bannerImages != null && !bannerImages.isEmpty()) {
        bannerImage = bannerImages.get(0);
    }
    
    String fallbackHeroBannerUrl = (bannerImage != null && bannerImage.getUrl() != null && !bannerImage.getUrl().isEmpty())
    ? bannerImage.getUrl()
    : "https://lh3.googleusercontent.com/aida-public/AB6AXuA0peKeNrR7ZPcWqE4RM4tNr4ABNGOvAqF-Me1QnxmebyVR_wy7ZV06sPHOoVbqSd-QGM9zIld1Oq6WwbFNBb59Oi9XPAAOxqIbU3QsyhOwc6Qg7X6Jcxzp0Xda9dbPL30jevM5UEGl0HbHEDjqGXxUBxaCVg0HgpSbUUQOE0b04Bs1TcQOAe4vitRgvPbLEs9Gh0Vgjq0C6oQcxkzuCF349FWDqRHGCFQQGkZn7MtNIDpe-Jqbf78_I-ENZl6mthNlK-R0Fwono";
    String fallbackHeroBannerAlt = (bannerImage != null && bannerImage.getAltText() != null && !bannerImage.getAltText().isEmpty())
    ? bannerImage.getAltText()
    : "Golden retriever dog smiling at camera";
    
    String heroBannerUrl = contentService.getImageUrl("home.hero.banner.image", contentLocale, contentDraftMode, fallbackHeroBannerUrl);
    String heroBannerAlt = contentService.getImageAlt("home.hero.banner.image", contentLocale, contentDraftMode, fallbackHeroBannerAlt);
    
    String fallbackAbout1Url = (aboutImage1 != null && aboutImage1.getUrl() != null && !aboutImage1.getUrl().isEmpty())
    ? aboutImage1.getUrl()
    : "https://lh3.googleusercontent.com/aida-public/AB6AXuDRHpM5upZqAjs8hXOnwYkwn5ci2i4FHDPOZOfR56qHFy2Zs09Cyp4LjPzpZQsPjmkFoRLiz8Pxi20BidHyMZf1t632noJBopC5ApWhGXGTninYcd-TmgCwyhiuXYKaFYkb_SlWaBzIgQhnwTs4J3Qnf3xLRgCkV4hGTEXorSTl-RZ5SZ1DZhn9HOjKbltXfE7UK-qvkaQIZw-uAncIeXmcZPX5wQwTjDkcUa_48maJ6vlN5V3S05rx013byYo3JFMce36Nonup_xQ";
    String fallbackAbout1Alt = (aboutImage1 != null && aboutImage1.getAltText() != null && !aboutImage1.getAltText().isEmpty())
    ? aboutImage1.getAltText()
    : "Vet examining a cat";
    String about1Url = contentService.getImageUrl("home.about.image.1", contentLocale, contentDraftMode, fallbackAbout1Url);
    String about1Alt = contentService.getImageAlt("home.about.image.1", contentLocale, contentDraftMode, fallbackAbout1Alt);
    
    String fallbackAbout2Url = (aboutImage2 != null && aboutImage2.getUrl() != null && !aboutImage2.getUrl().isEmpty())
    ? aboutImage2.getUrl()
    : "https://lh3.googleusercontent.com/aida-public/AB6AXuA8yN5DmXiib5xKtGpwJGQ4HbVO4EgR7kwTctb2tDny6VVTP4FBtoPj1xbY_vBsK76Nwx4oHC_VM9t1kWPEZqkNVOA5q7o2i8QC1Gj8M80IdMfSKFzM4MiVGeQMXHj6As_FvziJ5hhN_VszD5BDwAmUnQbMqiei-tNx-EZYzpFm_utRXju8_328DPG4xPtmTrv-PCXC4u3N6q5egoTMU-VmAH0YqLCUZPX9OUFPuBcgmM_GHC8l33qxeV6YoQq6-Ft0s1pOziC-BuI";
    String fallbackAbout2Alt = (aboutImage2 != null && aboutImage2.getAltText() != null && !aboutImage2.getAltText().isEmpty())
    ? aboutImage2.getAltText()
    : "Small dog at veterinary clinic";
    String about2Url = contentService.getImageUrl("home.about.image.2", contentLocale, contentDraftMode, fallbackAbout2Url);
    String about2Alt = contentService.getImageAlt("home.about.image.2", contentLocale, contentDraftMode, fallbackAbout2Alt);
    
    // Load services for the booking form
    ServiceDAO serviceDAO = new ServiceJdbcDAO();
    List<model.Service> services = serviceDAO.findByCategory("general");
    request.setAttribute("services", services);
    
    // --- DEBUGGING ---
    System.out.println("DEBUG index.jsp: Loaded services count: " + (services != null ? services.size() : "null"));
    // --- END DEBUGGING ---
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title><%= esc(txt.apply("home.meta.title", "Anipats - Professional Veterinary Medical Center")) %></title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <script id="tailwind-config">
            tailwind.config = {
                darkMode: "class",
                theme: {
                    extend: {
                        colors: {
                            "primary": "#ff7b00",
                            "background-light": "#f8f7f5",
                            "background-dark": "#23190f",
                            "dark-accent": "#120a0b",
                        },
                        fontFamily: {
                            "display": ["Manrope", "sans-serif"]
                        },
                        borderRadius: {
                            "DEFAULT": "0.5rem",
                            "lg": "1rem",
                            "xl": "1.5rem",
                            "full": "9999px"
                        },
                    },
                }
            };
        </script>
        <style type="text/tailwindcss">
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
            @layer base {
                html {
                    scroll-behavior: smooth;
                }
                body {
                    @apply font-display;
                }
                section[id], footer[id] {
                    scroll-margin-top: 96px;
                }
            }
        </style>
    </head>
    <body id="top" class="bg-background-light dark:bg-background-dark text-[#181111] dark:text-white transition-colors duration-300">
        <% if ("1".equals(forbidden)) { %>
        <div class="fixed top-20 right-6 z-[9999] max-w-sm bg-amber-500 text-[#181111] px-4 py-3 rounded-xl shadow-xl flex items-center justify-between gap-4" role="alert">
            <span class="font-semibold">Access denied.</span> You do not have permission to view that page.
            <button type="button" onclick="this.parentElement.remove()" class="shrink-0 p-1 hover:bg-black/10 rounded" aria-label="Close">&times;</button>
        </div>
        <% } %>
        <% if ("1".equals(booked)) { %>
        <div class="fixed top-20 right-6 z-[9999] max-w-sm bg-green-500 text-white px-4 py-3 rounded-xl shadow-xl flex items-center justify-between gap-4" role="alert">
            <span class="font-semibold">Thank you!</span> Your appointment request has been received.
            <button type="button" onclick="this.parentElement.remove()" class="shrink-0 p-1 hover:bg-white/20 rounded" aria-label="Close">&times;</button>
        </div>
        <% } %>
        <% if ("2".equals(booked)) { %>
        <div class="fixed top-20 right-6 z-[9999] max-w-md bg-blue-500 text-white px-4 py-3 rounded-xl shadow-xl" role="alert">
            <div class="flex items-start justify-between gap-4">
                <div>
                    <p class="font-bold">Booking received &amp; Account created!</p>
                    <p class="text-sm mt-1">To manage your appointment, please set a password for your new account. Use the Forgot Password link with your email to get started.</p>
                </div>
                <button type="button" onclick="this.parentElement.parentElement.remove()" class="shrink-0 p-1 -mr-1 -mt-1 hover:bg-white/20 rounded" aria-label="Close">&times;</button>
            </div>
        </div>
        <% } %>
        <% if ("1".equals(bookErr)) { %>
        <div class="fixed top-20 right-6 z-[9999] max-w-sm bg-red-500 text-white px-4 py-3 rounded-xl shadow-xl flex items-center justify-between gap-4" role="alert">
            <span class="font-semibold">Booking failed.</span> <%= (bookMsg != null && !bookMsg.isEmpty()) ? java.net.URLDecoder.decode(bookMsg, "UTF-8").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") : "Please try again or contact us." %>
            <button type="button" onclick="this.parentElement.remove()" class="shrink-0 p-1 hover:bg-white/20 rounded" aria-label="Close">&times;</button>
        </div>
        <% } %>

        <div class="hidden lg:block bg-dark-accent text-white py-2.5 border-b border-white/5">
            <div class="max-w-[1400px] mx-auto px-10 flex justify-between items-center text-[13px] font-medium tracking-tight">
                <div class="flex gap-8 items-center">
                    <a class="flex items-center gap-2 hover:text-primary transition-colors group" href="tel:+15550001234">
                        <span class="material-symbols-outlined text-[18px] text-primary group-hover:scale-110 transition-transform">call</span>
                        <%= esc(txt.apply("home.topbar.phone", "+1 (555) 000-1234")) %>
                    </a>
                    <a class="flex items-center gap-2 hover:text-primary transition-colors group" href="mailto:contact@anipats.com">
                        <span class="material-symbols-outlined text-[18px] text-primary group-hover:scale-110 transition-transform">mail</span>
                        <%= esc(txt.apply("home.topbar.email", "contact@anipats.com")) %>
                    </a>
                </div>
                <div class="flex gap-6 items-center">
                    <span class="text-white/60"><%= esc(txt.apply("home.topbar.follow", "Follow us:")) %></span>
                    <div class="flex gap-4">
                        <a class="hover:text-primary transition-colors flex items-center" href="#"><span class="material-symbols-outlined text-[18px]">public</span></a>
                        <a class="hover:text-primary transition-colors flex items-center" href="#"><span class="material-symbols-outlined text-[18px]">share</span></a>
                        <a class="hover:text-primary transition-colors flex items-center" href="#"><span class="material-symbols-outlined text-[18px]">chat</span></a>
                    </div>
                </div>
            </div>
        </div>

        <header class="sticky top-0 z-50 bg-white/95 dark:bg-background-dark/95 backdrop-blur-md border-b border-gray-100 dark:border-white/5 px-6 lg:px-10 py-4">
            <div class="max-w-[1400px] mx-auto flex items-center justify-between">
                <a href="<%= ctx %>/index.jsp" class="flex items-center gap-3 group cursor-pointer">
                    <div class="text-primary flex items-center">
                        <svg class="size-9 group-hover:rotate-12 transition-transform duration-300" fill="none" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                            <path d="M39.5563 34.1455V13.8546C39.5563 15.708 36.8773 17.3437 32.7927 18.3189C30.2914 18.916 27.263 19.2655 24 19.2655C20.737 19.2655 17.7086 18.916 15.2073 18.3189C11.1227 17.3437 8.44365 15.708 8.44365 13.8546V34.1455C8.44365 35.9988 11.1227 37.6346 15.2073 38.6098C17.7086 39.2069 20.737 39.5564 24 39.5564C27.263 39.5564 30.2914 39.2069 32.7927 38.6098C36.8773 37.6346 39.5563 35.9988 39.5563 34.1455Z" fill="currentColor"></path>
                        </svg>
                    </div>
                    <h2 class="text-2xl font-extrabold leading-tight tracking-tight text-[#181111] dark:text-white">Anipats</h2>
                </a>
                <nav class="hidden xl:flex items-center gap-10">
                    <a class="text-[15px] font-semibold text-[#181111]/80 dark:text-white/80 hover:text-primary dark:hover:text-primary transition-all relative after:content-[''] after:absolute after:bottom-[-4px] after:left-0 after:w-0 after:h-0.5 after:bg-primary hover:after:w-full after:transition-all" href="#top">Home</a>
                    <a class="text-[15px] font-semibold text-[#181111]/80 dark:text-white/80 hover:text-primary dark:hover:text-primary transition-all relative after:content-[''] after:absolute after:bottom-[-4px] after:left-0 after:w-0 after:h-0.5 after:bg-primary hover:after:w-full after:transition-all" href="#about">About</a>
                    <a class="text-[15px] font-semibold text-[#181111]/80 dark:text-white/80 hover:text-primary dark:hover:text-primary transition-all relative after:content-[''] after:absolute after:bottom-[-4px] after:left-0 after:w-0 after:h-0.5 after:bg-primary hover:after:w-full after:transition-all" href="#services">Services</a>
                    <a class="text-[15px] font-semibold text-[#181111]/80 dark:text-white/80 hover:text-primary dark:hover:text-primary transition-all relative after:content-[''] after:absolute after:bottom-[-4px] after:left-0 after:w-0 after:h-0.5 after:bg-primary hover:after:w-full after:transition-all" href="#contact">Contact</a>
                </nav>
                <div class="flex items-center gap-4">
                    <% if (loggedIn) { %>
                    <a href="<%= roleDashboardUrl != null ? roleDashboardUrl : (ctx + "/customer/dashboard") %>" class="hidden lg:flex px-5 py-2.5 bg-gray-50 dark:bg-white/5 hover:bg-gray-100 dark:hover:bg-white/10 text-[#181111] dark:text-white text-sm font-bold rounded-lg border border-gray-200 dark:border-white/10 transition-all hover:shadow-sm no-underline">
                        Dashboard
                    </a>
                    <% if (isOwnerOrAdminRole(currentRoleId)) { %>
                    <a href="<%= ctx %>/owner/content" class="hidden lg:flex px-5 py-2.5 bg-gray-50 dark:bg-white/5 hover:bg-gray-100 dark:hover:bg-white/10 text-[#181111] dark:text-white text-sm font-bold rounded-lg border border-gray-200 dark:border-white/10 transition-all hover:shadow-sm no-underline">
                        Content
                    </a>
                    <% } %>
                    <% } %>
                    <button type="button" data-toggle="modal" data-target="#bookAppointmentModal" class="hidden sm:flex px-6 py-2.5 bg-primary text-white text-sm font-bold rounded-lg shadow-lg shadow-primary/20 hover:shadow-xl hover:shadow-primary/30 hover:-translate-y-0.5 transition-all active:scale-95">
                        Book Appointment
                    </button>
                    <div class="h-8 w-[1px] bg-gray-200 dark:bg-white/10 mx-2 hidden lg:block"></div>
                    <% if (loggedIn) { %>
                    <span class="hidden lg:inline text-sm font-semibold text-[#181111] dark:text-white/90"><%= userDisplayName != null ? userDisplayName : "Account" %></span>
                    <a href="<%= ctx %>/logout" class="px-5 py-2.5 bg-dark-accent dark:bg-white dark:text-dark-accent text-white text-sm font-bold rounded-lg hover:opacity-90 transition-all active:scale-95 flex items-center gap-2">
                        <span class="material-symbols-outlined text-[18px]">logout</span>
                        Logout
                    </a>
                    <% } else { %>
                    <a href="<%= ctx %>/login" class="px-5 py-2.5 bg-dark-accent dark:bg-white dark:text-dark-accent text-white text-sm font-bold rounded-lg hover:opacity-90 transition-all active:scale-95 flex items-center gap-2">
                        <span class="material-symbols-outlined text-[18px]">account_circle</span>
                        Login / Register
                    </a>
                    <% } %>
                </div>
            </div>
        </header>

        <section class="bg-[#fdf8f1] dark:bg-background-dark/50 py-12 lg:py-20">
            <div class="max-w-[1200px] mx-auto px-6">
                <div class="flex flex-col lg:flex-row items-center gap-12 @container">
                    <div class="flex flex-col gap-8 flex-1">
                        <div class="flex flex-col gap-4">
                            <span class="text-primary font-bold uppercase tracking-widest text-sm"><%= esc(txt.apply("home.hero.kicker", "Professional Vet Care")) %></span>
                            <h1 class="text-[#181111] dark:text-white text-5xl lg:text-7xl font-black leading-[1.1] tracking-[-0.033em]">
                                <%= esc(txt.apply("home.hero.title", "We Care Your Pets")) %>
                            </h1>
                            <p class="text-[#181111]/70 dark:text-white/70 text-lg leading-relaxed max-w-[500px]">
                                <%= esc(txt.apply("home.hero.subtitle", "Professional veterinary medical center providing specialized care for your beloved animal companions. Expert medical standards meets compassionate care.")) %>
                            </p>
                        </div>
                        <div class="flex flex-wrap gap-4">
                            <button type="button" data-toggle="modal" data-target="#bookAppointmentModal" class="flex min-w-[160px] cursor-pointer items-center justify-center rounded-xl h-14 px-6 bg-primary text-white text-base font-bold shadow-lg shadow-primary/20 transition-all hover:bg-primary/90">
                                <%= esc(txt.apply("home.hero.cta_primary", "Get Started")) %>
                            </button>
                            <a href="#" class="flex min-w-[160px] cursor-pointer items-center justify-center rounded-xl h-14 px-6 bg-white dark:bg-white/10 border border-black/5 dark:border-white/10 text-[#181111] dark:text-white text-base font-bold transition-all hover:bg-black/5">
                                <%= esc(txt.apply("home.hero.cta_secondary", "Our Services")) %>
                            </a>
                        </div>
                    </div>
                    <div class="w-full lg:w-1/2">
                        <div class="relative w-full aspect-[4/3] bg-center bg-no-repeat bg-cover rounded-3xl shadow-2xl overflow-hidden group"
                        data-alt="<%= esc(heroBannerAlt) %>"
                        style="background-image: url('<%= esc(heroBannerUrl.startsWith("/") ? (ctx + heroBannerUrl) : heroBannerUrl) %>');">
                        <div class="absolute inset-0 bg-gradient-to-t from-primary/20 to-transparent"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="max-w-[1000px] mx-auto px-6 -mt-10 relative z-10">
        <div class="bg-white dark:bg-[#2d1a1b] rounded-2xl shadow-xl p-8 grid grid-cols-2 md:grid-cols-4 gap-8">
            <div class="text-center">
                <div class="text-3xl font-black text-primary">15k+</div>
                <div class="text-xs uppercase font-bold text-[#896163]"><%= esc(txt.apply("home.stats.clients.label", "Happy Clients")) %></div>
            </div>
            <div class="text-center border-l border-[#f4f0f0] dark:border-white/10">
                <div class="text-3xl font-black text-primary">452+</div>
                <div class="text-xs uppercase font-bold text-[#896163]"><%= esc(txt.apply("home.stats.pets.label", "Pets Available")) %></div>
            </div>
            <div class="text-center border-l border-[#f4f0f0] dark:border-white/10">
                <div class="text-3xl font-black text-primary">20+</div>
                <div class="text-xs uppercase font-bold text-[#896163]"><%= esc(txt.apply("home.stats.vets.label", "Expert Vets")) %></div>
            </div>
            <div class="text-center border-l border-[#f4f0f0] dark:border-white/10">
                <div class="text-3xl font-black text-primary">100%</div>
                <div class="text-xs uppercase font-bold text-[#896163]"><%= esc(txt.apply("home.stats.guarantee.label", "Care Guarantee")) %></div>
            </div>
        </div>
    </div>

    <section id="services" class="py-20 px-6 max-w-[1200px] mx-auto">
        <div class="flex flex-col items-center text-center mb-16">
            <h2 class="text-primary font-bold uppercase tracking-widest text-sm mb-2"><%= esc(txt.apply("home.services.kicker", "What we do")) %></h2>
            <h3 class="text-[#181111] dark:text-white text-4xl font-black"><%= esc(txt.apply("home.services.title", "Our Specialized Services")) %></h3>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="flex flex-col gap-6 rounded-2xl border border-[#e6dbdc] dark:border-white/10 bg-white dark:bg-[#2d1a1b] p-8 hover:shadow-xl transition-all hover:-translate-y-1">
                <div class="size-14 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
                    <span class="material-symbols-outlined text-3xl">home</span>
                </div>
                <div class="flex flex-col gap-2">
                    <h4 class="text-xl font-bold leading-tight"><%= esc(txt.apply("home.services.card1.title", "Pet Boarding")) %></h4>
                    <p class="text-[#896163] dark:text-white/60 text-sm leading-relaxed"><%= esc(txt.apply("home.services.card1.body", "Safe and comfortable home away from home. 24/7 supervision and climate-controlled luxury suites for your pets.")) %></p>
                </div>
                <a class="text-primary text-sm font-bold flex items-center gap-2 mt-auto" href="#"><%= esc(txt.apply("home.services.learn_more", "Learn More")) %> <span class="material-symbols-outlined text-[16px]">arrow_forward</span></a>
            </div>
            <div class="flex flex-col gap-6 rounded-2xl border border-[#e6dbdc] dark:border-white/10 bg-white dark:bg-[#2d1a1b] p-8 hover:shadow-xl transition-all hover:-translate-y-1">
                <div class="size-14 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
                    <span class="material-symbols-outlined text-3xl">restaurant</span>
                </div>
                <div class="flex flex-col gap-2">
                    <h4 class="text-xl font-bold leading-tight"><%= esc(txt.apply("home.services.card2.title", "Healthy Meals")) %></h4>
                    <p class="text-[#896163] dark:text-white/60 text-sm leading-relaxed"><%= esc(txt.apply("home.services.card2.body", "Nutritious plans tailored for your pet's needs. Customized diet plans designed by our in-house nutritionists.")) %></p>
                </div>
                <a class="text-primary text-sm font-bold flex items-center gap-2 mt-auto" href="#"><%= esc(txt.apply("home.services.learn_more", "Learn More")) %> <span class="material-symbols-outlined text-[16px]">arrow_forward</span></a>
            </div>
            <div class="flex flex-col gap-6 rounded-2xl border border-[#e6dbdc] dark:border-white/10 bg-white dark:bg-[#2d1a1b] p-8 hover:shadow-xl transition-all hover:-translate-y-1">
                <div class="size-14 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
                    <span class="material-symbols-outlined text-3xl">spa</span>
                </div>
                <div class="flex flex-col gap-2">
                    <h4 class="text-xl font-bold leading-tight"><%= esc(txt.apply("home.services.card3.title", "Pet Spa")) %></h4>
                    <p class="text-[#896163] dark:text-white/60 text-sm leading-relaxed"><%= esc(txt.apply("home.services.card3.body", "Professional grooming and relaxation services. Aromatherapy, massage, and therapeutic baths for ultimate comfort.")) %></p>
                </div>
                <a class="text-primary text-sm font-bold flex items-center gap-2 mt-auto" href="#"><%= esc(txt.apply("home.services.learn_more", "Learn More")) %> <span class="material-symbols-outlined text-[16px]">arrow_forward</span></a>
            </div>
        </div>
    </section>

    <section id="about" class="bg-white dark:bg-background-dark py-20">
        <div class="max-w-[1200px] mx-auto px-6 flex flex-col lg:flex-row items-center gap-16">
            <div class="w-full lg:w-1/2 grid grid-cols-2 gap-4">
                <div class="h-64 rounded-2xl bg-center bg-cover" data-alt="<%= esc(about1Alt) %>" style="background-image: url('<%= esc(about1Url.startsWith("/") ? (ctx + about1Url) : about1Url) %>');"></div>
                <div class="h-80 rounded-2xl bg-center bg-cover mt-8" data-alt="<%= esc(about2Alt) %>" style="background-image: url('<%= esc(about2Url.startsWith("/") ? (ctx + about2Url) : about2Url) %>');"></div>
            </div>
            <div class="w-full lg:w-1/2 flex flex-col gap-8">
                <div class="flex flex-col gap-6">
                    <h2 class="text-primary font-bold uppercase tracking-widest text-sm"><%= esc(txt.apply("home.about.kicker", "About Anipats")) %></h2>
                    <h1 class="text-[#181111] dark:text-white text-4xl lg:text-5xl font-black leading-tight">
                        <%= esc(txt.apply("home.about.title", "Exceptional Pet Care Standards")) %>
                    </h1>
                    <p class="text-[#181111]/70 dark:text-white/70 text-lg leading-relaxed">
                        <%= esc(txt.apply("home.about.body", "Our team of expert veterinarians ensures your pets receive the highest quality medical attention with modern equipment and heartfelt care. We treat every animal like our own family.")) %>
                    </p>
                    <div class="flex flex-col gap-4">
                        <div class="flex items-center gap-3">
                            <span class="material-symbols-outlined text-primary font-bold">check_circle</span>
                            <span class="font-bold"><%= esc(txt.apply("home.about.bullet1", "Modern Medical Technology")) %></span>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="material-symbols-outlined text-primary font-bold">check_circle</span>
                            <span class="font-bold"><%= esc(txt.apply("home.about.bullet2", "24/7 Emergency Support")) %></span>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="material-symbols-outlined text-primary font-bold">check_circle</span>
                            <span class="font-bold"><%= esc(txt.apply("home.about.bullet3", "Certified Pet Nutritionists")) %></span>
                        </div>
                    </div>
                </div>
                <button type="button" class="flex min-w-[180px] w-fit cursor-pointer items-center justify-center rounded-xl h-14 px-6 bg-primary text-white text-base font-bold shadow-lg shadow-primary/20 hover:scale-105 transition-all">
                    <%= esc(txt.apply("home.about.cta", "Learn More About Us")) %>
                </button>
            </div>
        </div>
    </section>

    <section class="py-24 px-6 max-w-[1200px] mx-auto">
        <div class="flex flex-col items-center text-center mb-16">
            <h2 class="text-primary font-bold uppercase tracking-widest text-sm mb-2"><%= esc(txt.apply("home.team.kicker", "Our Experts")) %></h2>
            <h3 class="text-[#181111] dark:text-white text-4xl font-black"><%= esc(txt.apply("home.team.title", "Meet Our Professional Team")) %></h3>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            <c:forEach var="card" items="${teamCards}">
                <div class="group">
                    <div class="relative aspect-square rounded-3xl overflow-hidden mb-6 shadow-lg bg-gray-200 bg-center bg-cover"
                    data-alt="${fn:escapeXml(card.alt)}"
                    style="background-image: url('${fn:escapeXml(card.url)}');">
                    <div class="absolute inset-0 bg-primary/0 group-hover:bg-primary/20 transition-all duration-300"></div>
                </div>
                <h4 class="text-xl font-black mb-1 group-hover:text-primary transition-colors">${fn:escapeXml(card.name)}</h4>
                <p class="text-[#896163] dark:text-white/60 font-medium">${fn:escapeXml(card.role)}</p>
            </div>
        </c:forEach>
    </div>
</section>

<footer id="contact" class="bg-dark-accent text-white py-16 px-6">
    <div class="max-w-[1200px] mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-16 border-b border-white/10 pb-16">
            <div class="flex flex-col gap-6">
                <div class="flex items-center gap-2 text-white">
                    <div class="text-primary">
                        <svg class="size-10" fill="none" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                            <path d="M39.5563 34.1455V13.8546C39.5563 15.708 36.8773 17.3437 32.7927 18.3189C30.2914 18.916 27.263 19.2655 24 19.2655C20.737 19.2655 17.7086 18.916 15.2073 18.3189C11.1227 17.3437 8.44365 15.708 8.44365 13.8546V34.1455C8.44365 35.9988 11.1227 37.6346 15.2073 38.6098C17.7086 39.2069 20.737 39.5564 24 39.5564C27.263 39.5564 30.2914 39.2069 32.7927 38.6098C36.8773 37.6346 39.5563 35.9988 39.5563 34.1455Z" fill="currentColor"></path>
                        </svg>
                    </div>
                    <h2 class="text-2xl font-black"><%= esc(txt.apply("home.footer.brand", "Anipats")) %></h2>
                </div>
                <p class="text-white/60 leading-relaxed">
                    <%= esc(txt.apply("home.footer.about", "Setting the gold standard in pet healthcare. Modern medical expertise with heart and compassion since 2010.")) %>
                </p>
                <div class="flex gap-4">
                    <div class="size-10 rounded-lg bg-white/5 flex items-center justify-center hover:bg-primary transition-colors cursor-pointer"><span class="material-symbols-outlined text-[20px]">public</span></div>
                    <div class="size-10 rounded-lg bg-white/5 flex items-center justify-center hover:bg-primary transition-colors cursor-pointer"><span class="material-symbols-outlined text-[20px]">share</span></div>
                    <div class="size-10 rounded-lg bg-white/5 flex items-center justify-center hover:bg-primary transition-colors cursor-pointer"><span class="material-symbols-outlined text-[20px]">chat</span></div>
                </div>
            </div>
            <div class="flex flex-col gap-6">
                <h4 class="text-lg font-bold border-l-4 border-primary pl-4"><%= esc(txt.apply("home.footer.quick_links", "Quick Links")) %></h4>
                <ul class="flex flex-col gap-3 text-white/60">
                    <li><a class="hover:text-primary transition-colors" href="<%= ctx %>/index.jsp"><%= esc(txt.apply("home.footer.quick.home", "Home Page")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="#"><%= esc(txt.apply("home.footer.quick.about", "About Us")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="#"><%= esc(txt.apply("home.footer.quick.services", "Medical Services")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="#"><%= esc(txt.apply("home.footer.quick.adoption", "Pet Adoption")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="#"><%= esc(txt.apply("home.footer.quick.pros", "Our Professionals")) %></a></li>
                    <% if (loggedIn) { %>
                    <li><a class="hover:text-primary transition-colors" href="<%= ctx %>/customer/dashboard"><%= esc(txt.apply("home.footer.quick.dashboard", "Dashboard")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="<%= ctx %>/logout"><%= esc(txt.apply("home.footer.quick.logout", "Logout")) %></a></li>
                    <% } else { %>
                    <li><a class="hover:text-primary transition-colors" href="<%= ctx %>/login"><%= esc(txt.apply("home.footer.quick.login", "Login")) %></a></li>
                    <li><a class="hover:text-primary transition-colors" href="<%= ctx %>/register"><%= esc(txt.apply("home.footer.quick.register", "Register")) %></a></li>
                    <% } %>
                </ul>
            </div>
            <div class="flex flex-col gap-6">
                <h4 class="text-lg font-bold border-l-4 border-primary pl-4"><%= esc(txt.apply("home.footer.contact_title", "Get In Touch")) %></h4>
                <div class="flex flex-col gap-4 text-white/60">
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary">location_on</span>
                        <span><%= esc(txt.apply("home.footer.location", "123 Medical Plaza, Downtown, NY 10001")) %></span>
                    </div>
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary">call</span>
                        <span><%= esc(txt.apply("home.footer.phone", "+1 (555) 000-1234")) %></span>
                    </div>
                    <div class="flex gap-3">
                        <span class="material-symbols-outlined text-primary">mail</span>
                        <span><%= esc(txt.apply("home.footer.email", "emergency@anipats.com")) %></span>
                    </div>
                </div>
            </div>
            <div class="flex flex-col gap-6">
                <h4 class="text-lg font-bold border-l-4 border-primary pl-4"><%= esc(txt.apply("home.footer.newsletter_title", "Newsletter")) %></h4>
                <p class="text-white/60 text-sm"><%= esc(txt.apply("home.footer.newsletter_body", "Get healthy pet tips and news delivered to your inbox weekly.")) %></p>
                <div class="flex flex-col gap-2">
                    <input class="bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:border-primary transition-colors text-white placeholder-white/40" placeholder="<%= esc(txt.apply("home.footer.newsletter_placeholder", "Your Email Address")) %>" type="email"/>
                    <button type="button" class="bg-primary text-white font-bold py-3 rounded-xl hover:bg-primary/90 transition-all shadow-lg shadow-primary/20"><%= esc(txt.apply("home.footer.newsletter_button", "Subscribe Now")) %></button>
                </div>
            </div>
        </div>
        <div class="flex flex-col md:flex-row justify-between items-center gap-6 text-white/40 text-sm">
            <p>© <%= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) %> <%= esc(txt.apply("home.footer.copyright_suffix", "Anipats Veterinary Medical Center. All rights reserved.")) %></p>
            <div class="flex gap-8">
                <a class="hover:text-white transition-colors" href="#"><%= esc(txt.apply("home.footer.privacy", "Privacy Policy")) %></a>
                <a class="hover:text-white transition-colors" href="#"><%= esc(txt.apply("home.footer.terms", "Terms of Service")) %></a>
            </div>
        </div>
    </div>
</footer>

<!-- Book Appointment Modal (no Bootstrap) -->
<div id="bookAppointmentModal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4" aria-modal="true" aria-labelledby="bookAppointmentLabel">
    <div id="bookModalBackdrop" class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="document.getElementById('bookAppointmentModal').classList.add('hidden'); document.getElementById('bookAppointmentModal').classList.remove('flex');"></div>
    <div class="relative bg-white dark:bg-[#2d1a1b] rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="sticky top-0 bg-white dark:bg-[#2d1a1b] px-6 py-4 border-b border-gray-100 dark:border-white/10 flex items-center justify-between z-10">
            <h2 id="bookAppointmentLabel" class="text-xl font-bold text-[#181111] dark:text-white"><%= esc(txt.apply("home.book_modal.title", "Book Appointment")) %></h2>
            <button type="button" class="modal-close p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-white/10 transition-colors" onclick="document.getElementById('bookAppointmentModal').classList.add('hidden'); document.getElementById('bookAppointmentModal').classList.remove('flex');" aria-label="Close">
                <span class="material-symbols-outlined text-2xl">close</span>
            </button>
        </div>
        <div class="p-6">
            <jsp:include page="bookForm.jsp" flush="true"/>
        </div>
    </div>
</div>

<script>
    (function() {
        function showModal(id) {
            var el = document.getElementById(id);
            if (el) {
                el.classList.remove('hidden');
                el.classList.add('flex');
                document.body.style.overflow = 'hidden';
            }
        }
        function hideModal(id) {
            var el = document.getElementById(id);
            if (el) {
                el.classList.add('hidden');
                el.classList.remove('flex');
                document.body.style.overflow = '';
            }
        }
        var autoOpenBooking = '${param.openBooking}' === '1';
        if (autoOpenBooking) {
            showModal('bookAppointmentModal');
        }
        document.querySelectorAll('[data-toggle="modal"][data-target="#bookAppointmentModal"]').forEach(function(btn) {
            btn.addEventListener('click', function() { showModal('bookAppointmentModal'); });
        });
        document.querySelectorAll('.modal-close').forEach(function(btn) {
            btn.addEventListener('click', function() { hideModal('bookAppointmentModal'); });
        });
        document.getElementById('bookModalBackdrop').addEventListener('click', function() { hideModal('bookAppointmentModal'); });
    })();
</script>
</body>
</html>