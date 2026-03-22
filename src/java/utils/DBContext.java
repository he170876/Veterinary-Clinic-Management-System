package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    /**
     * Kết nối phải trùng cách bạn mở SSMS (server + instance hoặc cổng TCP).
     * - Named instance (vd. MSI\\MSSQLSERVER12): dùng instanceName; cần SQL Server Browser chạy.
     * - Hoặc thay bằng cổng thật: jdbc:sqlserver://localhost:64662;databaseName=...
     *   (xem cổng trong SQL Server Configuration Manager → TCP/IP → IPAll).
     */
    private static final String URL = "jdbc:sqlserver://localhost;instanceName=MSSQLSERVER12"
            + ";databaseName=VetClinicManagement1"
            + ";encrypt=true;trustServerCertificate=true"
            + ";loginTimeout=15";
    private static final String USER = "sa";
    private static final String PASS = "123";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found!");
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void main(String[] args) {
        System.out.println("Testing...");
        try (Connection c = getConnection()) {
            System.out.println("SUCCESS! DB: " + c.getCatalog());
        } catch (SQLException e) {
            System.out.println("FAILED: " + e.getMessage());
        }
    }
}