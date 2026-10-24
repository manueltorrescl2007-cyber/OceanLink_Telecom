package beans.networkoperator;

public class Cliente {
  private int idCliente;
  private String nombre;
  private String razonSocial;
  private String ruc;
  private String correo;
  private String telefono;
  private String estado;

  public int getIdCliente() { return idCliente; }
  public void setIdCliente(int idCliente) { this.idCliente = idCliente; }
  public String getNombre() { return nombre; }
  public void setNombre(String nombre) { this.nombre = nombre; }
  public String getRazonSocial() { return razonSocial; }
  public void setRazonSocial(String razonSocial) { this.razonSocial = razonSocial; }
  public String getRuc() { return ruc; }
  public void setRuc(String ruc) { this.ruc = ruc; }
  public String getCorreo() { return correo; }
  public void setCorreo(String correo) { this.correo = correo; }
  public String getTelefono() { return telefono; }
  public void setTelefono(String telefono) { this.telefono = telefono; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
}
