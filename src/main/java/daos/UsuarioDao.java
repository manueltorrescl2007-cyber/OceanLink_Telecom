package daos;

import beans.Rol;
import beans.Usuario;
import utils.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UsuarioDao extends BaseDao {

    // SELECT común para listar y para buscar uno (usuario + nombre de su rol)
    private static final String SELECT_USUARIO =
            "SELECT u.id_usuario, u.nombre, u.correo, u.estado, "
          + "r.id_rol, r.nombre AS nombre_rol "
          + "FROM usuarios u "
          + "INNER JOIN roles_usuario r ON u.id_rol = r.id_rol ";

    /* ========== READ: lista de todos los usuarios (sin filtros) ========== */
    public ArrayList<Usuario> listarUsuarios() {
        return listarUsuarios(-1, null);
    }

    /* READ: lista filtrada por rol y/o estado
     * idRol  : -1 = todos los roles
     * estado : null o "" = todos los estados ("activo" / "inactivo")
     */
    public ArrayList<Usuario> listarUsuarios(int idRol, String estado) {
        ArrayList<Usuario> lista = new ArrayList<>();

        boolean filtrarRol = idRol > 0;
        boolean filtrarEstado = estado != null && !estado.isEmpty();

        // "WHERE 1 = 1" siempre es verdadero: permite ir agregando "AND ..." sin preocuparse
        StringBuilder sql = new StringBuilder(SELECT_USUARIO + "WHERE 1 = 1 ");
        if (filtrarRol) {
            sql.append("AND u.id_rol = ? ");
        }
        if (filtrarEstado) {
            sql.append("AND u.estado = ? ");
        }
        sql.append("ORDER BY u.id_usuario");

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            // Los ? se llenan en el mismo orden en que se agregaron
            int indice = 1;
            if (filtrarRol) {
                pstmt.setInt(indice++, idRol);
            }
            if (filtrarEstado) {
                pstmt.setString(indice++, estado);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(fetchUsuario(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    /* ========== READ: un usuario por su id (null si no existe) ========== */
    public Usuario obtenerUsuario(int idUsuario) {
        Usuario usuario = null;
        String sql = SELECT_USUARIO + "WHERE u.id_usuario = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    usuario = fetchUsuario(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

  public Usuario autenticarUsuario(
    String correo,
    String contrasena
  ) {

    if (correo == null || correo.isBlank()
      || contrasena == null || contrasena.isEmpty()) {
      return null;
    }

    String sql =
      "SELECT u.id_usuario, u.nombre, u.correo, "
        + "u.contrasena, u.estado, "
        + "r.id_rol, r.nombre AS nombre_rol "
        + "FROM usuarios u "
        + "INNER JOIN roles_usuario r ON u.id_rol = r.id_rol "
        + "WHERE u.correo = ? "
        + "LIMIT 1";

    try (Connection conn = getConnection();
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

      pstmt.setString(1, correo.trim());

      Usuario usuario = null;
      String passwordGuardada = null;
      String estado = null;

      try (ResultSet rs = pstmt.executeQuery()) {

        if (rs.next()) {
          usuario = fetchUsuario(rs);
          passwordGuardada = rs.getString("contrasena");
          estado = rs.getString("estado");
        }
      }

      // No permitir el acceso a cuentas inactivas.
      if (usuario == null
        || !"activo".equalsIgnoreCase(estado)) {
        return null;
      }

      // Verificar la contraseña.
      if (!PasswordUtil.verificarPassword(
        contrasena,
        passwordGuardada
      )) {
        return null;
      }

      // Si la contraseña antigua estaba en texto plano,
      // la migramos a hash después de verificarla.
      if (!PasswordUtil.esHashAlmacenado(passwordGuardada)) {

        String nuevoHash =
          PasswordUtil.hashPassword(contrasena);

        String sqlActualizar =
          "UPDATE usuarios SET contrasena = ? "
            + "WHERE id_usuario = ? AND contrasena = ?";

        try (PreparedStatement actualizar =
               conn.prepareStatement(sqlActualizar)) {

          actualizar.setString(1, nuevoHash);
          actualizar.setInt(2, usuario.getIdUsuario());
          actualizar.setString(3, passwordGuardada);

          actualizar.executeUpdate();
        }
      }

      // fetchUsuario no coloca la contraseña en el Bean.
      return usuario;

    } catch (SQLException e) {
      throw new IllegalStateException(
        "Error al autenticar al usuario.",
        e
      );
    }
  }

    /* ========== CREATE: nuevo usuario (estado = 'activo' por defecto en MySQL) ========== */
    public void crearUsuario(Usuario usuario) {

      String sql =
        "INSERT INTO usuarios "
          + "(nombre, correo, contrasena, id_rol) "
          + "VALUES (?, ?, ?, ?)";

      String passwordHash =
        PasswordUtil.hashPassword(usuario.getContrasena());

      try (Connection conn = getConnection();
           PreparedStatement pstmt = conn.prepareStatement(sql)) {

        pstmt.setString(1, usuario.getNombre());
        pstmt.setString(2, usuario.getCorreo());
        pstmt.setString(3, passwordHash);
        pstmt.setInt(4, usuario.getRol().getIdRol());

        pstmt.executeUpdate();

      } catch (SQLException e) {
        throw new IllegalStateException(
          "No se pudo crear el usuario.",
          e
        );
      }
    }

    /* ========== UPDATE: nombre, correo y rol (la contraseña no se toca aquí) ========== */
    public void actualizarUsuario(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombre = ?, correo = ?, id_rol = ? "
                   + "WHERE id_usuario = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, usuario.getNombre());
            pstmt.setString(2, usuario.getCorreo());
            pstmt.setInt(3, usuario.getRol().getIdRol());
            pstmt.setInt(4, usuario.getIdUsuario());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /* ========== DELETE lógico: activar / desactivar (RF03) ========== */
    public void cambiarEstado(int idUsuario, String estado) {
        String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado);   // "activo" o "inactivo"
            pstmt.setInt(2, idUsuario);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /* ========== Ayudante: convierte la fila actual del ResultSet en un Usuario ========== */
    private Usuario fetchUsuario(ResultSet rs) throws SQLException {
        Rol rol = new Rol();
        rol.setIdRol(rs.getInt("id_rol"));
        rol.setNombre(rs.getString("nombre_rol"));

        Usuario usuario = new Usuario();
        usuario.setIdUsuario(rs.getInt("id_usuario"));
        usuario.setNombre(rs.getString("nombre"));
        usuario.setCorreo(rs.getString("correo"));
        usuario.setEstado(rs.getString("estado"));
        usuario.setRol(rol);
        return usuario;
    }
}
