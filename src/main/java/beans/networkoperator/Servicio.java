package beans.networkoperator;

public class Servicio {
  private int idServicio;
  private Solicitud solicitud;
  private Ruta ruta;
  private int capacidadAsignada;
  private String fechaActivacion;
  private String estado;

  public int getIdServicio() { return idServicio; }
  public void setIdServicio(int idServicio) { this.idServicio = idServicio; }
  public Solicitud getSolicitud() { return solicitud; }
  public void setSolicitud(Solicitud solicitud) { this.solicitud = solicitud; }
  public Ruta getRuta() { return ruta; }
  public void setRuta(Ruta ruta) { this.ruta = ruta; }
  public int getCapacidadAsignada() { return capacidadAsignada; }
  public void setCapacidadAsignada(int capacidadAsignada) { this.capacidadAsignada = capacidadAsignada; }
  public String getFechaActivacion() { return fechaActivacion; }
  public void setFechaActivacion(String fechaActivacion) { this.fechaActivacion = fechaActivacion; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
}
