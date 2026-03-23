package controller.customer;

import dao.AppointmentDAO;
import dao.CustomerDAO;
import dao.PetDAO;
import dao.impl.CustomerJdbcDAO;
import dao.impl.PetJdbcDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import model.Customer;
import model.Pet;
import model.User;
import model.Service;
import service.ServiceService;
import service.impl.ServiceServiceImpl;
import utils.ValidationUtil;

/**
 * Logged-in customer booking flow that creates a pending appointment for an existing pet.
 */
@WebServlet(name = "CustomerBookAppointmentServlet", urlPatterns = {"/customer/appointments/book"})
public class CustomerBookAppointmentServlet extends HttpServlet {

    private transient CustomerDAO customerDAO;
    private transient PetDAO petDAO;
    private transient AppointmentDAO appointmentDAO;
    private transient ServiceService serviceService;

    @Override
    public void init() throws ServletException {
        customerDAO = new CustomerJdbcDAO();
        petDAO = new PetJdbcDAO();
        appointmentDAO = new AppointmentDAO();
        serviceService = new ServiceServiceImpl();
    }

    private List<Service> getGeneralServices() {
        List<Service> list = serviceService.getServicesByCategory("general");
        return list != null ? list : java.util.Collections.emptyList();
    }

    private Optional<Customer> resolveCurrentCustomer(User user) {
        if (user == null) {
            return Optional.empty();
        }

        Optional<Customer> customerOpt = customerDAO.findByUserId(user.getUserId());
        if (customerOpt.isPresent()) {
            return customerOpt;
        }

        try {
            Customer customer = new Customer();
            customer.setUser(user);
            customerDAO.create(customer);
            return customerDAO.findByUserId(user.getUserId());
        } catch (Exception ex) {
            return Optional.empty();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        Optional<Customer> customerOpt = resolveCurrentCustomer(user);
        if (!customerOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=customer_not_found");
            return;
        }

        forwardForm(request, response, user, customerOpt.get());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        Optional<Customer> customerOpt = resolveCurrentCustomer(user);
        if (!customerOpt.isPresent()) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=customer_not_found");
            return;
        }

        Customer customer = customerOpt.get();
        String petIdParam = ValidationUtil.trim(request.getParameter("petId"));
        String[] serviceIdParams = request.getParameterValues("serviceIds");
        String selectedServiceIdsCsv = serviceIdParams != null ? String.join(",", serviceIdParams) : null;
        String appointmentDate = ValidationUtil.trim(request.getParameter("appointmentDate"));
        String timeSlot = ValidationUtil.trim(request.getParameter("timeSlot"));
        String notes = ValidationUtil.trim(request.getParameter("notes"));

        List<Pet> customerPets = petDAO.findByCustomerId(customer.getCustomerId());
        List<Service> services = getGeneralServices();

        if (notes != null && notes.length() > ValidationUtil.NOTES_MAX_LENGTH) {
            forwardForm(request, response, user, customer,
                    "Notes must be at most " + ValidationUtil.NOTES_MAX_LENGTH + " characters.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (petIdParam == null || appointmentDate == null || timeSlot == null
                || serviceIdParams == null || serviceIdParams.length == 0) {
            forwardForm(request, response, user, customer,
                    "Please select a pet, at least one service, date, and time slot.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (customerPets.isEmpty()) {
            forwardForm(request, response, user, customer,
                    "Please add a pet to your account before booking an appointment.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        int petId;
        List<Integer> serviceIds = new ArrayList<>();
        try {
            petId = Integer.parseInt(petIdParam);
            Set<Integer> uniqueServiceIds = new LinkedHashSet<>();
            for (String rawServiceId : serviceIdParams) {
                if (rawServiceId == null || rawServiceId.trim().isEmpty()) {
                    continue;
                }
                int parsed = Integer.parseInt(rawServiceId.trim());
                if (parsed <= 0) {
                    throw new NumberFormatException("Invalid service id");
                }
                uniqueServiceIds.add(parsed);
            }
            serviceIds.addAll(uniqueServiceIds);
            if (serviceIds.isEmpty()) {
                throw new NumberFormatException("No service selected");
            }
        } catch (NumberFormatException ex) {
            forwardForm(request, response, user, customer,
                    "Invalid pet or service selection.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        boolean petOwnedByCustomer = false;
        for (Pet pet : customerPets) {
            if (pet != null && pet.getPetId() == petId) {
                petOwnedByCustomer = true;
                break;
            }
        }
        if (!petOwnedByCustomer) {
            forwardForm(request, response, user, customer,
                    "Please choose one of your own pets.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        int requestedDurationMinutes = 0;
        for (Integer serviceId : serviceIds) {
            Optional<Service> selectedServiceOpt = serviceService.getServiceById(serviceId);
            if (!selectedServiceOpt.isPresent()) {
                forwardForm(request, response, user, customer,
                        "Selected service is not available.",
                        petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                        customerPets, services);
                return;
            }
            Service selectedService = selectedServiceOpt.get();
            String category = selectedService.getCategory() != null
                    ? selectedService.getCategory().trim().toLowerCase()
                    : "";
            if (!"general".equals(category)) {
                forwardForm(request, response, user, customer,
                        "Selected service is not available for customer booking.",
                        petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                        customerPets, services);
                return;
            }
            if (selectedService.getDuration() > 0) {
                requestedDurationMinutes += selectedService.getDuration();
            }
        }
        if (requestedDurationMinutes <= 0) {
            requestedDurationMinutes = 30;
        }

        String normalizedSlot = ValidationUtil.normalizeBookingSlot(timeSlot);
        if (normalizedSlot == null) {
            forwardForm(request, response, user, customer,
                    "Invalid time slot selected.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        LocalDate requestedDate;
        try {
            requestedDate = LocalDate.parse(appointmentDate);
        } catch (DateTimeParseException ex) {
            forwardForm(request, response, user, customer,
                    "Please provide a valid appointment date.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (!ValidationUtil.isBookableDateSlot(requestedDate, normalizedSlot)) {
            forwardForm(request, response, user, customer,
                    "Selected time slot has passed. Please choose a different slot or date.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        // Convert time slot to appointment time (morning=08:00, afternoon=14:00)
        LocalDateTime requestedTime;
        try {
            int hour = "morning".equals(normalizedSlot) ? 8 : 14;
            requestedTime = LocalDateTime.parse(appointmentDate + "T" + String.format("%02d:00", hour));
        } catch (DateTimeParseException ex) {
            forwardForm(request, response, user, customer,
                    "Please provide a valid appointment date.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        int bookingsOnDate = appointmentDAO.countCustomerBookingsOnDate(
                customer.getCustomerId(), requestedTime.toLocalDate());
        if (bookingsOnDate >= AppointmentDAO.MAX_BOOKINGS_PER_DAY) {
            forwardForm(request, response, user, customer,
                    "You can only book up to " + AppointmentDAO.MAX_BOOKINGS_PER_DAY
                    + " appointments per day. Please choose a different date.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (appointmentDAO.hasCustomerAppointmentConflict(customer.getCustomerId(), requestedTime, requestedDurationMinutes)) {
            forwardForm(request, response, user, customer,
                    "You already have another appointment in this time slot. Please choose a different date or slot.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (appointmentDAO.hasPetAppointmentConflict(petId, requestedTime, requestedDurationMinutes)) {
            forwardForm(request, response, user, customer,
                    "This pet already has another appointment in this time slot. Please choose a different date or slot.",
                    petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        // Create appointment with NO veterinarian assigned (veterinarian will be assigned during check-in or examination)
        int appointmentId = appointmentDAO.createCustomerBooking(
                petId,
                customer.getCustomerId(),
                null,  // No veterinarian assigned at booking time
                requestedTime,
            serviceIds.get(0),
                notes
        );

        if (appointmentId <= 0) {
            forwardForm(request, response, user, customer,
                    "Could not create the appointment. Please try again.",
                petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                    customerPets, services);
            return;
        }

        if (!appointmentDAO.insertAppointmentServices(appointmentId, serviceIds)) {
            forwardForm(request, response, user, customer,
                "Appointment was created but selected services could not be linked.",
                petIdParam, selectedServiceIdsCsv, appointmentDate, timeSlot, notes,
                customerPets, services);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=upcoming&booked=1");
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response, User user, Customer customer)
            throws ServletException, IOException {
        forwardForm(request, response, user, customer, null, null, null, null, null, null, null, null);
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response,
            User user, Customer customer, String formError,
            String selectedPetId, String selectedServiceId,
            String appointmentDate, String selectedTimeSlot, String notes,
            List<Pet> customerPets, List<Service> services)
            throws ServletException, IOException {
        request.setAttribute("customerCurrentPage", "appointments");
        request.setAttribute("user", user);
        request.setAttribute("customer", customer);
        request.setAttribute("customerPets", customerPets != null ? customerPets : petDAO.findByCustomerId(customer.getCustomerId()));
        request.setAttribute("services", services != null ? services : getGeneralServices());
        request.setAttribute("veterinarians", appointmentDAO.getAllVeterinarians());
        request.setAttribute("formError", formError);
        request.setAttribute("selectedPetId", selectedPetId);
        request.setAttribute("selectedServiceId", selectedServiceId);
        request.setAttribute("selectedAppointmentDate", appointmentDate);
        request.setAttribute("selectedTimeSlot", selectedTimeSlot);
        request.setAttribute("notesValue", notes);
        request.getRequestDispatcher("/WEB-INF/views/customer/book-appointment.jsp").forward(request, response);
    }
}