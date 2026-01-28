<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>

<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Customer Registration - VMCS</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@200..800&amp;family=Noto+Sans:wght@100..900&amp;display=swap" rel="stylesheet"/>
    <!-- Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
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
<body class="bg-background-light dark:bg-background-dark min-h-screen">
<div class="flex min-h-screen w-full flex-row overflow-hidden">
    <!-- Left Side: Immersive Visual Panel -->
    <div class="hidden lg:flex lg:w-1/2 relative flex-col justify-end p-12 bg-cover bg-center"
         data-alt="Happy owner hugging a golden retriever in soft sunlight"
         style='background-image: url("https://lh3.googleusercontent.com/aida-public/AB6AXuBiRLeL6kKjwbj8IuCz7MltpXFRFuD-qD-ushGRrsVFsJ1udYe8SfIg8_3aCy0RebY9rslex6y8EkepULZwdk0TJ8d_utzTef1BxQz3daaxXqcQFI2HlM4MpFCVkqsaNjk5EryY5RT3wobDuUGoCGvUN9lus4pOPLCmmws55Ajg2Z0lb8WpBrHSY7S5Uc3xSZl3rHmHlBTqfvRD-TQM-59nuQJ-pD9Oz75TEo6mLy0cOQY_ciPW2MpGBmu-f9bW3KUnuBgY7MPg1jM");'>
        <!-- Overlay for legibility -->
        <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent"></div>
        <div class="relative z-10 text-white space-y-4 max-w-lg">
            <div class="flex items-center gap-2 mb-6">
                <div class="size-8 text-primary">
                    <svg fill="currentColor" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                        <path d="M42.4379 44C42.4379 44 36.0744 33.9038 41.1692 24C46.8624 12.9336 42.2078 4 42.2078 4L7.01134 4C7.01134 4 11.6577 12.932 5.96912 23.9969C0.876273 33.9029 7.27094 44 7.27094 44L42.4379 44Z"></path>
                    </svg>
                </div>
                <span class="text-2xl font-bold tracking-tight">VMCS</span>
            </div>
            <h1 class="text-5xl font-black leading-tight tracking-[-0.033em]">
                Your pet's health starts here.
            </h1>
            <p class="text-lg font-medium opacity-90 leading-relaxed">
                Join our community of pet lovers and healthcare professionals. Expert care is just a registration away.
            </p>
            <div class="pt-8 flex gap-6 items-center">
                <div class="flex -space-x-3">
                    <img class="inline-block h-10 w-10 rounded-full ring-2 ring-white" data-alt="Client testimonial avatar 1" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCTpqL9G42tGlZyi_AZK9cBPUm0JVqgGNmyLWKtDLejElHFpg_rzHndOtxGqOJoFfiiTFrHkQKIvKe9Rb61gJuGwLgFRvtJwI4bqkSLTeQiq-AhvjMmxMNJLEsW1xeK4EVEgrUZ-_rKOPTwQIA7Dmw9kO_XjlpL5qociSNDI6MJZf9sX7Ur1WMgx6eH3zuTpZ4pJBpdf1zB1f3rQka4NCi5OFY0dAAYqGKkB0kSLpppoHJ7XHGnvPs4kp0et3xAj0lF3U6JEd9AgO8"/>
                    <img class="inline-block h-10 w-10 rounded-full ring-2 ring-white" data-alt="Client testimonial avatar 2" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBOgWsduqURUkbWf0PpZFr8Hu6mu7yMzR-r1saOKEnEePwloKMxmDIK-3i4LRvwaptZXe9CyZI81Vey6sMQ4TAPd0sjl88svvLxAfDsOwrUUvOYopdlvMKXk7QyaKJ2dUE9I7Az9qRkvTxZYWLdRORCx7oDCXvoACwsAdITo0B23qA9q_U0gmuoYruzfLzR9LaZCJ4o7-9R9JN090lgHCDHN8xm4zsN8DnraTa80EakNRhomM_CXHEo-QMYQdTi5cHcTFF1O73rE9w"/>
                    <img class="inline-block h-10 w-10 rounded-full ring-2 ring-white" data-alt="Client testimonial avatar 3" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDY6HSIJL5hEQcrWj-ju19MCR2CVnShEf7IFq2-rj5Y5gXa_0_nSILMSRQanBY_Cs7L7WBxhB36eYxBsB5SpSOs-51Mx6joVrTFmnUWFpgxzXRIt3-90ZK-vVFofIA4LYVzjd1xWJYDtD8BXNHx8g-a7cSy4Wvt86q6E7fw9ZcRQLxmTA_alifeBZka5RXTIGvE_IHPwCk2vU4JuYJiQsMmZOU-eklqGBX48d63Q1VJY-ZkMnmDkXfsYLltKI7VZ5iwUwHlHJnZkv4"/>
                </div>
                <p class="text-sm font-semibold italic">"The best decision for my Luna." — Maria S.</p>
            </div>
        </div>
    </div>
    <!-- Right Side: Registration Form -->
    <div class="w-full lg:w-1/2 flex flex-col justify-center items-center bg-white dark:bg-background-dark px-6 py-12 sm:px-12 md:px-20">
        <div class="w-full max-w-[480px]">
            <!-- Mobile Branding -->
            <div class="flex items-center gap-3 mb-8 lg:hidden">
                <div class="size-6 text-primary">
                    <svg fill="currentColor" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
                        <path d="M42.4379 44C42.4379 44 36.0744 33.9038 41.1692 24C46.8624 12.9336 42.2078 4 42.2078 4L7.01134 4C7.01134 4 11.6577 12.932 5.96912 23.9969C0.876273 33.9029 7.27094 44 7.27094 44L42.4379 44Z"></path>
                    </svg>
                </div>
                <h2 class="text-xl font-bold dark:text-white">VMCS</h2>
            </div>
            <!-- Form Header -->
            <div class="mb-4">
                <h2 class="text-3xl font-bold leading-tight text-gray-900 dark:text-white">Create an Account</h2>
                <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">Join our family of pet owners and start managing your pet's wellness journey.</p>
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

            <form class="space-y-4" method="post" action="register">
                <!-- Full Name -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700 dark:text-gray-300 ml-1">Full Name</label>
                    <div class="relative">
                        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">person</span>
                        <input class="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-zinc-800/50 py-3.5 pl-12 pr-4 text-gray-900 dark:text-white focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all placeholder:text-gray-400"
                               placeholder="Jane Doe" type="text" name="fullName" required/>
                    </div>
                </div>
                <!-- Email -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700 dark:text-gray-300 ml-1">Email Address</label>
                    <div class="relative">
                        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">mail</span>
                        <input class="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-zinc-800/50 py-3.5 pl-12 pr-4 text-gray-900 dark:text-white focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all placeholder:text-gray-400"
                               placeholder="name@example.com" type="email" name="email" required/>
                    </div>
                </div>
                <!-- Phone Number -->
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm font-semibold text-gray-700 dark:text-gray-300 ml-1">Phone Number</label>
                    <div class="relative">
                        <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">call</span>
                        <input class="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-zinc-800/50 py-3.5 pl-12 pr-4 text-gray-900 dark:text-white focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all placeholder:text-gray-400"
                               placeholder="+1 (555) 000-0000" type="tel" name="phone" required/>
                    </div>
                </div>
                <!-- Password Grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-semibold text-gray-700 dark:text-gray-300 ml-1">Password</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">lock</span>
                            <input class="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-zinc-800/50 py-3.5 pl-12 pr-4 text-gray-900 dark:text-white focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all placeholder:text-gray-400"
                                   placeholder="••••••••" type="password" name="password" required/>
                        </div>
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm font-semibold text-gray-700 dark:text-gray-300 ml-1">Confirm Password</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">security</span>
                            <input class="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-zinc-800/50 py-3.5 pl-12 pr-4 text-gray-900 dark:text-white focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all placeholder:text-gray-400"
                                   placeholder="••••••••" type="password" name="confirmPassword" required/>
                        </div>
                    </div>
                </div>
                <!-- Terms -->
                <div class="flex items-start gap-3 py-2">
                    <input class="mt-1 h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary" id="terms" type="checkbox" name="terms" required/>
                    <label class="text-xs text-gray-600 dark:text-gray-400 leading-relaxed" for="terms">
                        By creating an account, you agree to VMCS <a class="text-primary font-bold hover:underline" href="#">Terms of Service</a> and <a class="text-primary font-bold hover:underline" href="#">Privacy Policy</a>.
                    </label>
                </div>
                <!-- Submit Button -->
                <button class="w-full bg-primary hover:bg-primary/90 text-white font-bold py-4 rounded-xl shadow-lg shadow-primary/20 transition-all active:scale-[0.98] mt-4 flex items-center justify-center gap-2"
                        type="submit">
                    Create Account
                    <span class="material-symbols-outlined">arrow_forward</span>
                </button>
            </form>
            <!-- Divider -->
            <div class="my-8 flex items-center gap-4">
                <div class="h-[1px] flex-1 bg-gray-200 dark:bg-gray-700"></div>
                <span class="text-xs font-bold text-gray-400 uppercase tracking-widest">or sign up with</span>
                <div class="h-[1px] flex-1 bg-gray-200 dark:bg-gray-700"></div>
            </div>
            <!-- Social Login Buttons -->
            <div class="grid grid-cols-2 gap-4 mb-8">
                <button class="flex items-center justify-center gap-2 py-3 px-4 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-zinc-800 transition-colors" type="button">
                    <svg class="w-5 h-5" viewBox="0 0 24 24">
                        <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"></path>
                        <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path>
                        <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"></path>
                        <path d="M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path>
                    </svg>
                    <span class="text-sm font-bold text-gray-700 dark:text-gray-300">Google</span>
                </button>
                <button class="flex items-center justify-center gap-2 py-3 px-4 rounded-lg border border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-zinc-800 transition-colors" type="button">
                    <svg class="w-5 h-5 text-blue-600" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"></path>
                    </svg>
                    <span class="text-sm font-bold text-gray-700 dark:text-gray-300">Facebook</span>
                </button>
            </div>
            <!-- Footer -->
            <p class="text-center text-sm text-gray-600 dark:text-gray-400">
                Already have an account?
                <a class="text-primary font-bold hover:underline transition-all" href="login">Sign in here</a>
            </p>
        </div>
    </div>
</div>
</body>
</html>

