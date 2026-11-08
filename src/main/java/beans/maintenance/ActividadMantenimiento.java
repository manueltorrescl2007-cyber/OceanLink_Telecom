package beans.maintenance;

import java.time.LocalDateTime;
import java.util.Date;

public class ActividadMantenimiento {
    private int idActividad;
    private int idMantenimiento;
    private Integer idUsuario;
    private LocalDateTime fechaHora;
    private String descripcionBitacora;
    private String tipoActividad;


    //Nombre del usuario que realizo la actividad
    // En caso de ser nulo, se colocara como usuario a "Sistema"
    private String nombreUsuario;

  public ActividadMantenimiento() {
  }

  public ActividadMantenimiento(int idActividad, int idMantenimiento, Integer idUsuario, LocalDateTime fechaHora, String descripcionBitacora, String tipoActividad, String nombreUsuario) {
    this.idActividad = idActividad;
    this.idMantenimiento = idMantenimiento;
    this.idUsuario = idUsuario;
    this.fechaHora = fechaHora;
    this.descripcionBitacora = descripcionBitacora;
    this.tipoActividad = tipoActividad;
    this.nombreUsuario = nombreUsuario;
  }

  public int getIdActividad() {
    return idActividad;
  }

  public void setIdActividad(int idActividad) {
    this.idActividad = idActividad;
  }

  public int getIdMantenimiento() {
    return idMantenimiento;
  }

  public void setIdMantenimiento(int idMantenimiento) {
    this.idMantenimiento = idMantenimiento;
  }

  public Integer getIdUsuario() {
    return idUsuario;
  }

  public void setIdUsuario(Integer idUsuario) {
    this.idUsuario = idUsuario;
  }

  public LocalDateTime getFechaHora() {
    return fechaHora;
  }

  public void setFechaHora(LocalDateTime fechaHora) {
    this.fechaHora = fechaHora;
  }

  public String getDescripcionBitacora() {
    return descripcionBitacora;
  }

  public void setDescripcionBitacora(String descripcionBitacora) {
    this.descripcionBitacora = descripcionBitacora;
  }

  public String getTipoActividad() {
    return tipoActividad;
  }

  public void setTipoActividad(String tipoActividad) {
    this.tipoActividad = tipoActividad;
  }

  public String getNombreUsuario() {
    return nombreUsuario;
  }

  public void setNombreUsuario(String nombreUsuario) {
    this.nombreUsuario = nombreUsuario;
  }
}
