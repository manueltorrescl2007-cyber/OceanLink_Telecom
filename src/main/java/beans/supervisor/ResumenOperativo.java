package beans.supervisor;

public class ResumenOperativo {
  private int clientesActivos;
  private int serviciosActivos;
  private int solicitudesPendientes;
  private int totalLandingStations;

  public ResumenOperativo() {
  }

  public int getClientesActivos() {
    return clientesActivos;
  }

  public void setClientesActivos(int clientesActivos) {
    this.clientesActivos = clientesActivos;
  }

  public int getServiciosActivos() {
    return serviciosActivos;
  }

  public void setServiciosActivos(int serviciosActivos) {
    this.serviciosActivos = serviciosActivos;
  }

  public int getSolicitudesPendientes() {
    return solicitudesPendientes;
  }

  public void setSolicitudesPendientes(int solicitudesPendientes) {
    this.solicitudesPendientes = solicitudesPendientes;
  }

  public int getTotalLandingStations() {
    return totalLandingStations;
  }

  public void setTotalLandingStations(int totalLandingStations) {
    this.totalLandingStations = totalLandingStations;
  }
}
