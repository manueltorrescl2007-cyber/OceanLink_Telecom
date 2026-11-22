package beans.admin;

public class DashboardItem {
  // Campos para Top Segmentos
  private String codigo;
  private long capacidadTotal;
  private long capacidadOcupada;
  private long capacidadReservada;
  private String tramo;

  // Campos para Últimos Usuarios
  private int idUsuario;
  private String nombre;
  private String correo;
  private String rol;

  // Campos para Última Infraestructura
  private String estructura;
  private String tipo;
  private String detalle;

  // Campo común
  private String estado;

  public DashboardItem() {
  }

  public String getCodigo() { return codigo; }
  public void setCodigo(String codigo) { this.codigo = codigo; }

  public long getCapacidadTotal() { return capacidadTotal; }
  public void setCapacidadTotal(long capacidadTotal) { this.capacidadTotal = capacidadTotal; }

  public long getCapacidadOcupada() { return capacidadOcupada; }
  public void setCapacidadOcupada(long capacidadOcupada) { this.capacidadOcupada = capacidadOcupada; }

  public long getCapacidadReservada() { return capacidadReservada; }
  public void setCapacidadReservada(long capacidadReservada) { this.capacidadReservada = capacidadReservada; }

  public String getTramo() { return tramo; }
  public void setTramo(String tramo) { this.tramo = tramo; }

  public int getIdUsuario() { return idUsuario; }
  public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

  public String getNombre() { return nombre; }
  public void setNombre(String nombre) { this.nombre = nombre; }

  public String getCorreo() { return correo; }
  public void setCorreo(String correo) { this.correo = correo; }

  public String getRol() { return rol; }
  public void setRol(String rol) { this.rol = rol; }

  public String getEstructura() { return estructura; }
  public void setEstructura(String estructura) { this.estructura = estructura; }

  public String getTipo() { return tipo; }
  public void setTipo(String tipo) { this.tipo = tipo; }

  public String getDetalle() { return detalle; }
  public void setDetalle(String detalle) { this.detalle = detalle; }

  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
}
