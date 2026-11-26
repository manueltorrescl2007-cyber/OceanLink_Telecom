package daos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

// Clase abstracta: no se crea un BaseDao solo, existe para que los demás DAO la hereden
// y compartan la conexión a la base de datos (clase 8.1).
public abstract class BaseDao {

    // Los datos de conexión se leen de variables de entorno (igual que el correo en EmailService),
    // así el mismo código sirve en cada laptop y en AWS sin cambiar este archivo:
    //   DB_HOST     -> dirección del MySQL (en AWS, el "punto de enlace" de RDS)
    //   DB_USER     -> usuario de MySQL
    //   DB_PASSWORD -> contraseña de MySQL
    // Si una variable no está configurada, se usa el valor local por defecto.
    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver de MySQL", e);
        }

        String host = obtenerVariable("DB_HOST", "127.0.0.1");
        String user = obtenerVariable("DB_USER", "root");
        String pass = obtenerVariable("DB_PASSWORD", "root");

        // connectionTimeZone: Java y MySQL intercambian fechas en hora de Lima
        String url = "jdbc:mysql://" + host + ":3306/ocean_link?connectionTimeZone=America/Lima";

        Connection conn = DriverManager.getConnection(url, user, pass);

        // Los servidores de AWS usan hora UTC. Con esto, NOW() y las fechas por defecto
        // de MySQL usan la hora de Lima (UTC-5), igual que en nuestras laptops.
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("SET time_zone = '-05:00'");
        } catch (SQLException e) {
            conn.close();
            throw e;
        }

        return conn;
    }

    private String obtenerVariable(String nombre, String valorPorDefecto) {
        String valor = System.getenv(nombre);
        return (valor == null || valor.isBlank()) ? valorPorDefecto : valor.trim();
    }
}
