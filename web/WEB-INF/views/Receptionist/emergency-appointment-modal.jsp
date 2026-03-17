<%--
  Emergency Appointment modal for receptionist (Dashboard & ViewListAppointment).
  Fields: Owner Name, Phone Number, Pet Name (input or dropdown from lookup), Pet Type.
  Same phone lookup as Book Appointment. Creates type=Emergency, status=Checked-In, service_id=null, today's date, time_slot from current time.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<div id="emergencyAppointmentModal" class="fixed inset-0 z-[100] hidden items-center justify-center p-4" aria-modal="true">
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" data-close-modal="emergencyAppointmentModal"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
        <div class="sticky top-0 bg-white dark:bg-slate-900 px-6 py-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between z-10">
            <h2 class="text-xl font-bold text-slate-800 dark:text-white flex items-center gap-2">
                <span class="material-symbols-outlined text-red-500">emergency</span>
                Emergency Appointment
            </h2>
            <button type="button" class="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors close-emergency-modal" aria-label="Close">
                <span class="material-symbols-outlined text-2xl">close</span>
            </button>
        </div>
        <div class="p-6">
            <form id="emergencyAppointmentForm" class="space-y-4">
                <div>
                    <label for="em_ownerName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Owner Name *</label>
                    <input type="text" id="em_ownerName" name="ownerName" placeholder="Enter full name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                </div>
                <div>
                    <label for="em_phone" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Phone Number *</label>
                    <input type="tel" id="em_phone" name="phone" placeholder="0123456789 (10 digits, start with 0)" pattern="0[0-9]{9}" maxlength="10" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    <p id="em_phoneStatus" class="text-xs mt-1 text-slate-500 hidden"></p>
                </div>
                <div id="em_petNameWrapper">
                    <label for="em_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>
                    <input type="text" id="em_petName" name="petName" placeholder="Your pet's name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    <input type="hidden" id="em_petId" name="petId" value=""/>
                </div>
                <div>
                    <label for="em_petType" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Type *</label>
                    <select id="em_petType" name="petType" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20">
                        <option value="">Select pet type</option>
                        <option value="Dog">Dog</option>
                        <option value="Cat">Cat</option>
                        <option value="Bird">Bird</option>
                        <option value="Rabbit">Rabbit</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <button type="submit" class="w-full py-3 rounded-xl bg-red-500 text-white font-semibold hover:opacity-90 transition-opacity flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined">emergency</span>
                    Create Emergency Appointment
                </button>
            </form>
        </div>
    </div>
</div>
<div id="emergencySuccessToast" class="fixed top-6 right-6 bg-green-500 text-white px-6 py-3 rounded-xl shadow-lg flex items-center gap-2 z-[2000]" style="display: none;">
    <span class="material-symbols-outlined">check_circle</span>
    <span id="emergencySuccessToastMessage">Emergency appointment created.</span>
</div>

<script>
(function() {
    var ctx = '${ctx}';
    var modal = document.getElementById('emergencyAppointmentModal');
    var phoneInput = document.getElementById('em_phone');
    var ownerInput = document.getElementById('em_ownerName');
    var petNameWrapper = document.getElementById('em_petNameWrapper');
    var bookPetId = document.getElementById('em_petId');
    var petTypeSelect = document.getElementById('em_petType');
    var phoneStatus = document.getElementById('em_phoneStatus');
    var form = document.getElementById('emergencyAppointmentForm');

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
        var pt = document.getElementById('em_petType');
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
        var html = '<label for="em_petSelect" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>';
        html += '<select id="em_petSelect" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>';
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
        var sel = document.getElementById('em_petSelect');
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
        var html = '<label for="em_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>';
        html += '<input type="text" id="em_petName" name="petName" placeholder="Your pet\'s name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>';
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

    function showModal() {
        if (modal) {
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            document.body.style.overflow = 'hidden';
        }
    }
    function hideModal() {
        if (modal) {
            modal.classList.add('hidden');
            modal.classList.remove('flex');
            document.body.style.overflow = '';
        }
    }

    modal.querySelectorAll('.close-emergency-modal, [data-close-modal="emergencyAppointmentModal"]').forEach(function(btn) {
        btn.addEventListener('click', hideModal);
    });

    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var bookPetIdEl = document.getElementById('em_petId');
            var petSelect = document.getElementById('em_petSelect');
            var petNameEl = document.getElementById('em_petName');
            if (petSelect && petSelect.value && bookPetIdEl) {
                bookPetIdEl.value = petSelect.value;
            } else if (petNameEl && bookPetIdEl) {
                bookPetIdEl.value = '';
            }
            var fd = new FormData(form);
            fetch(ctx + '/Receptionist/EmergencyAppointment', {
                method: 'POST',
                body: new URLSearchParams(fd)
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    hideModal();
                    var msg = data.message || 'Emergency appointment created.';
                    var toastEl = document.getElementById('emergencySuccessToast');
                    var msgEl = document.getElementById('emergencySuccessToastMessage');
                    if (toastEl && msgEl) {
                        msgEl.textContent = msg;
                        toastEl.style.display = 'flex';
                        setTimeout(function() {
                            toastEl.style.display = 'none';
                            window.location.reload();
                        }, 1200);
                    } else {
                        alert(msg);
                        window.location.reload();
                    }
                } else {
                    alert(data.message || 'Could not create emergency appointment.');
                }
            })
            .catch(function() {
                alert('An error occurred. Please try again.');
            });
        });
    }

    window.openEmergencyAppointmentModal = showModal;
})();
</script>
