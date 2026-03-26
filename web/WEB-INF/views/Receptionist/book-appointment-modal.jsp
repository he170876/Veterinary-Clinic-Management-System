<%--
Book Appointment modal for receptionist (Dashboard & ViewListAppointment).
Requires request attribute "services" (List<model.Service>).
Preferred Time = AM/PM dropdown. Live phone lookup: if customer found, Pet Name becomes dropdown.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<div id="bookAppointmentModal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4" aria-modal="true">
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" data-close-modal="bookAppointmentModal"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="sticky top-0 bg-white dark:bg-slate-900 px-6 py-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between z-10">
            <h2 class="text-xl font-bold text-slate-800 dark:text-white">Book Appointment</h2>
            <button type="button" class="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors close-book-modal" aria-label="Close">
                <span class="material-symbols-outlined text-2xl">close</span>
            </button>
        </div>
        <div class="p-6">
            <form id="receptionistBookForm" class="space-y-4">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="book_phone" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Phone Number *</label>
                        <input type="tel" id="book_phone" name="phone" placeholder="0123456789 (10 digits, start with 0)" pattern="0[0-9]{9}" maxlength="10" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                        <p id="book_phoneStatus" class="text-xs mt-1 text-slate-500 hidden"></p>
                    </div>
                    <div>
                        <label for="book_email" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Email Address *</label>
                        <input type="email" id="book_email" name="email" placeholder="your@email.com" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="book_ownerName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Owner Name *</label>
                        <input type="text" id="book_ownerName" name="ownerName" placeholder="Enter full name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Select Service(s) *</label>
                        <div class="relative" id="book_serviceDropdownWrap">
                            <button type="button" id="book_serviceDropdownBtn" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20 text-left flex items-center justify-between text-sm font-semibold">
                                <span id="book_serviceDropdownText" class="text-sm font-semibold">Choose service(s)</span>
                                <span class="material-symbols-outlined text-sm leading-none">expand_more</span>
                            </button>
                            <div id="book_serviceDropdown" class="hidden absolute top-full left-0 right-0 mt-1 max-h-56 overflow-y-auto rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 shadow-lg z-20 p-2">
                                <c:if test="${not empty services}">
                                    <c:forEach var="sv" items="${services}">
                                        <label class="flex items-center gap-2 px-2 py-1 rounded hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer text-sm font-medium text-slate-800 dark:text-slate-200">
                                            <input type="checkbox" name="serviceIds" value="${sv.serviceId}" class="book-service-checkbox"/>
                                            <span class="leading-tight">${sv.name}</span>
                                        </label>
                                    </c:forEach>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div id="book_petNameWrapper">
                        <label for="book_petSelect" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet *</label>
                        <select id="book_petSelect" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
                            <option value="__new__">Add a new pet</option>
                        </select>
                        <div id="book_newPetFields" class="mt-3">
                            <label for="book_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>
                            <input type="text" id="book_petName" name="petName" placeholder="Your pet's name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                        </div>
                        <input type="hidden" id="book_petId" name="petId" value=""/>
                    </div>
                    <div>
                        <label for="book_petType" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Type *</label>
                        <select id="book_petType" name="petType" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
                            <option value="">Select pet type</option>
                            <option value="Dog">Dog</option>
                            <option value="Cat">Cat</option>
                            <option value="Bird">Bird</option>
                            <option value="Rabbit">Rabbit</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="book_appointmentDate" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Preferred Date *</label>
                        <input type="date" id="book_appointmentDate" name="appointmentDate" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                    <div>
                        <label for="book_timeSlot" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Preferred Time *</label>
                        <select id="book_timeSlot" name="timeSlot" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
                            <option value="">--:--</option>
                            <option value="AM">in the Morning</option>
                            <option value="PM">in the Afternoon</option>
                        </select>
                    </div>
                </div>
                <div>
                    <textarea id="book_notes" name="notes" rows="4" placeholder="" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20 resize-none min-h-[100px] max-h-[100px]"></textarea>
                </div>
                <button type="submit" class="w-full py-3 rounded-xl bg-primary text-white font-semibold hover:opacity-90 transition-opacity">
                    Confirm Booking
                </button>
                <p class="text-xs text-slate-500 dark:text-slate-400 text-center">By clicking confirm, you agree to our terms of service and privacy policy. We'll send a confirmation email shortly.</p>
            </form>
        </div>
    </div>
