package dao;

public interface DashboardStatsDAO {
    int countNewCustomersThisMonth();
    int countNewAppointmentsThisMonth();
    int countTotalUsers();

    // Bổ sung cho dashboard
    int countTotalPatients();
    int countNewRegistrationsLast7Days();
    int countTotalAppointments();
}
