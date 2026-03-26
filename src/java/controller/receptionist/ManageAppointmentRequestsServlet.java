package controller.receptionist;

import dao.AppointmentDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import model.Appointment;
import model.User;

@WebServlet("/Receptionist/ManageAppointmentRequests")
public class ManageAppointmentRequestsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // This screen is a receptionist tool for handling customer requests (currently: reschedule requests).
        //
        // High-level flow:
        // - Read filters (requestType/keyword/customerName/date range)
        // - Load appointments and merge duplicate rows (appointments can join multiple services)
        // - Filter to only "Reschedule-Requested" status within the selected date range
        // - Attach the request payload/details for each appointment (DAO reads latest notification/message)
        // - Forward to JSP for rendering + action buttons
        AppointmentDAO dao = new AppointmentDAO();
        String requestType = request.getParameter("requestType");
        String keyword = request.getParameter("keyword");
        String customerName = request.getParameter("customerName");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        String appointmentIdParam = request.getParameter("appointmentId");
        Integer selectedAppointmentId = null;
        try {
            if (appointmentIdParam != null && !appointmentIdParam.isBlank()) {
                selectedAppointmentId = Integer.parseInt(appointmentIdParam);
            }
        } catch (Exception ignore) {
            selectedAppointmentId = null;
        }

        DateTimeFormatter paramFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        LocalDate fromDate = null;
        LocalDate toDate = null;

        try {
            if (fromDateParam != null && !fromDateParam.isEmpty()) {
                fromDate = LocalDate.parse(fromDateParam, paramFormatter);
            }
            if (toDateParam != null && !toDateParam.isEmpty()) {
                toDate = LocalDate.parse(toDateParam, paramFormatter);
            }
        } catch (Exception e) {
            fromDate = null;
            toDate = null;
        }

        // Default date range behavior mirrors ViewListAppointment:
        // If user does not provide any range, use today -> today + 6 days.
        // If only one bound is provided, infer the other as +/- 1 week.
        if (fromDate == null && toDate == null) {
            fromDate = today;
            toDate = today.plusDays(6);
        }

        if (fromDate == null && toDate != null) {
            fromDate = toDate.minusWeeks(1);
        } else if (fromDate != null && toDate == null) {
            toDate = fromDate.plusWeeks(1);
        }

        final LocalDate rangeStart = fromDate;
        final LocalDate rangeEnd = toDate;

        // Merge by appointmentId so multi-service appointments do not appear as multiple rows.
        List<Appointment> allAppointments = mergeAppointmentsById(dao.getAllAppointments());
        List<Appointment> requestAppointments = allAppointments.stream()
                .filter(a -> a.getAppointmentTime() != null)
                .filter(a -> {
                    LocalDate d = a.getAppointmentTime().toLocalDate();
                    if (rangeStart != null && d.isBefore(rangeStart)) return false;
                    if (rangeEnd != null && d.isAfter(rangeEnd)) return false;
                    return true;
                })
                .filter(a -> a.getStatus() != null
                        && "Reschedule-Requested".equalsIgnoreCase(a.getStatus()))
                .collect(Collectors.toList());

        int rescheduleCount = (int) requestAppointments.stream()
                .filter(a -> "Reschedule-Requested".equalsIgnoreCase(a.getStatus()))
                .count();

        List<Appointment> filteredRequests = requestAppointments;
        if (requestType != null && !requestType.isBlank() && !"All".equalsIgnoreCase(requestType)) {
            if ("Reschedule".equalsIgnoreCase(requestType)) {
                filteredRequests = requestAppointments.stream()
                        .filter(a -> "Reschedule-Requested".equalsIgnoreCase(a.getStatus()))
                        .collect(Collectors.toList());
            }
        }

        if (keyword != null && !keyword.isBlank()) {
            String kw = keyword.trim().toLowerCase();
            filteredRequests = filteredRequests.stream()
                    .filter(a -> String.valueOf(a.getAppointmentId()).contains(kw)
                    || (a.getPet() != null && a.getPet().getName() != null && a.getPet().getName().toLowerCase().contains(kw))
                    || (a.getCustomer() != null && a.getCustomer().getUser() != null
                    && a.getCustomer().getUser().getFullName() != null
                    && a.getCustomer().getUser().getFullName().toLowerCase().contains(kw))
                    || (a.getVeterinarianName() != null && a.getVeterinarianName().toLowerCase().contains(kw))
                    || (a.getStatus() != null && a.getStatus().toLowerCase().contains(kw)))
                    .collect(Collectors.toList());
        }

        if (customerName != null && !customerName.isBlank()) {
            String customerKeyword = customerName.trim().toLowerCase();
            filteredRequests = filteredRequests.stream()
                .filter(a -> a.getCustomer() != null && a.getCustomer().getUser() != null
                && a.getCustomer().getUser().getFullName() != null
                && a.getCustomer().getUser().getFullName().toLowerCase().contains(customerKeyword))
                .collect(Collectors.toList());
        }

        if (selectedAppointmentId != null) {
            final int targetId = selectedAppointmentId;
            boolean containsTarget = filteredRequests.stream().anyMatch(a -> a.getAppointmentId() == targetId);
            if (!containsTarget) {
                java.util.Optional<Appointment> target = requestAppointments.stream()
                        .filter(a -> a.getAppointmentId() == targetId)
                        .findFirst();
                if (target.isPresent()) {
                    filteredRequests.add(0, target.get());
                }
            }
        }

        filteredRequests.sort(java.util.Comparator.comparing(Appointment::getAppointmentTime));

        String fromDateValue = fromDate != null ? fromDate.format(paramFormatter) : "";
        String toDateValue = toDate != null ? toDate.format(paramFormatter) : "";

        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("MMMM dd, yyyy");
        String displayDateRange;
        if (fromDate != null && toDate != null) {
            if (fromDate.equals(toDate)) {
                displayDateRange = fromDate.format(displayFormatter);
            } else {
                displayDateRange = fromDate.format(displayFormatter) + " - " + toDate.format(displayFormatter);
            }
        } else {
            displayDateRange = "All time";
        }

        // Notifications for header dropdown.
        NotificationDAO ndao = new NotificationDAO();
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object currentUserObj = session.getAttribute("currentUser");
            if (currentUserObj instanceof User) {
                User currentUser = (User) currentUserObj;
                request.setAttribute("notifications", ndao.getRecentForUser(currentUser.getUserId(), 10));
                request.setAttribute("notificationTimeFmt", DateTimeFormatter.ofPattern("MMM dd, HH:mm"));
            }
        }

        request.setAttribute("requestType", requestType != null ? requestType : "All");
        request.setAttribute("fromDate", fromDateValue);
        request.setAttribute("toDate", toDateValue);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        request.setAttribute("customerName", customerName != null ? customerName.trim() : "");
        request.setAttribute("displayDateRange", displayDateRange);
        
        // Attach request payload/details for each appointment (used to render "requested date/slot/reason").
        java.util.Map<Integer, java.util.Map<String, String>> appointmentDetails = new java.util.HashMap<>();
        for (Appointment appt : filteredRequests) {
            java.util.Map<String, String> details;
            if ("Reschedule-Requested".equalsIgnoreCase(appt.getStatus())) {
                details = dao.getRescheduleRequestDetails(appt.getAppointmentId());
            } else {
                details = new java.util.HashMap<>();
            }
            appointmentDetails.put(appt.getAppointmentId(), details);
        }
        
        request.setAttribute("requestList", filteredRequests);
        request.setAttribute("appointmentDetails", appointmentDetails);
        request.setAttribute("veterinarians", dao.getAllVeterinarians());
        request.setAttribute("totalRequestCount", requestAppointments.size());
        request.setAttribute("rescheduleCount", rescheduleCount);
        request.setAttribute("selectedAppointmentId", selectedAppointmentId);

        request.getRequestDispatcher("/WEB-INF/views/Receptionist/ManageAppointmentRequests.jsp")
                .forward(request, response);
    }

    private List<Appointment> mergeAppointmentsById(List<Appointment> appointments) {
        if (appointments == null || appointments.isEmpty()) {
            return appointments == null ? new ArrayList<>() : appointments;
        }

        Map<Integer, Appointment> merged = new LinkedHashMap<>();
        for (Appointment appt : appointments) {
            if (appt == null) {
                continue;
            }

            int appointmentId = appt.getAppointmentId();
            Appointment existing = merged.get(appointmentId);
            if (existing == null) {
                merged.put(appointmentId, appt);
                continue;
            }

            String combinedService = mergeServiceNames(existing.getService(), appt.getService());
            existing.setService(combinedService);
        }

        return new ArrayList<>(merged.values());
    }

    private String mergeServiceNames(String left, String right) {
        String first = normalizeText(left);
        String second = normalizeText(right);

        if (first.isEmpty()) {
            return second;
        }
        if (second.isEmpty()) {
            return first;
        }

        for (String part : first.split(",")) {
            if (second.equalsIgnoreCase(part.trim())) {
                return first;
            }
        }

        return first + ", " + second;
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }
}
