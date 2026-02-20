/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Appointment;
import model.Customer;
import model.Pet;
import model.User;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO extends DBContext {

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();

        String sql = """
            SELECT
                a.appointment_id,
                a.appointment_time,
                a.status,
                a.veterinarian_id,
                a.service_id,
                s.name AS service_name,

                p.pet_id,
                p.name AS pet_name,
                p.photoUrl AS pet_photo,

                c.customer_id,
                u.full_name AS customer_name,
                
                vet_user.full_name AS veterinarian_name

            FROM appointments a
            JOIN pets p ON a.pet_id = p.pet_id
            JOIN customers c ON a.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN veterinarians v ON a.veterinarian_id = v.veterinarian_id
            LEFT JOIN users vet_user ON v.user_id = vet_user.user_id
            LEFT JOIN services s ON a.service_id = s.service_id
            WHERE p.isDeleted = 0
            ORDER BY a.appointment_time
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                Appointment ap = new Appointment();
                ap.setAppointmentId(rs.getInt("appointment_id"));
                ap.setAppointmentTime(
                        rs.getTimestamp("appointment_time").toLocalDateTime()
                );
                ap.setStatus(rs.getString("status"));
                ap.setVeterinarianId(rs.getInt("veterinarian_id"));
                ap.setService(rs.getString("service_name"));

                // Pet
                Pet pet = new Pet();
                pet.setPetId(rs.getInt("pet_id"));
                pet.setName(rs.getString("pet_name"));
                pet.setPhotoURL(rs.getString("pet_photo"));
                ap.setPet(pet);

                // Customer with User
                Customer cus = new Customer();
                cus.setCustomerId(rs.getInt("customer_id"));
                User customerUser = new User();
                customerUser.setFullName(rs.getString("customer_name"));
                cus.setUser(customerUser);
                ap.setCustomer(cus);
                
                // Store veterinarian name as a custom field (we'll add helper methods)
                String vetName = rs.getString("veterinarian_name");
                if (vetName != null) {
                    ap.setVeterinarianName(vetName);
                }

                list.add(ap);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<User> getAllVeterinarians() {
        List<User> list = new ArrayList<>();
        String sql = """
            SELECT v.veterinarian_id, u.full_name
            FROM veterinarians v
            JOIN users u ON v.user_id = u.user_id
            WHERE u.status = 'Active'
            ORDER BY u.full_name
        """;

        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                User vet = new User();
                vet.setUserId(rs.getInt("veterinarian_id")); // Store veterinarian_id as userId for the select
                vet.setFullName(rs.getString("full_name"));
                list.add(vet);
            }
        }catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateAppointmentDoctor(int appointmentId, int veterinarianId) {
        String sql = "UPDATE appointments SET veterinarian_id = ? WHERE appointment_id = ?";
        try (
            Connection con = getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, veterinarianId);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

