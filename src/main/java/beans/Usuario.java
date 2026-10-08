package beans;

public class Usuario {
  private int idUsuario;
  private String nombre;
  private String correo;
  private String contrasena;
  private String estado;
  private Rol rol;

  public int getIdUsuario() { return idUsuario; }
  public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
  public String getNombre() { return nombre; }
  public void setNombre(String nombre) { this.nombre = nombre; }
  public String getCorreo() { return correo; }
  public void setCorreo(String correo) { this.correo = correo; }
  public String getContrasena() { return contrasena; }
  public void setContrasena(String contrasena) { this.contrasena = contrasena; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
  public Rol getRol() { return rol; }
  public void setRol(Rol rol) { this.rol = rol; }
}
