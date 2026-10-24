package beans.networkoperator;

import beans.Usuario;

public class Solicitud {
  private int idSolicitud;
  private Cliente cliente;
  private Usuario usuario;
  private LandingStation landingOrigen;
  private LandingStation landingDestino;
  private int capacidadSolicitada;
  private String estado;
  private String justificacion;
  private String fechaRegistro;

  public int getIdSolicitud() { return idSolicitud; }
  public void setIdSolicitud(int idSolicitud) { this.idSolicitud = idSolicitud; }
  public Cliente getCliente() { return cliente; }
  public void setCliente(Cliente cliente) { this.cliente = cliente; }
  public Usuario getUsuario() { return usuario; }
  public void setUsuario(Usuario usuario) { this.usuario = usuario; }
  public LandingStation getLandingOrigen() { return landingOrigen; }
  public void setLandingOrigen(LandingStation landingOrigen) { this.landingOrigen = landingOrigen; }
  public LandingStation getLandingDestino() { return landingDestino; }
  public void setLandingDestino(LandingStation landingDestino) { this.landingDestino = landingDestino; }
  public int getCapacidadSolicitada() { return capacidadSolicitada; }
  public void setCapacidadSolicitada(int capacidadSolicitada) { this.capacidadSolicitada = capacidadSolicitada; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
  public String getJustificacion() { return justificacion; }
  public void setJustificacion(String justificacion) { this.justificacion = justificacion; }
  public String getFechaRegistro() { return fechaRegistro; }
  public void setFechaRegistro(String fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
