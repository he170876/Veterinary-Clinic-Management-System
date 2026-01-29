<%-- 
    Document   : index.jsp
    Created on : Jan 29, 2026, 3:49:57 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html class="no-js" lang="zxx">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="x-ua-compatible" content="ie=edge">
        <title>Animal</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- <link rel="manifest" href="site.webmanifest"> -->
        <link rel="shortcut icon" type="image/x-icon" href="img/favicon.png">
        <!-- Place favicon.ico in the root directory -->

        <!-- CSS here -->
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
        <!-- <link rel="stylesheet" href="anipat-master/css/responsive.css"> -->
        <style>
            /* Fix modal/backdrop stacking and interaction issues */
            .modal {
                z-index: 2000 !important;
                pointer-events: auto !important;
            }
            .modal .modal-dialog { pointer-events: auto !important; }
            .modal-backdrop {
                z-index: 1500 !important;
            }
            .modal-backdrop.show { opacity: 0.6 !important; }
            /* Navigation button styles */
            .nav-btn {
                background: linear-gradient(90deg,#f27c0d,#e07a0a);
                color: #fff !important;
                padding: 10px 10px !important;
                border-radius: 6px;
                font-weight: 600;
                box-shadow: 0 2px 6px rgba(226,122,9,0.15);
                transition: transform .12s ease, box-shadow .12s ease;
            }
            .nav-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(226,122,9,0.18); color:#fff !important; }
            .nav-login {
                color: #fff !important;
                padding: 10px 10px !important;
                border-radius: 6px;
                border: 1px solid rgba(255,255,255,0.12);
                background: #000000;
                font-weight: 600;
            }
            .nav-login:hover { background: rgba(255,255,255,0.03); }
            /* Small responsive tweak so buttons align with nav */
            #navigation li a.nav-btn, #navigation li a.nav-login { display: inline-block; }
        </style>
    </head>

    <body>
        <!--[if lte IE 9]>
                <p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade your browser</a> to improve your experience and security.</p>
            <![endif]-->

        <header>
            <div class="header-area ">
                <div class="header-top_area">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-6 col-md-8">
                                <div class="short_contact_list">
                                    <ul>
                                        <li><a href="#">+880 4664 216</a></li>
                                        <li><a href="#">Mon - Sat 10:00 - 7:00</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-4 ">
                                <div class="social_media_links">
                                    <a href="#">
                                        <i class="fa fa-facebook"></i>
                                    </a>
                                    <a href="#">
                                        <i class="fa fa-pinterest-p"></i>
                                    </a>
                                    <a href="#">
                                        <i class="fa fa-google-plus"></i>
                                    </a>
                                    <a href="#">
                                        <i class="fa fa-linkedin"></i>
                                    </a>
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
                                    <a href="anipat-master/index.html">
                                        <img src="anipat-master/img/logo.png" alt="">
                                    </a>
                                </div>
                            </div>
                            <div class="col-xl-9 col-lg-9">
                                <div class="main-menu  d-none d-lg-block">
                                    <nav>
                                        <ul id="navigation">
                                            <li><a  href="anipat-master/index.html">home</a></li>
                                            <li><a href="#">blog <i class="ti-angle-down"></i></a>
                                                <ul class="submenu">
                                                    <li><a href="anipat-master/blog.html">blog</a></li>
                                                    <li><a href="anipat-master/single-blog.html">single-blog</a></li>
                                                </ul>
                                            </li>
                                            <li><a href="anipat-master/service.html">services</a></li>
                                            <li><a href="anipat-master/contact.html">Contact</a></li>
                                            <li><a href="#" class="nav-btn" data-toggle="modal" data-target="#bookAppointmentModal">Book Appointment</a></li>
                                            <li><a href="login.jsp" class="nav-login">Login / Register</a></li>
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

        <!-- slider_area_start -->
        <div class="slider_area">
            <div class="single_slider slider_bg_1 d-flex align-items-center">
                <div class="container">
                    <div class="row">
                        <div class="col-lg-5 col-md-6">
                                <div class="slider_text">
                                <h3>We Care <br> <span>Your Pets</span></h3>
                                <p>Lorem ipsum dolor sit amet, consectetur <br> adipiscing elit, sed do eiusmod.</p>
                                <a href="#" class="boxed-btn4 nav-btn" data-toggle="modal" data-target="#bookAppointmentModal">Book Appointment</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="dog_thumb d-none d-lg-block">
                    <img src="anipat-master/img/banner/dog.png" alt="">
                </div>
            </div>
        </div>
        <!-- slider_area_end -->

        <!-- service_area_start  -->
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
        <!-- service_area_end -->

        <!-- pet_care_area_start  -->
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
                                <h3><span>We care your pet </span> <br>
                                    As you care</h3>
                                <p>Lorem ipsum dolor sit , consectetur adipiscing elit, sed do <br> iusmod tempor incididunt ut labore et dolore magna aliqua. <br> Quis ipsum suspendisse ultrices gravida. Risus commodo <br>
                                    viverra maecenas accumsan.</p>
                                <a href="anipat-master/about.html" class="boxed-btn3">About Us</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- pet_care_area_end  -->

        <!-- adapt_area_start  -->
        <div class="adapt_area">
            <div class="container">
                <div class="row justify-content-between align-items-center">
                    <div class="col-lg-5">
                        <div class="adapt_help">
                            <div class="section_title">
                                <h3><span>We need your</span>
                                    help Adopt Us</h3>
                                <p>Lorem ipsum dolor sit , consectetur adipiscing elit, sed do iusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices.</p>
                                <a href="anipat-master/contact.html" class="boxed-btn3">Contact Us</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="adapt_about">
                            <div class="row align-items-center">
                                <div class="col-lg-6 col-md-6">
                                    <div class="single_adapt text-center">
                                        <img src="anipat-master/img/adapt_icon/1.png" alt="">
                                        <div class="adapt_content">
                                            <h3 class="counter">452</h3>
                                            <p>Pets Available</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="single_adapt text-center">
                                        <img src="anipat-master/img/adapt_icon/3.png" alt="">
                                        <div class="adapt_content">
                                            <h3><span class="counter">52</span>+</h3>
                                            <p>Pets Available</p>
                                        </div>
                                    </div>
                                    <div class="single_adapt text-center">
                                        <img src="anipat-master/img/adapt_icon/2.png" alt="">
                                        <div class="adapt_content">
                                            <h3><span class="counter">52</span>+</h3>
                                            <p>Pets Available</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- adapt_area_end  -->

        <!-- team_area_start  -->
        <div class="team_area">
            <div class="container">
                <div class="row justify-content-center ">
                    <div class="col-lg-6 col-md-10">
                        <div class="section_title text-center mb-95">
                            <h3>Our Team</h3>
                            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.</p>
                        </div>
                    </div>
                </div>
                <div class="row justify-content-center">
                    <div class="col-lg-4 col-md-6">
                        <div class="single_team">
                            <div class="thumb">
                                <img src="anipat-master/img/team/1.png" alt="">
                            </div>
                            <div class="member_name text-center">
                                <div class="mamber_inner">
                                    <h4>Rala Emaia</h4>
                                    <p>Senior Director</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="single_team">
                            <div class="thumb">
                                <img src="anipat-master/img/team/2.png" alt="">
                            </div>
                            <div class="member_name text-center">
                                <div class="mamber_inner">
                                    <h4>jhon Smith</h4>
                                    <p>Senior Director</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6">
                        <div class="single_team">
                            <div class="thumb">
                                <img src="anipat-master/img/team/3.png" alt="">
                            </div>
                            <div class="member_name text-center">
                                <div class="mamber_inner">
                                    <h4>Rala Emaia</h4>
                                    <p>Senior Director</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- team_area_start  -->

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

        <!-- footer_start  -->
        <footer class="footer">
            <div class="footer_top">
                <div class="container">
                    <div class="row">
                        <div class="col-xl-3 col-md-6 col-lg-3">
                            <div class="footer_widget">
                                <h3 class="footer_title">
                                    Contact Us
                                </h3>
                                <ul class="address_line">
                                    <li>+555 0000 565</li>
                                    <li><a href="#">Demomail@gmail.Com</a></li>
                                    <li>700, Green Lane, New York, USA</li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-xl-3  col-md-6 col-lg-3">
                            <div class="footer_widget">
                                <h3 class="footer_title">
                                    Our Servces
                                </h3>
                                <ul class="links">
                                    <li><a href="#">Pet Insurance</a></li>
                                    <li><a href="#">Pet surgeries </a></li>
                                    <li><a href="#">Pet Adoption</a></li>
                                    <li><a href="#">Dog Insurance</a></li>
                                    <li><a href="#">Dog Insurance</a></li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-xl-3  col-md-6 col-lg-3">
                            <div class="footer_widget">
                                <h3 class="footer_title">
                                    Quick Link
                                </h3>
                                <ul class="links">
                                    <li><a href="#">About Us</a></li>
                                    <li><a href="#">Privacy Policy</a></li>
                                    <li><a href="#">Terms of Service</a></li>
                                    <li><a href="#">Login info</a></li>
                                    <li><a href="#">Knowledge Base</a></li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-xl-3 col-md-6 col-lg-3 ">
                            <div class="footer_widget">
                                <div class="footer_logo">
                                    <a href="#">
                                        <img src="anipat-master/img/logo.png" alt="">
                                    </a>
                                </div>
                                <p class="address_text">239 E 5th St, New York 
                                    NY 10003, USA
                                </p>
                                <div class="socail_links">
                                    <ul>
                                        <li>
                                            <a href="#">
                                                <i class="ti-facebook"></i>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="#">
                                                <i class="ti-pinterest"></i>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="#">
                                                <i class="fa fa-google-plus"></i>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="#">
                                                <i class="fa fa-linkedin"></i>
                                            </a>
                                        </li>
                                    </ul>
                                </div>

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
                            <p><!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. -->
                                Copyright &copy;<script>document.write(new Date().getFullYear());</script> All rights reserved | This template is made with <i class="ti-heart" aria-hidden="true"></i> by <a href="https://colorlib.com" target="_blank">Colorlib</a>
                                <!-- Link back to Colorlib can't be removed. Template is licensed under CC BY 3.0. --></p>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </footer>
        <!-- footer_end  -->

        <!-- Book Appointment Modal -->
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
                        <%@ include file="bookForm.jsp" %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Book Appointment Modal End -->


        <!-- JS here -->
        <script src="anipat-master/js/vendor/modernizr-3.5.0.min.js"></script>
        <script src="anipat-master/js/vendor/jquery-1.12.4.min.js"></script>
        <script src="anipat-master/js/popper.min.js"></script>
        <script src="anipat-master/js/bootstrap.min.js"></script>
        <script src="anipat-master/js/owl.carousel.min.js"></script>
        <script src="anipat-master/js/isotope.pkgd.min.js"></script>
        <script src="anipat-master/js/ajax-form.js"></script>
        <script src="anipat-master/js/waypoints.min.js"></script>
        <script src="anipat-master/js/jquery.counterup.min.js"></script>
        <script src="anipat-master/js/imagesloaded.pkgd.min.js"></script>
        <script src="anipat-master/js/scrollIt.js"></script>
        <script src="anipat-master/js/jquery.scrollUp.min.js"></script>
        <script src="anipat-master/js/wow.min.js"></script>
        <script src="anipat-master/js/nice-select.min.js"></script>
        <script src="anipat-master/js/jquery.slicknav.min.js"></script>
        <script src="anipat-master/js/jquery.magnific-popup.min.js"></script>
        <script src="anipat-master/js/plugins.js"></script>
        <script src="anipat-master/js/gijgo.min.js"></script>

        <!--contact js-->
        <script src="anipat-master/js/contact.js"></script>
        <script src="anipat-master/js/jquery.ajaxchimp.min.js"></script>
        <script src="anipat-master/js/jquery.form.js"></script>
        <script src="anipat-master/js/jquery.validate.min.js"></script>
        <script src="anipat-master/js/mail-script.js"></script>

        <script src="anipat-master/js/main.js"></script>
        <script>
                                    $('#datepicker').datepicker({
                                        iconsLibrary: 'fontawesome',
                                        disableDaysOfWeek: [0, 0],
                                        //     icons: {
                                        //      rightIcon: '<span class="fa fa-caret-down"></span>'
                                        //  }
                                    });
                                    $('#datepicker2').datepicker({
                                        iconsLibrary: 'fontawesome',
                                        icons: {
                                            rightIcon: '<span class="fa fa-caret-down"></span>'
                                        }

                                    });
                                    var timepicker = $('#timepicker').timepicker({
                                        format: 'HH.MM'
                                    });
        </script>
    </body>

</html>
