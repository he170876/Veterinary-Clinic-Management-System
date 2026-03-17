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
                        <label for="book_ownerName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Owner Name *</label>
                        <input type="text" id="book_ownerName" name="ownerName" placeholder="Enter full name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                    <div>
                        <label for="book_email" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Email Address *</label>
                        <input type="email" id="book_email" name="email" placeholder="your@email.com" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="book_phone" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Phone Number *</label>
                        <input type="tel" id="book_phone" name="phone" placeholder="0123456789 (10 digits, start with 0)" pattern="0[0-9]{9}" maxlength="10" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                        <p id="book_phoneStatus" class="text-xs mt-1 text-slate-500 hidden"></p>
                    </div>
                    <div>
                        <label for="book_serviceId" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Select Service *</label>
                        <select id="book_serviceId" name="serviceId" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
                            <option value="">Choose a service</option>
                            <c:if test="${not empty services}">
                                <c:forEach var="sv" items="${services}">
                                    <option value="${sv.serviceId}">${sv.name}</option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div id="book_petNameWrapper">
                        <label for="book_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>
                        <input type="text" id="book_petName" name="petName" placeholder="Your pet's name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                        <input type="hidden" id="book_petId" name="petId" value=""/>
                    </div>
                    <div>
                        <label for="book_petType" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Type *</label>
                        <select id="book_petType" name="petType" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20">
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
                            <option value="AM">AM</option>
                            <option value="PM">PM</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label for="book_notes" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Additional Notes</label>
                    <textarea id="book_notes" name="notes" rows="4" placeholder="How can we help your pet today?" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20 resize-none min-h-[100px] max-h-[100px]"></textarea>
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
    var petNameInput = document.getElementById('book_petName');
    var bookPetId = document.getElementById('book_petId');
    var petTypeSelect = document.getElementById('book_petType');
    var phoneStatus = document.getElementById('book_phoneStatus');
    var form = document.getElementById('receptionistBookForm');

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
        var amOpt = slotEl.querySelector('option[value="AM"]');
        var pmOpt = slotEl.querySelector('option[value="PM"]');
        if (amOpt) amOpt.disabled = false;
        if (pmOpt) pmOpt.disabled = false;
        if (isToday(selectedDate) && hour >= 12) {
            if (amOpt) {
                amOpt.disabled = true;
                if (slotEl.value === 'AM') slotEl.value = 'PM';
            }
        }
    }
    function showModal() {
        if (modal) {
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            document.body.style.overflow = 'hidden';
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

    var petTypeValues = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
    function matchPetType(dbSpecies) {
        var v = (dbSpecies || '').trim().toLowerCase();
        if (!v) return '';
        for (var i = 0; i < petTypeValues.length; i++) {
            if (petTypeValues[i].toLowerCase() === v) return petTypeValues[i];
        }
        return 'Other';
    }
    function setPetTypeFromPet(disabled, value) {
        var pt = document.getElementById('book_petType');
        if (!pt) return;
        if (disabled) {
            var v = matchPetType(value);
            pt.value = v || '';
            pt.disabled = true;
            pt.classList.add('bg-slate-100', 'dark:bg-slate-700');
        } else {
            pt.value = '';
            pt.disabled = false;
            pt.classList.remove('bg-slate-100', 'dark:bg-slate-700');
        }
    }
    function switchToPetDropdown(pets) {
        setPetTypeFromPet(false, '');
        var html = '<label for="book_petSelect" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>';
        html += '<select id="book_petSelect" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>';
        html += '<option value="" data-species="">Choose a pet</option>';
        for (var i = 0; i < pets.length; i++) {
            var species = (pets[i].species != null && pets[i].species !== undefined) ? String(pets[i].species) : '';
            html += '<option value="' + pets[i].petId + '" data-species="' + species.replace(/"/g, '&quot;') + '">' + (pets[i].name || '') + '</option>';
        }
        html += '</select>';
        petNameWrapper.innerHTML = html;
        petNameWrapper.appendChild(bookPetId);
        bookPetId.name = 'petId';
        bookPetId.value = '';
        var sel = document.getElementById('book_petSelect');
        if (sel) {
            sel.addEventListener('change', function() {
                bookPetId.value = this.value;
                var opt = this.options[this.selectedIndex];
                var species = opt ? (opt.getAttribute('data-species') || '') : '';
                setPetTypeFromPet(!!this.value, species);
            });
        }
    }

    function switchToPetTextInput() {
        setPetTypeFromPet(false, '');
        var html = '<label for="book_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>';
        html += '<input type="text" id="book_petName" name="petName" placeholder="Your pet\'s name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>';
        petNameWrapper.innerHTML = html;
        petNameWrapper.appendChild(bookPetId);
        bookPetId.value = '';
        bookPetId.name = 'petId';
    }

    var lookupTimeout;
    function onPhoneChange() {
        var phone = (phoneInput && phoneInput.value) ? phoneInput.value.trim() : '';
        if (phoneStatus) {
            phoneStatus.classList.add('hidden');
            phoneStatus.textContent = '';
        }
        if (phone.length < 10) {
            switchToPetTextInput();
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
                            if (ownerInput) ownerInput.value = data.customer.fullName || '';
                            if (emailInput) emailInput.value = data.customer.email || '';
                            if (data.pets && data.pets.length > 0) {
                                switchToPetDropdown(data.pets);
                            } else {
                                switchToPetTextInput();
                            }
                        } else {
                            phoneStatus.textContent = 'New customer. Enter pet details.';
                            phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                            switchToPetTextInput();
                        }
                    }
                })
                .catch(function() {
                    if (phoneStatus) {
                        phoneStatus.classList.remove('hidden');
                        phoneStatus.textContent = 'Could not lookup. Enter details manually.';
                        phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                    }
                    switchToPetTextInput();
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
            var bookPetIdEl = document.getElementById('book_petId');
            var petSelect = document.getElementById('book_petSelect');
            var petNameEl = document.getElementById('book_petName');
            if (petSelect && petSelect.value && bookPetIdEl) {
                bookPetIdEl.value = petSelect.value;
            } else if (petNameEl && bookPetIdEl) {
                bookPetIdEl.value = '';
            }
            var fd = new FormData(form);
            fetch(ctx + '/Receptionist/BookAppointment', {
                method: 'POST',
                body: new URLSearchParams(fd)
            })
            .then(function(r) { return r.json(); })
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
            .catch(function() {
                alert('An error occurred. Please try again.');
            });
        });
    }

    window.openBookAppointmentModal = showModal;
})();
</script>
