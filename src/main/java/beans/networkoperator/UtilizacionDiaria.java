package beans.networkoperator;

public class UtilizacionDiaria {
  private String fecha;
  private int capacidadTotal;
  private int capacidadOcupada;
  private int capacidadReservada;

  public String getFecha() { return fecha; }
  public void setFecha(String fecha) { this.fecha = fecha; }
  public int getCapacidadTotal() { return capacidadTotal; }
  public void setCapacidadTotal(int capacidadTotal) { this.capacidadTotal = capacidadTotal; }
  public int getCapacidadOcupada() { return capacidadOcupada; }
  public void setCapacidadOcupada(int capacidadOcupada) { this.capacidadOcupada = capacidadOcupada; }
  public int getCapacidadReservada() { return capacidadReservada; }
  public void setCapacidadReservada(int capacidadReservada) { this.capacidadReservada = capacidadReservada; }

  public int getCapacidadDisponible() {
    return capacidadTotal - capacidadOcupada - capacidadReservada;
  }

  public int getPorcentajeOcupada() {
    return capacidadTotal == 0 ? 0 : (int) Math.round(capacidadOcupada * 100.0 / capacidadTotal);
  }

  public int getPorcentajeReservada() {
    return capacidadTotal == 0 ? 0 : (int) Math.round(capacidadReservada * 100.0 / capacidadTotal);
  }

  public int getPorcentajeDisponible() {
    return capacidadTotal == 0 ? 0 : 100 - getPorcentajeOcupada() - getPorcentajeReservada();
  }
}
