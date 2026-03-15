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
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;
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
        String serviceIdParam = ValidationUtil.trim(request.getParameter("serviceId"));
        String preferredDoctorIdParam = ValidationUtil.trim(request.getParameter("preferredDoctorId"));
        String appointmentDate = ValidationUtil.trim(request.getParameter("appointmentDate"));
        String appointmentTime = ValidationUtil.trim(request.getParameter("appointmentTime"));
        String notes = ValidationUtil.trim(request.getParameter("notes"));

        List<Pet> customerPets = petDAO.findByCustomerId(customer.getCustomerId());
        List<User> veterinarians = appointmentDAO.getAllVeterinarians();
        List<Service> services = serviceService.getAllServices();

        if (notes != null && notes.length() > ValidationUtil.NOTES_MAX_LENGTH) {
            forwardForm(request, response, user, customer,
                    "Notes must be at most " + ValidationUtil.NOTES_MAX_LENGTH + " characters.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (petIdParam == null || serviceIdParam == null || appointmentDate == null || appointmentTime == null) {
            forwardForm(request, response, user, customer,
                    "Please select a pet, service, date, and time.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (customerPets.isEmpty()) {
            forwardForm(request, response, user, customer,
                    "Please add a pet to your account before booking an appointment.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        int petId;
        int serviceId;
        Integer preferredDoctorId = null;
        try {
            petId = Integer.parseInt(petIdParam);
            serviceId = Integer.parseInt(serviceIdParam);
        } catch (NumberFormatException ex) {
            forwardForm(request, response, user, customer,
                    "Invalid pet or service selection.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (preferredDoctorIdParam != null) {
            try {
                preferredDoctorId = Integer.valueOf(preferredDoctorIdParam);
                if (preferredDoctorId <= 0) {
                    throw new NumberFormatException("Invalid veterinarian id");
                }
            } catch (NumberFormatException ex) {
                forwardForm(request, response, user, customer,
                        "Selected preferred veterinarian is invalid.",
                        petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                        customerPets, services, veterinarians);
                return;
            }
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
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        Optional<Service> selectedServiceOpt = serviceService.getServiceById(serviceId);
        if (!selectedServiceOpt.isPresent()) {
            forwardForm(request, response, user, customer,
                    "Selected service is not available.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }
        Service selectedService = selectedServiceOpt.get();
        int requestedDurationMinutes = selectedService.getDuration();

        if (preferredDoctorId != null) {
            boolean validDoctor = false;
            for (User veterinarian : veterinarians) {
                if (veterinarian != null && veterinarian.getUserId() == preferredDoctorId.intValue()) {
                    validDoctor = true;
                    break;
                }
            }
            if (!validDoctor) {
                forwardForm(request, response, user, customer,
                        "Selected preferred veterinarian is not available.",
                        petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                        customerPets, services, veterinarians);
                return;
            }
        }

        LocalDateTime requestedTime;
        try {
            requestedTime = LocalDateTime.parse(appointmentDate + "T" + appointmentTime);
        } catch (DateTimeParseException ex) {
            forwardForm(request, response, user, customer,
                    "Please provide a valid appointment date and time.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (requestedTime.isBefore(LocalDateTime.now())) {
            forwardForm(request, response, user, customer,
                    "Appointment time cannot be in the past.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        int bookingsOnDate = appointmentDAO.countCustomerBookingsOnDate(
                customer.getCustomerId(), requestedTime.toLocalDate());
        if (bookingsOnDate >= AppointmentDAO.MAX_BOOKINGS_PER_DAY) {
            forwardForm(request, response, user, customer,
                    "You can only book up to " + AppointmentDAO.MAX_BOOKINGS_PER_DAY
                    + " appointments per day. Please choose a different date.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (appointmentDAO.hasCustomerAppointmentConflict(customer.getCustomerId(), requestedTime, requestedDurationMinutes)) {
            forwardForm(request, response, user, customer,
                    "You already have another appointment that overlaps this time range. Please choose a different slot.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (appointmentDAO.hasPetAppointmentConflict(petId, requestedTime, requestedDurationMinutes)) {
            forwardForm(request, response, user, customer,
                    "This pet already has another appointment that overlaps this time range. Please choose a different slot.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        if (preferredDoctorId != null && appointmentDAO.hasVeterinarianAppointmentConflict(preferredDoctorId, requestedTime, requestedDurationMinutes)) {
            forwardForm(request, response, user, customer,
                    "The selected veterinarian is not available in this time range. Please choose another time or doctor.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        int appointmentId = appointmentDAO.createCustomerBooking(
                petId,
                customer.getCustomerId(),
                preferredDoctorId,
                requestedTime,
                serviceId,
                notes
        );

        if (appointmentId <= 0) {
            forwardForm(request, response, user, customer,
                    "Could not create the appointment. Please try again.",
                    petIdParam, serviceIdParam, preferredDoctorIdParam, appointmentDate, appointmentTime, notes,
                    customerPets, services, veterinarians);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/customer/appointments?tab=upcoming&booked=1");
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response, User user, Customer customer)
            throws ServletException, IOException {
        forwardForm(request, response, user, customer, null, null, null, null, null, null, null, null, null, null);
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response,
            User user, Customer customer, String formError,
            String selectedPetId, String selectedServiceId, String selectedPreferredDoctorId,
            String appointmentDate, String appointmentTime, String notes,
            List<Pet> customerPets, List<Service> services, List<User> veterinarians)
            throws ServletException, IOException {
        request.setAttribute("customerCurrentPage", "appointments");
        request.setAttribute("user", user);
        request.setAttribute("customer", customer);
        request.setAttribute("customerPets", customerPets != null ? customerPets : petDAO.findByCustomerId(customer.getCustomerId()));
        request.setAttribute("services", services != null ? services : serviceService.getAllServices());
        request.setAttribute("veterinarians", veterinarians != null ? veterinarians : appointmentDAO.getAllVeterinarians());
        request.setAttribute("formError", formError);
        request.setAttribute("selectedPetId", selectedPetId);
        request.setAttribute("selectedServiceId", selectedServiceId);
        request.setAttribute("selectedPreferredDoctorId", selectedPreferredDoctorId);
        request.setAttribute("selectedAppointmentDate", appointmentDate);
        request.setAttribute("selectedAppointmentTime", appointmentTime);
        request.setAttribute("notesValue", notes);
        request.getRequestDispatcher("/WEB-INF/views/customer/book-appointment.jsp").forward(request, response);
    }
}