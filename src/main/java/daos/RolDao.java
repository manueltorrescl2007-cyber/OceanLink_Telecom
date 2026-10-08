package daos;

import beans.Rol;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class RolDao extends BaseDao {

    /* Lista de roles para llenar el <select> del formulario de usuario */
    public ArrayList<Rol> listarRoles() {
        ArrayList<Rol> lista = new ArrayList<>();
        String sql = "SELECT id_rol, nombre, descripcion FROM roles_usuario ORDER BY id_rol";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Rol rol = new Rol();
                rol.setIdRol(rs.getInt("id_rol"));
                rol.setNombre(rs.getString("nombre"));
                rol.setDescripcion(rs.getString("descripcion"));
                lista.add(rol);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}
