package beans;

public class LandingStation {

  private int idLanding;
  private String nombre;
  private String pais;
  private String ciudad;
  private String estado;

  public int getIdLanding() {
    return idLanding;
  }

  public void setIdLanding(int idLanding) {
    this.idLanding = idLanding;
  }

  public String getNombre() {
    return nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
  }

  public String getPais() {
    return pais;
  }

  public void setPais(String pais) {
    this.pais = pais;
  }

  public String getCiudad() {
    return ciudad;
  }

  public void setCiudad(String ciudad) {
    this.ciudad = ciudad;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }
}
