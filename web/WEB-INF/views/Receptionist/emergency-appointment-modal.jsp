<%--
  Emergency Appointment modal for receptionist (Dashboard & ViewListAppointment).
  Fields: Phone Number, Owner Name (locked on lookup), Pet (dropdown incl. new pet), Pet Type (locked on existing pet).
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
                    <label for="em_phone" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Phone Number *</label>
                    <input type="tel" id="em_phone" name="phone" placeholder="0123456789 (10 digits, start with 0)" pattern="0[0-9]{9}" maxlength="10" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    <p id="em_phoneStatus" class="text-xs mt-1 text-slate-500 hidden"></p>
                </div>
                <div>
                    <label for="em_ownerName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Owner Name *</label>
                    <input type="text" id="em_ownerName" name="ownerName" placeholder="Enter full name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                </div>
                <div>
                    <label for="em_email" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Email Address *</label>
                    <input type="email" id="em_email" name="email" placeholder="your@email.com" autocomplete="email" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20"/>
                </div>
                <div id="em_petNameWrapper">
                    <label for="em_petSelect" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet *</label>
                    <select id="em_petSelect" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
                        <option value="__new__">Add a new pet</option>
                    </select>
                    <div id="em_newPetFields" class="mt-3">
                        <label for="em_petName" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Name *</label>
                        <input type="text" id="em_petName" name="petName" placeholder="Your pet's name" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required/>
                    </div>
                    <input type="hidden" id="em_petId" name="petId" value=""/>
                </div>
                <div>
                    <label for="em_petType" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Pet Type *</label>
                    <select id="em_petType" name="petType" class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20" required>
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
    var emailInput = document.getElementById('em_email');
    var customerFoundByPhone = false;
    var petSelect = document.getElementById('em_petSelect');
    var newPetFields = document.getElementById('em_newPetFields');
    var petNameInput = document.getElementById('em_petName');
    var bookPetId = document.getElementById('em_petId');
    var petTypeSelect = document.getElementById('em_petType');
    var phoneStatus = document.getElementById('em_phoneStatus');
    var form = document.getElementById('emergencyAppointmentForm');
    var NEW_PET_VALUE = '__new__';

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
        refreshEmailRequirement();
    }

    function setOwnerNameLocked(locked, fullName) {
        if (!ownerInput) return;
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

    function setCustomerEmailLocked(locked, email) {
        if (!emailInput) return;
        if (locked) {
            emailInput.value = email || '';
            emailInput.readOnly = true;
            emailInput.required = true;
            emailInput.classList.remove('bg-slate-50', 'dark:bg-slate-800');
            emailInput.classList.add('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
        } else {
            emailInput.value = (email !== undefined && email !== null) ? email : '';
            emailInput.readOnly = false;
            emailInput.required = true;
            emailInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
            emailInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
        }
    }

    function refreshEmailRequirement() {
        if (!emailInput || !petSelect) return;
        var isNewPet = !petSelect.value || petSelect.value === NEW_PET_VALUE;
        emailInput.required = isNewPet;
    }

    if (petSelect) {
        petSelect.addEventListener('change', function() {
            setPetUIFromSelection();
            refreshEmailRequirement();
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
            customerFoundByPhone = false;
            setOwnerNameLocked(false);
            if (emailInput) {
                emailInput.value = '';
            }
            setCustomerEmailLocked(false, '');
            renderPetSelectOptions([]);
            refreshEmailRequirement();
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
                            customerFoundByPhone = true;
                            phoneStatus.textContent = 'Customer found. Select pet below.';
                            phoneStatus.className = 'text-xs mt-1 text-green-600 dark:text-green-400';
                            setOwnerNameLocked(true, data.customer.fullName || '');
                            setCustomerEmailLocked(true, data.customer.email || '');
                            renderPetSelectOptions(data.pets || []);
                        } else {
                            customerFoundByPhone = false;
                            phoneStatus.textContent = 'New customer. Enter pet details.';
                            phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                            setOwnerNameLocked(false);
                            if (emailInput) emailInput.value = '';
                            setCustomerEmailLocked(false, '');
                            renderPetSelectOptions([]);
                        }
                        refreshEmailRequirement();
                    }
                })
                .catch(function() {
                    if (phoneStatus) {
                        phoneStatus.classList.remove('hidden');
                        phoneStatus.textContent = 'Could not lookup. Enter details manually.';
                        phoneStatus.className = 'text-xs mt-1 text-slate-500 dark:text-slate-400';
                    }
                    customerFoundByPhone = false;
                    setOwnerNameLocked(false);
                    if (emailInput) emailInput.value = '';
                    setCustomerEmailLocked(false, '');
                    renderPetSelectOptions([]);
                    refreshEmailRequirement();
                });
        }, 400);
    }

    if (phoneInput) {
        phoneInput.addEventListener('blur', onPhoneChange);
        phoneInput.addEventListener('input', onPhoneChange);
    }

    function showModal() {
        if (modal) {
            customerFoundByPhone = false;
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            document.body.style.overflow = 'hidden';

            // Reset state when opening modal
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
                emailInput.value = '';
                emailInput.readOnly = false;
                emailInput.required = true;
                emailInput.classList.remove('bg-slate-100', 'dark:bg-slate-700', 'cursor-not-allowed');
                emailInput.classList.add('bg-slate-50', 'dark:bg-slate-800');
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
            refreshEmailRequirement();
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
            if (petSelect && bookPetIdEl) {
                bookPetIdEl.value = (petSelect.value && petSelect.value !== NEW_PET_VALUE)
                    ? petSelect.value
                    : '';
            }
            var isNewPet = !petSelect || !petSelect.value || petSelect.value === NEW_PET_VALUE;
            if (isNewPet && !customerFoundByPhone) {
                var em = emailInput && emailInput.value ? emailInput.value.trim() : '';
                if (!em) {
                    alert('Please enter a valid email for the new customer.');
                    return;
                }
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
