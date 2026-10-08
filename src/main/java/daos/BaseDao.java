package daos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class BaseDao {

    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver de MySQL", e);
        }
        String user = "root";
        String pass = "root";
        String url = "jdbc:mysql://127.0.0.1:3306/ocean_link";
        return DriverManager.getConnection(url, user, pass);
    }
}
