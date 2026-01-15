/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

/**
 *
 * @author Acer
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // ====== THAY CÁC THÔNG TIN NÀY ======
    private static final String SERVER_NAME = "localhost"; 
    private static final String DATABASE_NAME = "BLX";
    private static final String USERNAME = "sa";
    private static final String PASSWORD = "123456";
    private static final int PORT = 1433;
    // ==================================

    public static Connection getConnection() throws SQLException {
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT
                + ";databaseName=" + DATABASE_NAME
                + ";encrypt=true;trustServerCertificate=true";

        return DriverManager.getConnection(url, USERNAME, PASSWORD);
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("✅ Kết nối SQL Server THÀNH CÔNG!");
            }
        } catch (SQLException e) {
            System.out.println("❌ Kết nối THẤT BẠI!");
            e.printStackTrace();
        }
    }
}

