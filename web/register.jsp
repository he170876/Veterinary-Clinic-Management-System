<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String fullName = (String) request.getAttribute("fullName");
    String email = (String) request.getAttribute("email");
    String phone = (String) request.getAttribute("phone");
    String errorMsg = (String) request.getAttribute("error");
    
    if (fullName == null) fullName = "";
    if (email == null) email = "";
    if (phone == null) phone = "";
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Create Account - Anipats</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#f14437",
                        "primary-dark": "#d6362b",
                        "background-light": "#fcfcfc",
                        "background-dark": "#1a1614",
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
<body class="bg-background-light min-h-screen flex items-center justify-center">
<div class="flex flex-col lg:flex-row w-full min-h-screen">
    <!-- Left Brand Panel -->
    <div class="hidden lg:flex lg:w-1/2 bg-primary flex-col justify-center items-center p-12 text-white relative overflow-hidden">
        <div class="absolute inset-0 opacity-10 pointer-events-none">
            <div class="absolute top-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/2 -translate-y-1/2"></div>
            <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full translate-x-1/3 translate-y-1/3"></div>
        </div>
        <div class="relative z-10 max-w-md text-center">
            <div class="flex justify-center mb-10">
                <div class="flex items-center gap-3">
                    <div class="p-3 bg-white text-primary rounded-xl shadow-xl">
                        <span class="material-symbols-outlined !text-4xl">pets</span>
                    </div>
                    <span class="text-4xl font-black tracking-tight">Anipats</span>
                </div>
            </div>
            <h1 class="text-4xl font-extrabold mb-6 tracking-tight leading-tight">
                Your pet's health journey starts here.
            </h1>
            <p class="text-lg font-medium opacity-90 leading-relaxed">
                Join thousands of pet owners who trust Anipats for their furry friends' healthcare needs.
            </p>
            <div class="mt-12 w-full aspect-[4/3] rounded-2xl bg-cover bg-center shadow-2xl border-4 border-white/10"
                 style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuBiRLeL6kKjwbj8IuCz7MltpXFRFuD-qD-ushGRrsVFsJ1udYe8SfIg8_3aCy0RebY9rslex6y8EkepULZwdk0TJ8d_utzTef1BxQz3daaxXqcQFI2HlM4MpFCVkqsaNjk5EryY5RT3wobDuUGoCGvUN9lus4pOPLCmmws55Ajg2Z0lb8WpBrHSY7S5Uc3xSZl3rHmHlBTqfvRD-TQM-59nuQJ-pD9Oz75TEo6mLy0cOQY_ciPW2MpGBmu-f9bW3KUnuBgY7MPg1jM');">
            </div>
        </div>
    </div>
    <!-- Right Registration Panel -->
    <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-6 sm:p-12 md:p-20 bg-white">
        <div class="w-full max-w-[440px]">
            <a href="<%= request.getContextPath() %>/index.jsp" class="inline-flex items-center gap-2 text-gray-500 hover:text-primary font-medium text-sm mb-4 -mt-2">
                <span class="material-symbols-outlined text-lg">arrow_back</span> Back to Home
            </a>
            <!-- Mobile Logo -->
            <div class="lg:hidden flex items-center gap-3 mb-8">
                <div class="size-10 bg-primary text-white rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">pets</span>
                </div>
                <span class="text-2xl font-black text-gray-900 tracking-tight">Anipats</span>
            </div>

            <div class="mb-6">
                <h2 class="text-3xl font-bold text-gray-900 mb-2">Create Account</h2>
                <p class="text-gray-500 font-medium">Fill in your details to get started.</p>
            </div>

            <!-- Error Message -->
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-700 flex items-center gap-2">
                <span class="material-symbols-outlined text-lg">error</span>
                <%= errorMsg %>
            </div>
            <% } %>

            <form class="space-y-4" method="post" action="<%= request.getContextPath() %>/register">
                <!-- Full Name -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700">Full Name <span class="text-red-500">*</span></label>
                    <input class="w-full h-12 rounded-lg border border-gray-200 bg-white px-4 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="John Doe"
                           type="text"
                           name="fullName"
                           value="<%= fullName %>"
                           required/>
                </div>

                <!-- Email -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700">Email Address <span class="text-red-500">*</span></label>
                    <input class="w-full h-12 rounded-lg border border-gray-200 bg-white px-4 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="john@example.com"
                           type="email"
                           name="email"
                           value="<%= email %>"
                           required/>
                </div>

                <!-- Phone -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700">Phone Number</label>
                    <input class="w-full h-12 rounded-lg border border-gray-200 bg-white px-4 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="+1 (555) 000-0000"
                           type="tel"
                           name="phone"
                           value="<%= phone %>"/>
                </div>

                <!-- Password -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700">Password <span class="text-red-500">*</span></label>
                    <div class="relative">
                        <input class="w-full h-12 rounded-lg border border-gray-200 bg-white px-4 pr-12 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                               placeholder="Min. 6 characters"
                               type="password"
                               name="password"
                               id="password"
                               required
                               minlength="6"/>
                        <button class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-primary transition-colors" type="button" onclick="togglePassword('password', this)">
                            <span class="material-symbols-outlined">visibility</span>
                        </button>
                    </div>
                </div>

                <!-- Confirm Password -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700">Confirm Password <span class="text-red-500">*</span></label>
                    <div class="relative">
                        <input class="w-full h-12 rounded-lg border border-gray-200 bg-white px-4 pr-12 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                               placeholder="Repeat password"
                               type="password"
                               name="confirmPassword"
                               id="confirmPassword"
                               required
                               minlength="6"/>
                        <button class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-primary transition-colors" type="button" onclick="togglePassword('confirmPassword', this)">
                            <span class="material-symbols-outlined">visibility</span>
                        </button>
                    </div>
                </div>

                <!-- Terms -->
                <div class="flex items-start gap-3 pt-2">
                    <input class="mt-1 h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary" id="terms" type="checkbox" name="terms" required/>
                    <label class="text-xs text-gray-500 leading-relaxed" for="terms">
                        By creating an account, you agree to Anipats 
                        <a class="text-primary font-semibold hover:underline" href="#">Terms of Service</a> and 
                        <a class="text-primary font-semibold hover:underline" href="#">Privacy Policy</a>.
                    </label>
                </div>

                <!-- Submit Button -->
                <button class="w-full h-12 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg transition-all shadow-lg shadow-primary/20 mt-4 active:scale-[0.98] flex items-center justify-center gap-2"
                        type="submit">
                    Create Account
                    <span class="material-symbols-outlined">arrow_forward</span>
                </button>
            </form>

            <div class="relative my-6">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-200"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-4 bg-white text-gray-400 font-medium">or</span>
                </div>
            </div>

            <!-- Google Sign Up (UI only) -->
            <button class="w-full h-12 flex items-center justify-center gap-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors font-semibold text-gray-700 mb-6" type="button">
                <svg class="size-5" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"></path>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"></path>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path>
                </svg>
                Sign up with Google
            </button>

            <p class="text-center text-sm font-medium text-gray-500">
                Already have an account?
                <a class="text-primary font-bold hover:text-primary-dark ml-1" href="<%= request.getContextPath() %>/login">Sign in</a>
            </p>
        </div>

        <footer class="mt-auto pt-8 flex gap-6 text-xs text-gray-400 font-medium">
            <a class="hover:text-primary transition-colors" href="#">Privacy</a>
            <a class="hover:text-primary transition-colors" href="#">Terms</a>
            <a class="hover:text-primary transition-colors" href="#">Support</a>
        </footer>
    </div>
</div>

<script>
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const icon = btn.querySelector('.material-symbols-outlined');
        if (input.type === 'password') {
            input.type = 'text';
            icon.textContent = 'visibility_off';
        } else {
            input.type = 'password';
            icon.textContent = 'visibility';
        }
    }
</script>
</body>
</html>
