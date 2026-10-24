package beans.networkoperator;

import beans.Usuario;

import java.util.ArrayList;

public class Incidencia {
  private int idIncidencia;
  private String codigo;
  private String titulo;
  private String descripcion;
  private String severidad;
  private String estado;
  private String fechaRegistro;
  private String fechaRestauracion;
  private String fechaCierre;
  private Usuario usuario;

  private ArrayList<Segmento> segmentos = new ArrayList<>();

  public int getIdIncidencia() { return idIncidencia; }
  public void setIdIncidencia(int idIncidencia) { this.idIncidencia = idIncidencia; }
  public String getCodigo() { return codigo; }
  public void setCodigo(String codigo) { this.codigo = codigo; }
  public String getTitulo() { return titulo; }
  public void setTitulo(String titulo) { this.titulo = titulo; }
  public String getDescripcion() { return descripcion; }
  public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
  public String getSeveridad() { return severidad; }
  public void setSeveridad(String severidad) { this.severidad = severidad; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
  public String getFechaRegistro() { return fechaRegistro; }
  public void setFechaRegistro(String fechaRegistro) { this.fechaRegistro = fechaRegistro; }
  public String getFechaRestauracion() { return fechaRestauracion; }
  public void setFechaRestauracion(String fechaRestauracion) { this.fechaRestauracion = fechaRestauracion; }
  public String getFechaCierre() { return fechaCierre; }
  public void setFechaCierre(String fechaCierre) { this.fechaCierre = fechaCierre; }
  public Usuario getUsuario() { return usuario; }
  public void setUsuario(Usuario usuario) { this.usuario = usuario; }
  public ArrayList<Segmento> getSegmentos() { return segmentos; }
  public void setSegmentos(ArrayList<Segmento> segmentos) { this.segmentos = segmentos; }

  public String getSeveridadTexto() {
    return "Critica".equals(severidad) ? "Crítica" : severidad;
  }

  public String getEstadoTexto() {
    if (estado == null) {
      return "";
    }
    switch (estado) {
      case "En analisis":           return "En análisis";
      case "Reparacion programada": return "Reparación programada";
      case "En reparacion":         return "En reparación";
      case "Servicio restaurado":   return "Restaurado";
      default:                      return estado;
    }
  }

  public String getClaseSeveridad() {
    return severidad == null ? "" : "severidad-" + severidad.toLowerCase();
  }

  public String getCodigosSegmentos() {
    String texto = "";
    for (Segmento s : segmentos) {
      if (!texto.isEmpty()) {
        texto += ", ";
      }
      texto += s.getCodigo();
    }
    return texto.isEmpty() ? "-" : texto;
  }
}
