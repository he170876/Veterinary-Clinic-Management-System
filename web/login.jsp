<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Anipats Login - Veterinary Medical Center System</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
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
                    borderRadius: {
                        "DEFAULT": "0.375rem",
                        "lg": "0.625rem",
                        "xl": "1rem",
                        "full": "9999px"
                    },
                },
            },
        }
    </script>
    <style type="text/tailwindcss">
        body {
            font-family: 'Manrope', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#181411] dark:text-white min-h-screen flex items-center justify-center">
<div class="flex flex-col lg:flex-row w-full min-h-screen">
    <!-- Left Brand Panel -->
    <div class="hidden lg:flex lg:w-1/2 bg-primary flex-col justify-center items-center p-12 text-white relative overflow-hidden">
        <div class="absolute inset-0 opacity-10 pointer-events-none">
            <div class="absolute top-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/2 -translate-y-1/2"></div>
            <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full translate-x-1/3 translate-y-1/3"></div>
            <div class="absolute top-1/2 left-1/2 w-full h-full border-[60px] border-white rounded-full -translate-x-1/2 -translate-y-1/2 opacity-20"></div>
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
                Compassionate care for every patient.
            </h1>
            <p class="text-lg font-medium opacity-90 leading-relaxed">
                Empowering veterinary professionals with the Anipats Medical Center System. Manage patient health, streamline operations, and enhance pet owner experiences.
            </p>
            <div class="mt-12 w-full aspect-[4/3] rounded-2xl bg-cover bg-center shadow-2xl border-4 border-white/10"
                 style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCYKc2zm0IF8I7mUvjjwWGfJdmoNWw4dKpaw_EXLuqUNfDXou8B-egt4gDMFz_lMdn7sxnxIcNqGw4bTAw-hH1Rx8BcfwDomQ79QkNN8UqUUqtkpXNO1gk2kdx0Lo-tWcklFTfSV9ae2fzWEXfHmVm1tM_QAqvjkVyXGc0QBrKIHxY1fHpK4-vWNBy3FgfU2DMOwtFxneSUEKMCUMOHdGWizPE5JN_Iyd2zwBWaf0unnNezsO-lcTaTstOHrzWdvDs8ivbshP8dyX4');">
            </div>
        </div>
    </div>
    <!-- Right Login Panel -->
    <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-6 sm:p-12 md:p-24 bg-white dark:bg-background-dark">
        <div class="w-full max-w-[440px]">
            <a href="<%= request.getContextPath() %>/index.jsp" class="inline-flex items-center gap-2 text-[#64748b] dark:text-gray-400 hover:text-primary dark:hover:text-primary font-medium text-sm mb-4 -mt-2">
                <span class="material-symbols-outlined text-lg">arrow_back</span> Back to Home
            </a>
            <!-- Mobile Logo -->
            <div class="lg:hidden flex items-center gap-3 mb-10">
                <div class="size-10 bg-primary text-white rounded-lg flex items-center justify-center">
                    <span class="material-symbols-outlined">pets</span>
                </div>
                <span class="text-2xl font-black text-[#181411] dark:text-white tracking-tight">Anipats</span>
            </div>
            <div class="mb-6">
                <h2 class="text-3xl font-bold text-[#181411] dark:text-white mb-2">Welcome Back</h2>
                <p class="text-[#64748b] dark:text-gray-400 font-medium">Please enter your credentials to access the system.</p>
            </div>

            <!-- Server-side error -->
            <%
                String errorMsg = (String) request.getAttribute("error");
                if (errorMsg != null && !errorMsg.isEmpty()) {
            %>
            <div class="mb-4 rounded-lg border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-700">
                <%= errorMsg %>
            </div>
            <%
                }
            %>

            <form class="space-y-5" method="post" action="<%= request.getContextPath() %>/login">
                <!-- Email Field -->
                <div class="flex flex-col gap-2">
                    <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Email Address</label>
                    <input class="w-full h-12 rounded-lg border border-[#e2e8f0] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 text-[#181411] dark:text-white placeholder:text-[#94a3b8] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                           placeholder="vets@anipats.com"
                           type="email"
                           name="email"
                           required/>
                </div>
                <!-- Password Field -->
                <div class="flex flex-col gap-2">
                    <div class="flex justify-between items-center">
                        <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Password</label>
                        <a class="text-primary text-sm font-bold hover:text-primary-dark transition-colors" href="#">Forgot password?</a>
                    </div>
                    <div class="relative">
                        <input class="w-full h-12 rounded-lg border border-[#e2e8f0] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 pr-12 text-[#181411] dark:text-white placeholder:text-[#94a3b8] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                               placeholder="••••••••"
                               type="password"
                               name="password"
                               required/>
                        <button class="absolute right-4 top-1/2 -translate-y-1/2 text-[#94a3b8] hover:text-primary transition-colors" type="button" onclick="togglePassword(this)">
                            <span class="material-symbols-outlined">visibility</span>
                        </button>
                    </div>
                </div>
                <!-- Remember Me -->
                <div class="flex items-center gap-2">
                    <input class="size-4 rounded border-[#e2e8f0] text-primary focus:ring-primary" id="remember" type="checkbox" name="remember"/>
                    <label class="text-sm text-[#475569] dark:text-gray-300 font-medium" for="remember">Keep me logged in</label>
                </div>
                <!-- Submit Button -->
                <button class="w-full h-12 bg-primary hover:bg-primary-dark text-white font-bold rounded-lg transition-all shadow-lg shadow-primary/20 mt-4 active:scale-[0.98]" type="submit">
                    Sign In
                </button>
            </form>

            <div class="relative my-8">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-[#e2e8f0] dark:border-gray-700"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-4 bg-white dark:bg-background-dark text-[#64748b] dark:text-gray-400 font-medium">Alternatively</span>
                </div>
            </div>

            <!-- Google Login (UI only) -->
            <button class="w-full h-12 flex items-center justify-center gap-3 border border-[#e2e8f0] dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors font-semibold text-[#181411] dark:text-white mb-8" type="button">
                <svg class="size-5" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"></path>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"></path>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path>
                </svg>
                Sign in with Google
            </button>

            <p class="text-center text-sm font-medium text-[#64748b] dark:text-gray-400">
                New to Anipats?
                <a class="text-primary font-bold hover:text-primary-dark ml-1" href="<%= request.getContextPath() %>/register">Create an account</a>
            </p>
        </div>
        <!-- Footer -->
        <footer class="mt-auto pt-10 flex flex-wrap justify-center gap-6 text-xs text-[#94a3b8] dark:text-gray-500 font-medium">
            <a class="hover:text-primary transition-colors" href="#">Privacy Policy</a>
            <a class="hover:text-primary transition-colors" href="#">Terms of Service</a>
            <a class="hover:text-primary transition-colors" href="#">Support Center</a>
            <span class="ml-auto opacity-50">© 2024 Anipats VMCS</span>
        </footer>
    </div>
</div>

<script>
    function togglePassword(btn) {
        const input = btn.parentElement.querySelector('input');
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
