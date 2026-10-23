package beans;

import java.sql.Timestamp;

public class Solicitud {

  private int idSolicitud;
  private int idCliente;
  private int idUsuario;
  private int idLandingOrigen;
  private int idLandingDestino;
  private long capacidadSolicitada;
  private String estado;
  private String justificacion;
  private Timestamp fechaRegistro;

  // Nombres obtenidos al consultar las tablas relacionadas
  private String nombreCliente;
  private String nombreOrigen;
  private String nombreDestino;

  public int getIdSolicitud() {
    return idSolicitud;
  }

  public void setIdSolicitud(int idSolicitud) {
    this.idSolicitud = idSolicitud;
  }

  public int getIdCliente() {
    return idCliente;
  }

  public void setIdCliente(int idCliente) {
    this.idCliente = idCliente;
  }

  public int getIdUsuario() {
    return idUsuario;
  }

  public void setIdUsuario(int idUsuario) {
    this.idUsuario = idUsuario;
  }

  public int getIdLandingOrigen() {
    return idLandingOrigen;
  }

  public void setIdLandingOrigen(int idLandingOrigen) {
    this.idLandingOrigen = idLandingOrigen;
  }

  public int getIdLandingDestino() {
    return idLandingDestino;
  }

  public void setIdLandingDestino(int idLandingDestino) {
    this.idLandingDestino = idLandingDestino;
  }

  public long getCapacidadSolicitada() {
    return capacidadSolicitada;
  }

  public void setCapacidadSolicitada(long capacidadSolicitada) {
    this.capacidadSolicitada = capacidadSolicitada;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }

  public String getJustificacion() {
    return justificacion;
  }

  public void setJustificacion(String justificacion) {
    this.justificacion = justificacion;
  }

  public Timestamp getFechaRegistro() {
    return fechaRegistro;
  }

  public void setFechaRegistro(Timestamp fechaRegistro) {
    this.fechaRegistro = fechaRegistro;
  }

  public String getNombreCliente() {
    return nombreCliente;
  }

  public void setNombreCliente(String nombreCliente) {
    this.nombreCliente = nombreCliente;
  }

  public String getNombreOrigen() {
    return nombreOrigen;
  }

  public void setNombreOrigen(String nombreOrigen) {
    this.nombreOrigen = nombreOrigen;
  }

  public String getNombreDestino() {
    return nombreDestino;
  }

  public void setNombreDestino(String nombreDestino) {
    this.nombreDestino = nombreDestino;
  }
}
