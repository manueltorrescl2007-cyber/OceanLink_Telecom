package daos;

import beans.Cliente;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ClienteDao extends BaseDao {

  private static final String SELECT_CLIENTE =
    "SELECT id_cliente, nombre, razon_social, RUC, correo, telefono, estado "
      + "FROM clientes ";

  // Listar todos los clientes
  public ArrayList<Cliente> listarClientes() throws SQLException {
    return listarClientes(null, null);
  }

  // Listar con búsqueda y filtro de estado opcionales
  public ArrayList<Cliente> listarClientes(String buscar, String estado)
    throws SQLException {

    ArrayList<Cliente> lista = new ArrayList<>();

    boolean filtrarBusqueda = buscar != null && !buscar.trim().isEmpty();
    boolean filtrarEstado = estado != null && !estado.isEmpty();

    StringBuilder sql = new StringBuilder(SELECT_CLIENTE + "WHERE 1 = 1 ");

    if (filtrarBusqueda) {
      sql.append("AND (nombre LIKE ? OR razon_social LIKE ? OR RUC LIKE ?) ");
    }

    if (filtrarEstado) {
      sql.append("AND estado = ? ");
    }

    sql.append("ORDER BY nombre");

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

      int indice = 1;

      if (filtrarBusqueda) {
        String texto = "%" + buscar.trim() + "%";

        pstmt.setString(indice++, texto);
        pstmt.setString(indice++, texto);
        pstmt.setString(indice++, texto);
      }

      if (filtrarEstado) {
        pstmt.setString(indice++, estado);
      }

      try (ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
          lista.add(fetchCliente(rs));
        }
      }
    }

    return lista;
  }

  // Buscar un cliente por su identificador
  public Cliente obtenerCliente(int idCliente) throws SQLException {

    String sql = SELECT_CLIENTE + "WHERE id_cliente = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setInt(1, idCliente);

      try (ResultSet rs = pstmt.executeQuery()) {
        if (rs.next()) {
          return fetchCliente(rs);
        }
      }
    }

    return null;
  }

  // Registrar un cliente
  public boolean crearCliente(Cliente cliente) throws SQLException {

    String sql =
      "INSERT INTO clientes "
        + "(nombre, razon_social, RUC, correo, telefono, estado) "
        + "VALUES (?, ?, ?, ?, ?, ?)";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, cliente.getNombre());
      pstmt.setString(2, cliente.getRazonSocial());
      pstmt.setString(3, cliente.getRuc());
      pstmt.setString(4, cliente.getCorreo());
      pstmt.setString(5, cliente.getTelefono());
      pstmt.setString(6, cliente.getEstado());

      return pstmt.executeUpdate() == 1;
    }
  }

  // Actualizar los datos de un cliente
  public boolean actualizarCliente(Cliente cliente) throws SQLException {

    String sql =
      "UPDATE clientes "
        + "SET nombre = ?, razon_social = ?, RUC = ?, "
        + "correo = ?, telefono = ?, estado = ? "
        + "WHERE id_cliente = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, cliente.getNombre());
      pstmt.setString(2, cliente.getRazonSocial());
      pstmt.setString(3, cliente.getRuc());
      pstmt.setString(4, cliente.getCorreo());
      pstmt.setString(5, cliente.getTelefono());
      pstmt.setString(6, cliente.getEstado());
      pstmt.setInt(7, cliente.getIdCliente());

      return pstmt.executeUpdate() == 1;
    }
  }

  // Activar o desactivar sin borrar su historial
  public boolean cambiarEstado(int idCliente, String estado)
    throws SQLException {

    if (!"activo".equals(estado) && !"inactivo".equals(estado)) {
      throw new IllegalArgumentException("Estado de cliente inválido");
    }

    String sql = "UPDATE clientes SET estado = ? WHERE id_cliente = ?";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, estado);
      pstmt.setInt(2, idCliente);

      return pstmt.executeUpdate() == 1;
    }
  }

  // Convertir una fila del resultado en un objeto Cliente
  private Cliente fetchCliente(ResultSet rs) throws SQLException {

    Cliente cliente = new Cliente();

    cliente.setIdCliente(rs.getInt("id_cliente"));
    cliente.setNombre(rs.getString("nombre"));
    cliente.setRazonSocial(rs.getString("razon_social"));
    cliente.setRuc(rs.getString("RUC"));
    cliente.setCorreo(rs.getString("correo"));
    cliente.setTelefono(rs.getString("telefono"));
    cliente.setEstado(rs.getString("estado"));

    return cliente;
  }
}
