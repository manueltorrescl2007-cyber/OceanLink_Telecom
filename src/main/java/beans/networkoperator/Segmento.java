package beans.networkoperator;

public class Segmento {
  private int idSegmento;
  private String codigo;
  private LandingStation landingInicial;
  private LandingStation landingFinal;
  private int capacidadTotal;
  private int capacidadOcupada;
  private int capacidadReservada;
  private String estado;

  public int getIdSegmento() { return idSegmento; }
  public void setIdSegmento(int idSegmento) { this.idSegmento = idSegmento; }
  public String getCodigo() { return codigo; }
  public void setCodigo(String codigo) { this.codigo = codigo; }
  public LandingStation getLandingInicial() { return landingInicial; }
  public void setLandingInicial(LandingStation landingInicial) { this.landingInicial = landingInicial; }
  public LandingStation getLandingFinal() { return landingFinal; }
  public void setLandingFinal(LandingStation landingFinal) { this.landingFinal = landingFinal; }
  public int getCapacidadTotal() { return capacidadTotal; }
  public void setCapacidadTotal(int capacidadTotal) { this.capacidadTotal = capacidadTotal; }
  public int getCapacidadOcupada() { return capacidadOcupada; }
  public void setCapacidadOcupada(int capacidadOcupada) { this.capacidadOcupada = capacidadOcupada; }
  public int getCapacidadReservada() { return capacidadReservada; }
  public void setCapacidadReservada(int capacidadReservada) { this.capacidadReservada = capacidadReservada; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }

  public int getCapacidadDisponible() {
    return capacidadTotal - capacidadOcupada - capacidadReservada;
  }

  public int getPorcentajeUso() {
    if (capacidadTotal == 0) {
      return 0;
    }
    return (int) Math.round(porcentajeExacto());
  }

  // Uso = ocupada + reservada: la capacidad reservada ya no está disponible para otros servicios
  private double porcentajeExacto() {
    return capacidadTotal == 0 ? 0 : (capacidadOcupada + capacidadReservada) * 100.0 / capacidadTotal;
  }

  // El nivel se decide con el porcentaje exacto (sin redondear), igual que en las demás pantallas
  public String getNivelUso() {
    double uso = porcentajeExacto();
    if (uso > 95) {
      return "critica";
    } else if (uso >= 80) {
      return "alta";
    }
    return "normal";
  }
}
