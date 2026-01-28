<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>

<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>VMCS Login - Veterinary Medical Center System</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#ec7f13",
                        "background-light": "#f8f7f6",
                        "background-dark": "#221910",
                    },
                    fontFamily: {
                        "display": ["Manrope", "sans-serif"]
                    },
                    borderRadius: {
                        "DEFAULT": "0.25rem",
                        "lg": "0.5rem",
                        "xl": "0.75rem",
                        "full": "9999px"
                    },
                },
            },
        }
    </script>
    <style>
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
        <!-- Decorative Pattern (Abstract) -->
        <div class="absolute inset-0 opacity-10 pointer-events-none">
            <div class="absolute top-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/2 -translate-y-1/2"></div>
            <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full translate-x-1/3 translate-y-1/3"></div>
        </div>
        <div class="relative z-10 max-w-md text-center">
            <div class="flex justify-center mb-8">
                <div class="size-16 text-white">
                    <svg fill="none" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                        <path d="M42.4379 44C42.4379 44 36.0744 33.9038 41.1692 24C46.8624 12.9336 42.2078 4 42.2078 4L7.01134 4C7.01134 4 11.6577 12.932 5.96912 23.9969C0.876273 33.9029 7.27094 44 7.27094 44L42.4379 44Z" fill="currentColor"></path>
                    </svg>
                </div>
            </div>
            <h1 class="text-4xl font-black mb-6 tracking-tight">Caring for your companions.</h1>
            <p class="text-lg font-medium opacity-90 leading-relaxed">
                Access the Veterinary Medical Center System for clinics, staff, and pet owners. Manage health records,
                appointments, and care plans in one place.
            </p>
            <div class="mt-12 w-full aspect-video rounded-xl bg-cover bg-center shadow-2xl"
                 data-alt="A veterinarian smiling while examining a healthy golden retriever dog"
                 style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCYKc2zm0IF8I7mUvjjwWGfJdmoNWw4dKpaw_EXLuqUNfDXou8B-egt4gDMFz_lMdn7sxnxIcNqGw4bTAw-hH1Rx8BcfwDomQ79QkNN8UqUUqtkpXNO1gk2kdx0Lo-tWcklFTfSV9ae2fzWEXfHmVm1tM_QAqvjkVyXGc0QBrKIHxY1fHpK4-vWNBy3FgfU2DMOwtFxneSUEKMCUMOHdGWizPE5JN_Iyd2zwBWaf0unnNezsO-lcTaTstOHrzWdvDs8ivbshP8dyX4');">
            </div>
        </div>
    </div>
    <!-- Right Login Panel -->
    <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-6 sm:p-12 md:p-24 bg-white dark:bg-background-dark">
        <div class="w-full max-w-[440px]">
            <!-- Mobile Logo -->
            <div class="lg:hidden flex items-center gap-3 mb-10">
                <div class="size-8 text-primary">
                    <svg fill="none" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                        <path d="M42.4379 44C42.4379 44 36.0744 33.9038 41.1692 24C46.8624 12.9336 42.2078 4 42.2078 4L7.01134 4C7.01134 4 11.6577 12.932 5.96912 23.9969C0.876273 33.9029 7.27094 44 7.27094 44L42.4379 44Z" fill="currentColor"></path>
                    </svg>
                </div>
                <span class="text-xl font-bold text-[#181411] dark:text-white">VMCS</span>
            </div>
            <div class="mb-6">
                <h2 class="text-3xl font-bold text-[#181411] dark:text-white mb-2">Welcome back</h2>
                <p class="text-[#897561] dark:text-gray-400 font-medium">Please enter your details to sign in.</p>
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

            <form class="space-y-5" method="post" action="login">
                <!-- Email Field -->
                <div class="flex flex-col gap-2">
                    <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Email Address</label>
                    <input
                            class="w-full h-12 rounded-lg border border-[#e6e0db] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 text-[#181411] dark:text-white placeholder:text-[#897561] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                            placeholder="name@example.com"
                            type="email"
                            name="email"
                            required
                    />
                </div>
                <!-- Password Field -->
                <div class="flex flex-col gap-2">
                    <div class="flex justify-between items-center">
                        <label class="text-[#181411] dark:text-gray-200 text-sm font-semibold">Password</label>
                        <a class="text-primary text-sm font-bold hover:underline" href="#">Forgot password?</a>
                    </div>
                    <div class="relative">
                        <input
                                class="w-full h-12 rounded-lg border border-[#e6e0db] dark:border-gray-700 bg-white dark:bg-[#2d241b] px-4 pr-12 text-[#181411] dark:text-white placeholder:text-[#897561] focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                                placeholder="Enter your password"
                                type="password"
                                name="password"
                                required
                        />
                        <button class="absolute right-4 top-1/2 -translate-y-1/2 text-[#897561] hover:text-primary transition-colors"
                                type="button">
                            <span class="material-symbols-outlined">visibility</span>
                        </button>
                    </div>
                </div>
                <!-- Remember Me -->
                <div class="flex items-center gap-2">
                    <input class="size-4 rounded border-[#e6e0db] text-primary focus:ring-primary" id="remember" type="checkbox" name="remember"/>
                    <label class="text-sm text-[#181411] dark:text-gray-300" for="remember">Remember for 30 days</label>
                </div>
                <!-- Login Button -->
                <button
                        class="w-full h-12 bg-primary hover:bg-[#d6710f] text-white font-bold rounded-lg transition-colors shadow-lg shadow-primary/20 mt-4"
                        type="submit">
                    Login
                </button>
            </form>

            <div class="relative my-8">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-[#e6e0db] dark:border-gray-700"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-4 bg-white dark:bg-background-dark text-[#897561] dark:text-gray-400 font-medium">
                        Or continue with
                    </span>
                </div>
            </div>
            <!-- Social Login (UI only) -->
            <button
                    class="w-full h-12 flex items-center justify-center gap-3 border border-[#e6e0db] dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors font-semibold text-[#181411] dark:text-white mb-8"
                    type="button">
                <svg class="size-5" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                          fill="#4285F4"></path>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                          fill="#34A853"></path>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"
                          fill="#FBBC05"></path>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                          fill="#EA4335"></path>
                </svg>
                Login with Google
            </button>

            <p class="text-center text-sm font-medium text-[#897561] dark:text-gray-400">
                Don't have an account?
                <a class="text-primary font-bold hover:underline ml-1" href="register">Sign up for free</a>
            </p>
        </div>
        <!-- Footer links -->
        <footer class="mt-auto pt-10 flex gap-6 text-xs text-[#897561] dark:text-gray-500 font-medium">
            <a class="hover:text-primary" href="#">Privacy Policy</a>
            <a class="hover:text-primary" href="#">Terms of Service</a>
            <a class="hover:text-primary" href="#">Support</a>
        </footer>
    </div>
</div>
</body>
</html>

