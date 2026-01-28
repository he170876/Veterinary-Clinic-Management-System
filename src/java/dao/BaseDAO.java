package dao;

import java.sql.Connection;
import java.sql.SQLException;
import utils.DBContext;

/**
 * Base DAO providing a helper to obtain a JDBC connection from {@link DBContext}.
 * All JDBC DAO implementations should extend this class.
 */
public abstract class BaseDAO {

    protected Connection getConnection() throws SQLException {
        return DBContext.getConnection();
    }
}

