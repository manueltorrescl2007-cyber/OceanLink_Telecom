package beans.supervisor;

public class MetricaBarra {
  private String titulo;
  private String detalle;
  private String porcentaje;
  private String anchoBarra;
  private String claseBarra;

  public MetricaBarra() {
  }

  public MetricaBarra(String titulo, String detalle, String porcentaje, String anchoBarra, String claseBarra) {
    this.titulo = titulo;
    this.detalle = detalle;
    this.porcentaje = porcentaje;
    this.anchoBarra = anchoBarra;
    this.claseBarra = claseBarra;
  }

  public String getTitulo() {
    return titulo;
  }

  public void setTitulo(String titulo) {
    this.titulo = titulo;
  }

  public String getDetalle() {
    return detalle;
  }

  public void setDetalle(String detalle) {
    this.detalle = detalle;
  }

  public String getPorcentaje() {
    return porcentaje;
  }

  public void setPorcentaje(String porcentaje) {
    this.porcentaje = porcentaje;
  }

  public String getAnchoBarra() {
    return anchoBarra;
  }

  public void setAnchoBarra(String anchoBarra) {
    this.anchoBarra = anchoBarra;
  }

  public String getClaseBarra() {
    return claseBarra;
  }

  public void setClaseBarra(String claseBarra) {
    this.claseBarra = claseBarra;
  }
}
