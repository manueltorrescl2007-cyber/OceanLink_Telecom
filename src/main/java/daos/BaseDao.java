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
        String pass = "Mathias_Pucp2006"; // Esto se cambia dependiendo de la persona que ejecute la DB
        String url = "jdbc:mysql://127.0.0.1:3306/ocean_link";
        return DriverManager.getConnection(url, user, pass);
    }
}
