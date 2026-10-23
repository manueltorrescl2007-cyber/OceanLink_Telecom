package beans;

public class Segmento {

  private int idSegmento;
  private String codigo;
  private int idLandingInicial;
  private int idLandingFinal;
  private long capacidadTotal;
  private long capacidadOcupada;
  private long capacidadReservada;
  private String estado;

  private String nombreInicial;
  private String nombreFinal;

  public int getIdSegmento() {
    return idSegmento;
  }

  public void setIdSegmento(int idSegmento) {
    this.idSegmento = idSegmento;
  }

  public String getCodigo() {
    return codigo;
  }

  public void setCodigo(String codigo) {
    this.codigo = codigo;
  }

  public int getIdLandingInicial() {
    return idLandingInicial;
  }

  public void setIdLandingInicial(int idLandingInicial) {
    this.idLandingInicial = idLandingInicial;
  }

  public int getIdLandingFinal() {
    return idLandingFinal;
  }

  public void setIdLandingFinal(int idLandingFinal) {
    this.idLandingFinal = idLandingFinal;
  }

  public long getCapacidadTotal() {
    return capacidadTotal;
  }

  public void setCapacidadTotal(long capacidadTotal) {
    this.capacidadTotal = capacidadTotal;
  }

  public long getCapacidadOcupada() {
    return capacidadOcupada;
  }

  public void setCapacidadOcupada(long capacidadOcupada) {
    this.capacidadOcupada = capacidadOcupada;
  }

  public long getCapacidadReservada() {
    return capacidadReservada;
  }

  public void setCapacidadReservada(long capacidadReservada) {
    this.capacidadReservada = capacidadReservada;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }

  public String getNombreInicial() {
    return nombreInicial;
  }

  public void setNombreInicial(String nombreInicial) {
    this.nombreInicial = nombreInicial;
  }

  public String getNombreFinal() {
    return nombreFinal;
  }

  public void setNombreFinal(String nombreFinal) {
    this.nombreFinal = nombreFinal;
  }

  public long getCapacidadDisponible() {
    return capacidadTotal - capacidadOcupada - capacidadReservada;
  }
}
