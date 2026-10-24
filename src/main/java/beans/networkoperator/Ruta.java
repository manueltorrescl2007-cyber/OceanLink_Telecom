package beans.networkoperator;

public class Ruta {
  private int idRuta;
  private String nombre;
  private LandingStation landingOrigen;
  private LandingStation landingDestino;
  private String estado;

  public int getIdRuta() { return idRuta; }
  public void setIdRuta(int idRuta) { this.idRuta = idRuta; }
  public String getNombre() { return nombre; }
  public void setNombre(String nombre) { this.nombre = nombre; }
  public LandingStation getLandingOrigen() { return landingOrigen; }
  public void setLandingOrigen(LandingStation landingOrigen) { this.landingOrigen = landingOrigen; }
  public LandingStation getLandingDestino() { return landingDestino; }
  public void setLandingDestino(LandingStation landingDestino) { this.landingDestino = landingDestino; }
  public String getEstado() { return estado; }
  public void setEstado(String estado) { this.estado = estado; }
}
