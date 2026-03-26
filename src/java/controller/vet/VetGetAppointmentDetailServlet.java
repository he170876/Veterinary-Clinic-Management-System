package controller.vet;

import dao.AppointmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Appointment;
import model.Customer;
import model.Pet;
import model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

/**
 * Vet-safe detail API used by the "Details" modal on:
 * - `web/WEB-INF/views/vet/patients-queue.jsp`
 * - `web/WEB-INF/views/vet/dashboard.jsp`
 *
 * Endpoint: GET `/vet/GetAppointmentDetail?appointmentId=...`
 *
 * Response contract (JSON):
 * - success: boolean
 * - message: string (only present when success=false)
 * - appointmentId: number
 * - status: string
 * - date: "yyyy-MM-dd" (appointment_date)
 * - time: display string for slot (AM/PM -> English label)
 * - formattedDateWithSlot: display string (date + slot)
 * - service: string (already merged for multi-service appointments by AppointmentDAO)
 * - notes: string (nullable in DB; returned as "" if null)
 * - veterinarianId / veterinarianName
 * - pet: { name, photoUrl, species, breed, gender, age, weight }
 * - owner: { name, email, phone, address }
 *
 * Notes:
 * - This is intentionally a small, "modal-friendly" payload (not the full Appointment model).
 * - This servlet does not implement RBAC itself; access control is assumed to be enforced upstream
 *   (e.g., by RoleBasedAccessFilter) similarly to other /vet/* endpoints.
 */
@WebServlet("/vet/GetAppointmentDetail")
public class VetGetAppointmentDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Always return JSON; the client expects r.json() in `vet-appointment-detail-modal.jspf`.
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Required query parameter.
        String idParam = request.getParameter("appointmentId");
        if (idParam == null || idParam.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Missing appointmentId\"}");
            return;
        }

        // Defensive parsing: avoid 500 + HTML error page (which would break r.json()).
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"Invalid appointmentId\"}");
            return;
        }

        AppointmentDAO dao = new AppointmentDAO();
        // Uses the shared detail loader that already:
        // - merges multi-service appointment rows
        // - includes notes, customer/vet names, etc.
        Appointment ap = dao.getAppointmentDetail(appointmentId);
        if (ap == null) {
            out.print("{\"success\":false,\"message\":\"Appointment not found\"}");
            return;
        }

        // Build JSON manually (no JSON library in this project). See esc() for minimal escaping.
        out.print(buildJson(ap));
    }

    private String buildJson(Appointment ap) {
        Pet pet = ap.getPet();
        Customer cus = ap.getCustomer();
        User owner = cus != null ? cus.getUser() : null;

        // Age is derived on the server for a stable display string in the modal.
        // We keep it simple: years + months, or just one component.
        String petAge = "";
        if (pet != null && pet.getBirthDate() != null) {
            Period period = Period.between(pet.getBirthDate(), LocalDate.now());
            int years = period.getYears();
            int months = period.getMonths();
            if (years > 0 && months > 0) {
                petAge = years + " year" + (years > 1 ? "s" : "") + " " + months + " month" + (months > 1 ? "s" : "");
            } else if (years > 0) {
                petAge = years + " year" + (years > 1 ? "s" : "");
            } else {
                petAge = months + " month" + (months > 1 ? "s" : "");
            }
        }

        // ISO-ish format for a stable client display/parsing.
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"appointmentId\":").append(ap.getAppointmentId()).append(",");
        json.append("\"status\":\"").append(esc(ap.getStatus())).append("\",");
        json.append("\"date\":\"").append(ap.getAppointmentDate() != null ? ap.getAppointmentDate().format(dateFmt) : "").append("\",");
        json.append("\"time\":\"").append(esc(ap.getDisplayTimePeriodEnglish())).append("\",");
        json.append("\"service\":\"").append(esc(ap.getService())).append("\",");
        json.append("\"notes\":\"").append(esc(ap.getNotes())).append("\",");
        json.append("\"formattedDateWithSlot\":\"").append(esc(ap.getFormattedDateWithSlot())).append("\",");
        // veterinarianId is nullable in the model (Integer); StringBuilder.append(Object) will output "null" if null.
        json.append("\"veterinarianId\":").append(ap.getVeterinarianId()).append(",");
        json.append("\"veterinarianName\":\"").append(esc(ap.getVeterinarianName())).append("\",");

        json.append("\"pet\":{");
        if (pet != null) {
            json.append("\"name\":\"").append(esc(pet.getName())).append("\",");
            json.append("\"photoUrl\":\"").append(esc(pet.getPhotoURL())).append("\",");
            json.append("\"species\":\"").append(esc(pet.getSpecies())).append("\",");
            json.append("\"breed\":\"").append(esc(pet.getBreed())).append("\",");
            json.append("\"gender\":\"").append(esc(pet.getGender())).append("\",");
            json.append("\"age\":\"").append(esc(petAge)).append("\",");
            json.append("\"weight\":\"").append(pet.getWeight() != null ? pet.getWeight() + " kg" : "").append("\"");
        }
        json.append("},");

        json.append("\"owner\":{");
        if (owner != null) {
            json.append("\"name\":\"").append(esc(owner.getFullName())).append("\",");
            json.append("\"email\":\"").append(esc(owner.getEmail())).append("\",");
            json.append("\"phone\":\"").append(esc(owner.getPhone())).append("\",");
            json.append("\"address\":\"").append(esc(owner.getAddress())).append("\"");
        }
        json.append("}");
        json.append("}");
        return json.toString();
    }

    private String esc(String s) {
        if (s == null) return "";
        // Minimal JSON string escaping for values we embed between quotes.
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}

