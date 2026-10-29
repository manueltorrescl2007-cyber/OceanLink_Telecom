package beans;

import java.sql.Timestamp;

public class Servicio {

  private int idServicio;
  private int idSolicitud;
  private int idRuta;
  private long capacidadAsignada;
  private Timestamp fechaActivacion;
  private String estado;

  // Datos de las tablas relacionadas
  private String nombreCliente;
  private String nombreRuta;
  private String estadoSolicitud;

  public int getIdServicio() {
    return idServicio;
  }

  public void setIdServicio(int idServicio) {
    this.idServicio = idServicio;
  }

  public int getIdSolicitud() {
    return idSolicitud;
  }

  public void setIdSolicitud(int idSolicitud) {
    this.idSolicitud = idSolicitud;
  }

  public int getIdRuta() {
    return idRuta;
  }

  public void setIdRuta(int idRuta) {
    this.idRuta = idRuta;
  }

  public long getCapacidadAsignada() {
    return capacidadAsignada;
  }

  public void setCapacidadAsignada(long capacidadAsignada) {
    this.capacidadAsignada = capacidadAsignada;
  }

  public Timestamp getFechaActivacion() {
    return fechaActivacion;
  }

  public void setFechaActivacion(Timestamp fechaActivacion) {
    this.fechaActivacion = fechaActivacion;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }

  public String getNombreCliente() {
    return nombreCliente;
  }

  public void setNombreCliente(String nombreCliente) {
    this.nombreCliente = nombreCliente;
  }

  public String getNombreRuta() {
    return nombreRuta;
  }

  public void setNombreRuta(String nombreRuta) {
    this.nombreRuta = nombreRuta;
  }

  public String getEstadoSolicitud() {
    return estadoSolicitud;
  }

  public void setEstadoSolicitud(String estadoSolicitud) {
    this.estadoSolicitud = estadoSolicitud;
  }
}
