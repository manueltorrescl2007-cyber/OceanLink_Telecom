package beans.maintenance;

public class ServicioAfectado {

  private int idServicio;
  private String cliente;
  private String ruta;
  private String segmentosEnMantenimiento;
  private String usuariosEncargados;

  // Constructor vacío
  public ServicioAfectado() {
  }

  // Getters y Setters

  public int getIdServicio() {
    return idServicio;
  }

  public void setIdServicio(int idServicio) {
    this.idServicio = idServicio;
  }

  public String getCliente() {
    return cliente;
  }

  public void setCliente(String cliente) {
    this.cliente = cliente;
  }

  public String getRuta() {
    return ruta;
  }

  public void setRuta(String ruta) {
    this.ruta = ruta;
  }

  public String getSegmentosEnMantenimiento() {
    return segmentosEnMantenimiento;
  }

  public void setSegmentosEnMantenimiento(
    String segmentosEnMantenimiento) {
    this.segmentosEnMantenimiento = segmentosEnMantenimiento;
  }

  public String getUsuariosEncargados() {
    return usuariosEncargados;
  }

  public void setUsuariosEncargados(String usuariosEncargados) {
    this.usuariosEncargados = usuariosEncargados;
  }
}
