package beans.networkoperator;

import beans.Usuario;

public class Observacion {
  private int idObservacion;
  private Incidencia incidencia;
  private Usuario usuario;
  private String fechaHora;
  private String mensaje;

  public int getIdObservacion() { return idObservacion; }
  public void setIdObservacion(int idObservacion) { this.idObservacion = idObservacion; }
  public Incidencia getIncidencia() { return incidencia; }
  public void setIncidencia(Incidencia incidencia) { this.incidencia = incidencia; }
  public Usuario getUsuario() { return usuario; }
  public void setUsuario(Usuario usuario) { this.usuario = usuario; }
  public String getFechaHora() { return fechaHora; }
  public void setFechaHora(String fechaHora) { this.fechaHora = fechaHora; }
  public String getMensaje() { return mensaje; }
  public void setMensaje(String mensaje) { this.mensaje = mensaje; }
}