</div>
<!-- Toast khi book thành công (dùng chung cho Dashboard & ViewListAppointment) -->
<div id="bookSuccessToast" class="fixed top-6 right-6 bg-green-500 text-white px-6 py-3 rounded-xl shadow-lg flex items-center gap-2 z-[2000]" style="display: none;">
    <span class="material-symbols-outlined">check_circle</span>
    <span id="bookSuccessToastMessage">Appointment booked successfully.</span>
</div>

<script>
    (function() {
        var ctx = '${ctx}';
        var modal = document.getElementById('bookAppointmentModal');
        var phoneInput = document.getElementById('book_phone');
        var ownerInput = document.getElementById('book_ownerName');
        var emailInput = document.getElementById('book_email');
        var petNameWrapper = document.getElementById('book_petNameWrapper');
        var petSelect = document.getElementById('book_petSelect');
        var newPetFields = document.getElementById('book_newPetFields');
        var petNameInput = document.getElementById('book_petName');
        var bookPetId = document.getElementById('book_petId');
        var petTypeSelect = document.getElementById('book_petType');
        var phoneStatus = document.getElementById('book_phoneStatus');
        var form = document.getElementById('receptionistBookForm');
        var NEW_PET_VALUE = '__new__';
        var serviceDropdownBtn = document.getElementById('book_serviceDropdownBtn');
        var serviceDropdown = document.getElementById('book_serviceDropdown');
        var serviceDropdownText = document.getElementById('book_serviceDropdownText');

        /**
         * =========================
         * Receptionist Book Modal
         * =========================
         *
         * Client-side responsibilities:
         * - Live lookup by phone to auto-fill Owner + Email and populate pet dropdown
         * - Lock fields when an existing customer is found (prevent accidental edits)
         * - Enforce same-day slot cutoffs in the UI (AM after 12:00 disabled, PM after 20:00 disabled)
         * - Submit booking via POST /Receptionist/BookAppointment (URL-encoded body)
         *
         * Server-side contract (see ReceptionistBookAppointmentServlet):
         * - Response is JSON: { success:boolean, message:string, appointmentId?:number }
         */
        
        function getTodayLocal() {
            var d = new Date();
            return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
        }
        function isToday(dateStr) {
            return dateStr && dateStr === getTodayLocal();
        }
        function updateTimeSlotOptions() {
            var dateEl = document.getElementById('book_appointmentDate');
            var slotEl = document.getElementById('book_timeSlot');
            if (!dateEl || !slotEl) return;
            var selectedDate = dateEl.value;
            var now = new Date();
            var hour = now.getHours();
            var minutes = now.getMinutes();
            // Time constants for booking rules (same-day only)
            var NOON_HOUR_24 = 12; // 12:00
            var EVENING_CUTOFF_HOUR_12 = 8; // 8PM
            var EVENING_CUTOFF_HOUR_24 = 12 + EVENING_CUTOFF_HOUR_12; // 20:00
            var currentTotalMinutes = hour * 60 + minutes;
            var noonTotalMinutes = NOON_HOUR_24 * 60;
            var cutoffTotalMinutes = EVENING_CUTOFF_HOUR_24 * 60;
            var amOpt = slotEl.querySelector('option[value="AM"]');
            var pmOpt = slotEl.querySelector('option[value="PM"]');
            if (amOpt) amOpt.disabled = false;
            if (pmOpt) pmOpt.disabled = false;

            if (isToday(selectedDate)) {
                // Disable AM after 12:00
                if (amOpt) {
                    amOpt.disabled = currentTotalMinutes > noonTotalMinutes;
                }

                // Disable PM after 8:00 PM
                if (pmOpt) {
                    pmOpt.disabled = currentTotalMinutes > cutoffTotalMinutes;
                }

                // Ensure selected value is still enabled
                if (slotEl.value === 'AM' && amOpt && amOpt.disabled) {
                    if (pmOpt && !pmOpt.disabled) slotEl.value = 'PM';
                    else slotEl.value = '';
                }
                if (slotEl.value === 'PM' && pmOpt && pmOpt.disabled) {
                    if (amOpt && !amOpt.disabled) slotEl.value = 'AM';
                    else slotEl.value = '';
                }
            }
        }
        function showModal() {
            if (modal) {
                modal.classList.remove('hidden');
                modal.classList.add('flex');
                document.body.style.overflow = 'hidden';

                // Reset state (so readOnly/disabled flags from lookup won't persist)
                if (phoneInput) phoneInput.value = '';
                if (phoneStatus) {
                    phoneStatus.classList.add('hidden');
                    phoneStatus.textContent = '';
                }
                if (ownerInput) {
                    ownerInput.readOnly = false;
                    ownerInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                    ownerInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
                    ownerInput.value = '';
                }
                if (emailInput) {
                    emailInput.readOnly = false;
                    emailInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                    emailInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
                    emailInput.value = '';
                }
                if (bookPetId) bookPetId.value = '';
                if (petSelect) {
                    petSelect.innerHTML = '<option value="' + NEW_PET_VALUE + '">Add a new pet</option>';
                    petSelect.value = NEW_PET_VALUE;
                }
                if (newPetFields) newPetFields.classList.remove('hidden');
                if (petNameInput) {
                    petNameInput.disabled = false;
                    petNameInput.required = true;
                }
                if (petTypeSelect) {
                    petTypeSelect.disabled = false;
                    petTypeSelect.classList.remove('bg-slate-100', 'dark:bg-slate-700');
                    petTypeSelect.value = '';
                }

                // Reset date/slot defaults and apply same-day cutoff rules.
                var today = getTodayLocal();
                var dateEl = document.getElementById('book_appointmentDate');
                if (dateEl) {
                    dateEl.setAttribute('min', today);
                    if (dateEl.value && dateEl.value < today) dateEl.value = today;
                }
                updateTimeSlotOptions();
            }
        }
        
        function hideModal() {
            if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                document.body.style.overflow = '';
            }
        }
        
        function updateServiceSummary() {
            var selected = form ? form.querySelectorAll('input[name="serviceIds"]:checked') : [];
            if (!serviceDropdownText) return;
            if (!selected || selected.length === 0) {
                serviceDropdownText.textContent = 'Choose service(s)';
                return;
            }
            serviceDropdownText.textContent = selected.length + ' service(s) selected';
        }
        
        if (serviceDropdownBtn && serviceDropdown) {
            serviceDropdownBtn.addEventListener('click', function() {
                serviceDropdown.classList.toggle('hidden');
            });
            
            document.addEventListener('click', function(e) {
                if (!serviceDropdown.contains(e.target) && !serviceDropdownBtn.contains(e.target)) {
                    serviceDropdown.classList.add('hidden');
                }
            });
            
            serviceDropdown.addEventListener('change', function() {
                updateServiceSummary();
            });
        }
        
        var petTypeValues = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
        function matchPetType(dbSpecies) {
            var v = (dbSpecies || '').trim().toLowerCase();
            if (!v) return '';
            for (var i = 0; i < petTypeValues.length; i++) {
                if (petTypeValues[i].toLowerCase() === v) return petTypeValues[i];
            }
            return 'Other';
        }

        function setPetTypeFromSpecies(species, locked) {
            if (!petTypeSelect) return;
            if (locked) {
                var v = matchPetType(species);
                petTypeSelect.value = v || '';
                petTypeSelect.disabled = true;
                petTypeSelect.classList.add('bg-slate-100', 'dark:bg-slate-700');
            } else {
                petTypeSelect.value = '';
                petTypeSelect.disabled = false;
                petTypeSelect.classList.remove('bg-slate-100', 'dark:bg-slate-700');
            }
        }

        function setPetUIFromSelection() {
            if (!petSelect) return;
            var value = petSelect.value;
            var isNewPet = !value || value === NEW_PET_VALUE;

            if (bookPetId) bookPetId.value = isNewPet ? '' : value;

            if (newPetFields) {
                if (isNewPet) newPetFields.classList.remove('hidden');
                else newPetFields.classList.add('hidden');
            }

            if (petNameInput) {
                petNameInput.disabled = !isNewPet;
                petNameInput.required = isNewPet;
            }

            if (!isNewPet) {
                var opt = petSelect.options[petSelect.selectedIndex];
                var species = opt ? (opt.getAttribute('data-species') || '') : '';
                setPetTypeFromSpecies(species, true);
            } else {
                setPetTypeFromSpecies('', false);
            }
        }

        function renderPetSelectOptions(pets) {
            if (!petSelect) return;

            var html = '';
            if (pets && pets.length > 0) {
                for (var i = 0; i < pets.length; i++) {
                    var p = pets[i] || {};
                    var species = p.species != null ? String(p.species) : '';
                    html += '<option value="' + p.petId + '" data-species="' + species.replace(/"/g, '&quot;') + '">' + (p.name || '') + '</option>';
                }
            }

            html += '<option value="' + NEW_PET_VALUE + '">Add a new pet</option>';
            petSelect.innerHTML = html;

            if (pets && pets.length > 0) {
                petSelect.value = String(pets[0].petId);
            } else {
                petSelect.value = NEW_PET_VALUE;
            }
            setPetUIFromSelection();
        }

        function setOwnerEmailLocked(locked, fullName, email) {
            if (ownerInput) {
                if (locked) {
                    ownerInput.value = fullName || '';
                    ownerInput.readOnly = true;
                    ownerInput.classList.remove('bg-slate-50', 'dark:bg-slate-800');
                    ownerInput.classList.add('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                } else {
                    ownerInput.readOnly = false;
                    ownerInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                    ownerInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
                }
            }
            if (emailInput) {
                if (locked) {
                    emailInput.value = email || '';
                    emailInput.readOnly = true;
                    emailInput.classList.remove('bg-slate-50', 'dark:bg-slate-800');
                    emailInput.classList.add('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                } else {
                    emailInput.readOnly = false;
                    emailInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                    emailInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
                }
            }
        }

        if (petSelect) {
            petSelect.addEventListener('change', function() {
                setPetUIFromSelection();
            });
        }
            
            var lookupTimeout;
            function onPhoneChange() {
                var phone = (phoneInput && phoneInput.value) ? phoneInput.value.trim() : '';
                if (phoneStatus) {
                    phoneStatus.classList.add('hidden');
                    phoneStatus.textContent = '';
                }
                if (phone.length < 10) {
                    setOwnerEmailLocked(false);
                    renderPetSelectOptions([]);
                    return;
                }
                clearTimeout(lookupTimeout);
                lookupTimeout = setTimeout(function() {
                    fetch(ctx + '/Receptionist/LookupCustomerByPhone?phone=' + encodeURIComponent(phone))
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (phoneStatus) {
                            phoneStatus.classList.remove('hidden');
                            if (data.found) {
                                phoneStatus.textContent = 'Customer found. Select pet below.';
                                phoneStatus.className = 'text-xs mt-1 text-green-600 dark:text-green-400';
                                setOwnerEmailLocked(true, data.customer.fullName || '', data.customer.email || '');
                                renderPetSelectOptions(data.pets || []);
                            } else {
                                phoneStatus.textContent = 'New customer. Enter pet details.';
                                phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                                setOwnerEmailLocked(false);
                                renderPetSelectOptions([]);
                            }
                        }
                    })
                            .catch(function() {
                                if (phoneStatus) {
                                    phoneStatus.classList.remove('hidden');
                                    phoneStatus.textContent = 'Could not lookup. Enter details manually.';
                                    phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                                }
                                setOwnerEmailLocked(false);
                                renderPetSelectOptions([]);
                            });
                        }, 400);
                    }
                    
                    if (phoneInput) {
                        phoneInput.addEventListener('blur', onPhoneChange);
                        phoneInput.addEventListener('input', onPhoneChange);
                    }
                    var dateEl = document.getElementById('book_appointmentDate');
                    if (dateEl) {
                        dateEl.addEventListener('change', function() {
                            var today = getTodayLocal();
                            if (this.value && this.value < today) this.value = today;
                            updateTimeSlotOptions();
                        });
                        dateEl.addEventListener('input', function() {
                            var today = getTodayLocal();
                            if (this.value && this.value < today) this.value = today;
                            updateTimeSlotOptions();
                        });
                    }
                    
                    modal.querySelectorAll('.close-book-modal, [data-close-modal="bookAppointmentModal"]').forEach(function(btn) {
                        btn.addEventListener('click', hideModal);
                    });
                    
                    if (form) {
                        form.addEventListener('submit', function(e) {
                            e.preventDefault();
                            
                            var selectedServices = form.querySelectorAll('input[name="serviceIds"]:checked');
                            if (!selectedServices || selectedServices.length === 0) {
                                alert('Please select at least one service.');
                                return;
                            }
                            
                            var bookPetIdEl = document.getElementById('book_petId');
                            var petSelect = document.getElementById('book_petSelect');
                            if (petSelect && bookPetIdEl) {
                                bookPetIdEl.value = (petSelect.value && petSelect.value !== NEW_PET_VALUE)
                                    ? petSelect.value
                                    : '';
                            }
                            // Build body so every checked serviceIds is sent (some browsers mishandle new URLSearchParams(FormData)).
                            var params = new URLSearchParams();
                            for (var i = 0; i < form.elements.length; i++) {
                                var field = form.elements[i];
                                if (!field.name || field.disabled) continue;
                                var fType = (field.type || '').toLowerCase();
                                if (fType === 'file') continue;
                                if (fType === 'checkbox' || fType === 'radio') {
                                    if (!field.checked) continue;
                                }
                                params.append(field.name, field.value);
                            }

                            fetch(ctx + '/Receptionist/BookAppointment', {
                                method: 'POST',
                                credentials: 'same-origin',
                                headers: {
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                                },
                                body: params
                            })
                                .then(function(r) {
                                    return r.text().then(function(text) {
                                        var ct = (r.headers.get('Content-Type') || '').toLowerCase();
                                        if (r.redirected || r.status === 302 || r.status === 301) {
                                            throw new Error('Session expired or access denied. Please refresh the page and sign in again.');
                                        }
                                        if (text && !text.trim().startsWith('{') && !text.trim().startsWith('[')) {
                                            console.error('Book appointment non-JSON response', r.status, ct, text.substring(0, 400));
                                            throw new Error('Server returned a non-JSON response. If you were signed out, log in again. Otherwise check the server log.');
                                        }
                                        try {
                                            return JSON.parse(text);
                                        } catch (parseErr) {
                                            console.error('Book appointment raw response:', text);
                                            throw new Error('Server did not return valid JSON (HTTP ' + r.status + '). See console or server log.');
                                        }
                                    });
                                })
                                .then(function(data) {
                                    if (data.success) {
                                        hideModal();
                                        var msg = data.message || 'Appointment booked successfully.';
                                        var toastEl = document.getElementById('bookSuccessToast');
                                        var msgEl = document.getElementById('bookSuccessToastMessage');
                                        if (toastEl && msgEl) {
                                            msgEl.textContent = msg;
                                            toastEl.style.display = 'flex';
                                            setTimeout(function() {
                                                toastEl.style.display = 'none';
                                                window.location.reload();
                                            }, 1200);
                                        } else if (typeof window.showToast === 'function') {
                                            window.showToast(msg);
                                            setTimeout(function() { window.location.reload(); }, 1200);
                                        } else {
                                            alert(msg);
                                            window.location.reload();
                                        }
                                    } else {
                                        alert(data.message || 'Booking failed.');
                                    }
                                })
                                .catch(function(err) {
                                    alert(err && err.message ? err.message : 'An error occurred. Please try again.');
                                });
                        });
                    }
                                    
                                    window.openBookAppointmentModal = showModal;
                                })();
                            </script>
