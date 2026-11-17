package beans.supervisor;

import java.time.LocalDateTime;

public class HistoricoGeneral {
  private int idNumerico;          // id_incidencia o id_mantenimiento (para enlazar al detalle)
  private String codigoMostrar;    // INC-001 o MNT-001
  private String tipoRegistro;     // "Incidencia" o "Mantenimiento"
  private String segmento;         // Código del segmento o segmentos separados por coma
  private String detalleTipo;      // Título de incidencia o "Preventivo" / "Correctivo"
  private LocalDateTime fechaOrden;// Fecha real para ordenar cronológicamente del más reciente al más antiguo
  private String fechaFormateada;  // Ej. "02 sep 2026"
  private String estadoSeveridad;  // "Critica", "Alta", "Media", "Leve" o "Finalizado", "Cancelado"
  private String claseBadge;       // Clase CSS correspondiente

  public HistoricoGeneral() {
  }

  public int getIdNumerico() { return idNumerico; }
  public void setIdNumerico(int idNumerico) { this.idNumerico = idNumerico; }

  public String getCodigoMostrar() { return codigoMostrar; }
  public void setCodigoMostrar(String codigoMostrar) { this.codigoMostrar = codigoMostrar; }

  public String getTipoRegistro() { return tipoRegistro; }
  public void setTipoRegistro(String tipoRegistro) { this.tipoRegistro = tipoRegistro; }

  public String getSegmento() { return segmento; }
  public void setSegmento(String segmento) { this.segmento = segmento; }

  public String getDetalleTipo() { return detalleTipo; }
  public void setDetalleTipo(String detalleTipo) { this.detalleTipo = detalleTipo; }

  public LocalDateTime getFechaOrden() { return fechaOrden; }
  public void setFechaOrden(LocalDateTime fechaOrden) { this.fechaOrden = fechaOrden; }

  public String getFechaFormateada() { return fechaFormateada; }
  public void setFechaFormateada(String fechaFormateada) { this.fechaFormateada = fechaFormateada; }

  public String getEstadoSeveridad() { return estadoSeveridad; }
  public void setEstadoSeveridad(String estadoSeveridad) { this.estadoSeveridad = estadoSeveridad; }

  public String getClaseBadge() { return claseBadge; }
  public void setClaseBadge(String claseBadge) { this.claseBadge = claseBadge; }
}
