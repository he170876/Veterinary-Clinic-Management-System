<%-- Reschedule: new date (>= today) + AM/PM with same slot rules as book appointment. --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<div id="rescheduleAppointmentModal" class="fixed inset-0 z-[90] hidden items-center justify-center p-4" aria-modal="true" aria-labelledby="rescheduleModalTitle">
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" data-close-reschedule-modal></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-md w-full border border-slate-200 dark:border-slate-800">
        <div class="flex items-center justify-between px-6 py-4 border-b border-slate-200 dark:border-slate-800">
            <h2 id="rescheduleModalTitle" class="text-xl font-bold text-slate-800 dark:text-white">Reschedule appointment</h2>
            <button type="button" class="p-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors close-reschedule-modal" aria-label="Close">
                <span class="material-symbols-outlined text-2xl text-slate-600 dark:text-slate-300">close</span>
            </button>
        </div>
        <form id="rescheduleAppointmentForm" class="p-6 space-y-4">
            <input type="hidden" id="reschedule_appointmentId" name="appointmentId" value=""/>
            <div>
                <label for="reschedule_date" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">New date *</label>
                <input type="date" id="reschedule_date" name="newDate" required
                       class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20"/>
                <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Must be today or a later date.</p>
            </div>
            <div>
                <label for="reschedule_timeSlot" class="block text-sm font-semibold text-slate-700 dark:text-slate-300 mb-1">Time slot *</label>
                <select id="reschedule_timeSlot" name="timeSlot" required
                        class="w-full px-3 py-2 border border-slate-200 dark:border-slate-700 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-primary/20">
                    <option value="">--:--</option>
                    <option value="AM">in the Morning</option>
                    <option value="PM">in the Afternoon</option>
                </select>
                <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Morning slot closes after 12:00, afternoon after 8:00 PM</p>
            </div>
            <div class="flex gap-3 justify-end pt-2">
                <button type="button" class="close-reschedule-modal px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-300 font-medium hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
                    Cancel
                </button>
                <button type="submit" id="reschedule_submitBtn" class="px-4 py-2 rounded-xl bg-primary text-white font-semibold hover:opacity-90 transition-opacity shadow shadow-primary/20">
                    Confirm reschedule
                </button>
            </div>
        </form>
    </div>
</div>
<script>
(function() {
    var ctx = '${ctx}';
    var modal = document.getElementById('rescheduleAppointmentModal');
    var form = document.getElementById('rescheduleAppointmentForm');
    var idInput = document.getElementById('reschedule_appointmentId');
    var dateEl = document.getElementById('reschedule_date');
    var slotEl = document.getElementById('reschedule_timeSlot');
    var submitBtn = document.getElementById('reschedule_submitBtn');

    /**
     * ==============================
     * Receptionist Reschedule Modal
     * ==============================
     *
     * UI rules (same-day only):
     * - AM disabled after 12:00
     * - PM disabled after 20:00
     *
     * Submit:
     * - POST /Receptionist/RescheduleAppointment
     * - Body: appointmentId, newDate (yyyy-MM-dd), timeSlot (AM/PM)
     * - Response: JSON { success, message }
     *
     * Server-side side effects:
     * - Updates appointment_date/time_slot (and appointment_time in legacy schema)
     * - Sends customer notification with title "Reschedule Confirmed"
     */

    function getTodayLocal() {
        var d = new Date();
        return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
    }
    function isToday(dateStr) {
        return dateStr && dateStr === getTodayLocal();
    }
    function updateRescheduleTimeSlotOptions() {
        if (!dateEl || !slotEl) return;
        var selectedDate = dateEl.value;
        var now = new Date();
        var hour = now.getHours();
        var minutes = now.getMinutes();
        var NOON_HOUR_24 = 12;
        var EVENING_CUTOFF_HOUR_12 = 8;
        var EVENING_CUTOFF_HOUR_24 = 12 + EVENING_CUTOFF_HOUR_12;
        var currentTotalMinutes = hour * 60 + minutes;
        var noonTotalMinutes = NOON_HOUR_24 * 60;
        var cutoffTotalMinutes = EVENING_CUTOFF_HOUR_24 * 60;
        var amOpt = slotEl.querySelector('option[value="AM"]');
        var pmOpt = slotEl.querySelector('option[value="PM"]');
        if (amOpt) amOpt.disabled = false;
        if (pmOpt) pmOpt.disabled = false;

        if (isToday(selectedDate)) {
            if (amOpt) {
                amOpt.disabled = currentTotalMinutes > noonTotalMinutes;
            }
            if (pmOpt) {
                pmOpt.disabled = currentTotalMinutes > cutoffTotalMinutes;
            }
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

    function showRescheduleModal(appointmentId) {
        if (!modal || !idInput || !dateEl || !slotEl) return;
        idInput.value = appointmentId || '';
        var today = getTodayLocal();
        dateEl.setAttribute('min', today);
        dateEl.value = today;
        slotEl.value = '';
        updateRescheduleTimeSlotOptions();
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        document.body.style.overflow = 'hidden';
    }

    function hideRescheduleModal() {
        if (!modal) return;
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        document.body.style.overflow = '';
        if (idInput) idInput.value = '';
        if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Confirm reschedule';
        }
    }

    window.rescheduleAppointment = showRescheduleModal;

    if (dateEl) {
        dateEl.addEventListener('change', function() {
            var today = getTodayLocal();
            if (this.value && this.value < today) this.value = today;
            updateRescheduleTimeSlotOptions();
        });
        dateEl.addEventListener('input', function() {
            var today = getTodayLocal();
            if (this.value && this.value < today) this.value = today;
            updateRescheduleTimeSlotOptions();
        });
    }
    if (modal) {
        modal.querySelectorAll('.close-reschedule-modal, [data-close-reschedule-modal]').forEach(function(btn) {
            btn.addEventListener('click', hideRescheduleModal);
        });
    }

    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            var aid = idInput ? idInput.value : '';
            var nd = dateEl ? dateEl.value : '';
            var ts = slotEl ? slotEl.value : '';
            if (!aid || !nd || !ts) {
                alert('Please choose a date and time slot.');
                return;
            }
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Saving...';
            }
            var body = 'appointmentId=' + encodeURIComponent(aid)
                + '&newDate=' + encodeURIComponent(nd)
                + '&timeSlot=' + encodeURIComponent(ts);
            fetch(ctx + '/Receptionist/RescheduleAppointment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    hideRescheduleModal();
                    var msg = data.message || 'Appointment rescheduled successfully.';
                    if (typeof showToast === 'function') {
                        showToast(msg);
                        setTimeout(function() { window.location.reload(); }, 1500);
                    } else {
                        alert(msg);
                        window.location.reload();
                    }
                } else {
                    alert(data.message || 'Could not reschedule.');
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.textContent = 'Confirm reschedule';
                    }
                }
            })
            .catch(function() {
                alert('An error occurred. Please try again.');
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Confirm reschedule';
                }
            });
        });
    }
})();
</script>
