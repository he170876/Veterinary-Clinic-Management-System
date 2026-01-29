<%--
    Document   : index.jsp
    Anipat landing page - VCMS
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="no-js" lang="zxx">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="x-ua-compatible" content="ie=edge">
        <title>Anipats - We Care Your Pets</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="shortcut icon" type="image/x-icon" href="anipat-master/img/logo.png">
        <link rel="stylesheet" href="anipat-master/css/bootstrap.min.css">
        <link rel="stylesheet" href="anipat-master/css/owl.carousel.min.css">
        <link rel="stylesheet" href="anipat-master/css/magnific-popup.css">
        <link rel="stylesheet" href="anipat-master/css/font-awesome.min.css">
        <link rel="stylesheet" href="anipat-master/css/themify-icons.css">
        <link rel="stylesheet" href="anipat-master/css/nice-select.css">
        <link rel="stylesheet" href="anipat-master/css/flaticon.css">
        <link rel="stylesheet" href="anipat-master/css/gijgo.css">
        <link rel="stylesheet" href="anipat-master/css/animate.css">
        <link rel="stylesheet" href="anipat-master/css/slicknav.css">
        <link rel="stylesheet" href="anipat-master/css/style.css">
        <style>
            .modal { z-index: 2000 !important; pointer-events: auto !important; }
            .modal .modal-dialog { pointer-events: auto !important; }
            .modal-backdrop { z-index: 1500 !important; }
            .modal-backdrop.show { opacity: 0.6 !important; }
            .nav-btn { background: #f14437; color: #fff !important; padding: 10px 18px !important; border-radius: 6px; font-weight: 600; transition: transform .12s ease, box-shadow .12s ease; }
            .nav-btn:hover { transform: translateY(-2px); background: #d6362b !important; color:#fff !important; }
            .nav-login { color: #fff !important; padding: 10px 18px !important; border-radius: 6px; border: 1px solid rgba(255,255,255,0.2); background: #1a1614; font-weight: 600; }
            .nav-login:hover { background: rgba(255,255,255,0.06); color:#fff !important; }
            #navigation li a.nav-btn, #navigation li a.nav-login { display: inline-block; }
            .hero-accent { color: #f14437; }
            .hero-subtitle { font-size: 0.85rem; letter-spacing: 0.2em; color: #f14437; font-weight: 700; margin-bottom: 0.5rem; }
            .stats-row { background: #f8f7f5; padding: 2.5rem 0; }
            .stats-item { text-align: center; }
            .stats-item .number { font-size: 2.25rem; font-weight: 800; color: #f14437; line-height: 1.2; }
            .stats-item .label { font-size: 0.9rem; color: #5c4a3a; font-weight: 600; margin-top: 0.25rem; }
        </style>
    </head>
    <body>
        <%
            String ctx = request.getContextPath();
            Object currentUser = (session == null) ? null : session.getAttribute("currentUser");
            boolean loggedIn = (currentUser != null);
            String userDisplayName = null;
            if (currentUser != null && currentUser instanceof model.User) {
                String fn = ((model.User) currentUser).getFullName();
                if (fn != null && !fn.isEmpty()) userDisplayName = fn; else userDisplayName = ((model.User) currentUser).getEmail();
            }
            String booked = request.getParameter("booked");
            String bookErr = request.getParameter("bookError");
            String bookMsg = request.getParameter("bookMessage");
            String forbidden = request.getParameter("forbidden");
        %>
        <% if ("1".equals(forbidden)) { %>
        <div class="alert alert-warning alert-dismissible fade show m-3" role="alert" style="position: fixed; top: 80px; right: 20px; z-index: 9999;">
            <strong>Access denied.</strong> You do not have permission to view that page.
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        </div>
        <% } %>
        <% if ("1".equals(booked)) { %>
        <div class="alert alert-success alert-dismissible fade show m-3" role="alert" style="position: fixed; top: 80px; right: 20px; z-index: 9999;">
            <strong>Thank you!</strong> Your appointment request has been received. We will contact you shortly.
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        </div>
        <% } %>
        <% if ("1".equals(bookErr)) { %>
        <div class="alert alert-danger alert-dismissible fade show m-3" role="alert" style="position: fixed; top: 80px; right: 20px; z-index: 9999;">
            <strong>Booking failed.</strong> <%= (bookMsg != null && !bookMsg.isEmpty()) ? java.net.URLDecoder.decode(bookMsg, "UTF-8") : "Please try again or contact us." %>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        </div>
        <% } %>
        <header>
            <div class="header-area ">
                <div class="header-top_area">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-6 col-md-8">
                                <div class="short_contact_list">
                                    <ul>
                                        <li><a href="tel:+15550001234">+1 (555) 000-1234</a></li>
                                        <li><a href="mailto:contact@anipats.com">contact@anipats.com</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-4 ">
                                <div class="social_media_links d-flex align-items-center justify-content-end">
                                    <span class="mr-2" style="font-size: 0.9rem; color: rgba(255,255,255,0.9);">Follow us</span>
                                    <a href="#"><i class="fa fa-facebook"></i></a>
                                    <a href="#"><i class="fa fa-pinterest-p"></i></a>
                                    <a href="#"><i class="fa fa-google-plus"></i></a>
                                    <a href="#"><i class="fa fa-linkedin"></i></a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="sticky-header" class="main-header-area">
                    <div class="container">
                        <div class="row align-items-center">
                            <div class="col-xl-3 col-lg-3">
                                <div class="logo">
                                    <a href="<%= ctx %>/index.jsp">
                                        <img src="anipat-master/img/logo.png" alt="Anipats">
                                    </a>
                                </div>
                            </div>
                            <div class="col-xl-9 col-lg-9">
                                <div class="main-menu  d-none d-lg-block">
                                    <nav>
                                        <ul id="navigation">
                                            <li><a href="<%= ctx %>/index.jsp">Home</a></li>
                                            <li><a href="anipat-master/about.html">About</a></li>
                                            <li><a href="anipat-master/service.html">Services</a></li>
                                            <li><a href="#">Adoption</a></li>
                                            <li><a href="anipat-master/contact.html">Contact</a></li>
                                            <li><a href="#" class="nav-btn" data-toggle="modal" data-target="#bookAppointmentModal">Book Appointment</a></li>
                                            <% if (loggedIn) { %>
                                            <li><span class="nav-login" style="cursor:default;"><%= userDisplayName != null ? userDisplayName : "Account" %></span></li>
                                            <li><a href="<%= ctx %>/customer/dashboard" class="nav-login">Dashboard</a></li>
                                            <li><a href="<%= ctx %>/logout" class="nav-login">Logout</a></li>
                                            <% } else { %>
                                            <li><a href="<%= ctx %>/login" class="nav-login">Login / Register</a></li>
                                            <% } %>
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="mobile_menu d-block d-lg-none"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Hero -->
        <div class="slider_area">
            <div class="single_slider slider_bg_1 d-flex align-items-center">
                <div class="container">
                    <div class="row align-items-center">
                        <div class="col-lg-6 col-md-7">
                            <div class="slider_text">
                                <p class="hero-subtitle">PROFESSIONAL VET CARE</p>
                                <h3 class="mb-3">We Care <span class="hero-accent">Your Pets</span></h3>
                                <p class="mb-4" style="max-width: 480px; line-height: 1.6;">Professional veterinary medical center providing specialized care for your beloved animal companions. Expert medical standards meets compassionate care.</p>
                                <div class="d-flex flex-wrap gap-2">
                                    <a href="#" class="boxed-btn4 nav-btn" data-toggle="modal" data-target="#bookAppointmentModal">Get Started</a>
                                    <a href="anipat-master/service.html" class="boxed-btn3" style="border: 2px solid #1a1614; color: #1a1614; padding: 10px 24px; border-radius: 6px; font-weight: 600;">Our Services</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6 col-md-5 d-none d-md-block text-center">
                            <img src="anipat-master/img/banner/dog.png" alt="Happy pet" class="img-fluid" style="max-height: 420px;">
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats -->
        <div class="stats-row">
            <div class="container">
                <div class="row">
                    <div class="col-6 col-md-3">
                        <div class="stats-item">
                            <div class="number">15k+</div>
                            <div class="label">HAPPY CLIENTS</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="stats-item">
                            <div class="number">452+</div>
                            <div class="label">PETS AVAILABLE</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="stats-item">
                            <div class="number">20+</div>
                            <div class="label">EXPERT VETS</div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="stats-item">
                            <div class="number">100%</div>
                            <div class="label">CARE GUARANTEE</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="service_area">
            <div class="container">
                <div class="row justify-content-center ">
                    <div class="col-lg-7 col-md-10">
                        <div class="section_title text-center mb-95">
                            <h3>Services for every dog</h3>
                            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.</p>
                        </div>
                    </div>
                </div>
                <div class="row justify-content-center">
                    <div class="col-lg-4 col-md-6">
                        <div class="single_service">
                            <div class="service_thumb service_icon_bg_1 d-flex align-items-center justify-content-center">
                                <div class="service_icon">
                                    <img src="anipat-master/img/service/service_icon_1.png" alt="">
                                </div>
                            </div>
                            <div class="service_content text-center">
                                <h3>Pet Boarding</h3>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="single_service active">
                            <div class="service_thumb service_icon_bg_1 d-flex align-items-center justify-content-center">
                                <div class="service_icon">
                                    <img src="anipat-master/img/service/service_icon_2.png" alt="">
                                </div>
                            </div>
                            <div class="service_content text-center">
                                <h3>Healthy Meals</h3>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="single_service">
                            <div class="service_thumb service_icon_bg_1 d-flex align-items-center justify-content-center">
                                <div class="service_icon">
                                    <img src="anipat-master/img/service/service_icon_3.png" alt="">
                                </div>
                            </div>
                            <div class="service_content text-center">
                                <h3>Pet Spa</h3>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="pet_care_area">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-5 col-md-6">
                        <div class="pet_thumb">
                            <img src="anipat-master/img/about/pet_care.png" alt="">
                        </div>
                    </div>
                    <div class="col-lg-6 offset-lg-1 col-md-6">
                        <div class="pet_info">
                            <div class="section_title">
                                <h3><span>We care your pet </span> <br> As you care</h3>
                                <p>Lorem ipsum dolor sit , consectetur adipiscing elit, sed do iusmod tempor incididunt ut labore et dolore magna aliqua.</p>
                                <a href="anipat-master/about.html" class="boxed-btn3">About Us</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="contact_anipat anipat_bg_1">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="contact_text text-center">
                            <div class="section_title text-center">
                                <h3>Why go with Anipat?</h3>
                                <p>Because we know that even the best technology is only as good as the people behind it. 24/7 tech support.</p>
                            </div>
                            <div class="contact_btn d-flex align-items-center justify-content-center">
                                <a href="anipat-master/contact.html" class="boxed-btn4">Contact Us</a>
                                <p>Or  <a href="#"> +880 4664 216</a></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <footer class="footer">
            <div class="footer_top">
                <div class="container">
                    <div class="row">
                        <div class="col-xl-3 col-md-6 col-lg-3">
                            <div class="footer_widget">
                                <h3 class="footer_title">Contact Us</h3>
                                <ul class="address_line">
                                    <li>+555 0000 565</li>
                                    <li><a href="#">Demomail@gmail.Com</a></li>
                                    <li>700, Green Lane, New York, USA</li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-xl-3 col-md-6 col-lg-3">
                            <div class="footer_widget">
                                <h3 class="footer_title">Quick Link</h3>
                                <ul class="links">
                                    <li><a href="anipat-master/about.html">About Us</a></li>
                                    <% if (loggedIn) { %>
                                    <li><a href="<%= ctx %>/customer/dashboard">Dashboard</a></li>
                                    <li><a href="<%= ctx %>/logout">Logout</a></li>
                                    <% } else { %>
                                    <li><a href="<%= ctx %>/login">Login</a></li>
                                    <li><a href="<%= ctx %>/register">Register</a></li>
                                    <% } %>
                                </ul>
                            </div>
                        </div>
                        <div class="col-xl-3 col-md-6 col-lg-3 ">
                            <div class="footer_widget">
                                <div class="footer_logo">
                                    <a href="<%= ctx %>/index.jsp"><img src="anipat-master/img/logo.png" alt=""></a>
                                </div>
                                <p class="address_text">239 E 5th St, New York NY 10003, USA</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="copy-right_text">
                <div class="container">
                    <div class="bordered_1px"></div>
                    <div class="row">
                        <div class="col-xl-12">
                            <p class="copy_right text-center">
                                Copyright &copy;<script>document.write(new Date().getFullYear());</script> Anipats VCMS
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </footer>

        <div class="modal fade" id="bookAppointmentModal" tabindex="-1" role="dialog" aria-labelledby="bookAppointmentLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="bookAppointmentLabel">Book Appointment</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <jsp:include page="bookForm.jsp" flush="true"/>
                    </div>
                </div>
            </div>
        </div>

        <script src="anipat-master/js/vendor/jquery-1.12.4.min.js"></script>
        <script src="anipat-master/js/popper.min.js"></script>
        <script src="anipat-master/js/bootstrap.min.js"></script>
        <script src="anipat-master/js/owl.carousel.min.js"></script>
        <script src="anipat-master/js/jquery.slicknav.min.js"></script>
        <script src="anipat-master/js/main.js"></script>
    </body>
</html>
