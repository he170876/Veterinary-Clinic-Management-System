package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DBContext {

    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "1433";
    private static final String DEFAULT_INSTANCE = "MSSQLSERVER12";
    private static final String DEFAULT_DB = "VetClinicManagement";
    private static final String DEFAULT_USER = "sa";
    private static final String DEFAULT_PASS = "123456";

    private static final String HOST = getConfig("DB_HOST", DEFAULT_HOST);
    private static final String PORT = getConfig("DB_PORT", DEFAULT_PORT);
    private static final String INSTANCE = getConfig("DB_INSTANCE", DEFAULT_INSTANCE);
    private static final String DB_NAME = getConfig("DB_NAME", DEFAULT_DB);
    private static final String USER = getConfig("DB_USER", DEFAULT_USER);
    private static final String PASS = getConfig("DB_PASS", DEFAULT_PASS);

    // Optional full URL override for local debugging or deployment.
    private static final String DIRECT_URL = getConfig("DB_URL", "");

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver not found!");
        }
    }

    public static Connection getConnection() throws SQLException {
        List<String> candidates = buildCandidateUrls();
        SQLException lastException = null;

        for (String url : candidates) {
            try {
                return DriverManager.getConnection(url, USER, PASS);
            } catch (SQLException e) {
                lastException = e;
            }
        }

        throw lastException != null ? lastException : new SQLException("No SQL Server connection URL candidates available.");
    }

    private static List<String> buildCandidateUrls() {
        List<String> urls = new ArrayList<>();

        if (!DIRECT_URL.isBlank()) {
            urls.add(DIRECT_URL);
            return urls;
        }

        // Prefer direct TCP port; this does not require SQL Server Browser (UDP 1434).
        urls.add("jdbc:sqlserver://" + HOST + ":" + PORT
                + ";databaseName=" + DB_NAME
                + ";encrypt=true;trustServerCertificate=true"
                + ";loginTimeout=15");

        // Fallback to named instance for environments that rely on instance discovery.
        urls.add("jdbc:sqlserver://" + HOST + ";instanceName=" + INSTANCE
                + ";databaseName=" + DB_NAME
                + ";encrypt=true;trustServerCertificate=true"
                + ";loginTimeout=15");

        return urls;
    }

    private static String getConfig(String key, String defaultValue) {
        String fromSystem = System.getProperty(key);
        if (fromSystem != null && !fromSystem.isBlank()) {
            return fromSystem.trim();
        }

        String fromEnv = System.getenv(key);
        if (fromEnv != null && !fromEnv.isBlank()) {
            return fromEnv.trim();
        }

        return defaultValue;
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