package beans;
import java.util.ArrayList;

public class Ruta {

  private int idRuta;
  private String nombre;
  private int idLandingOrigen;
  private int idLandingDestino;
  private String estado;

  private String nombreOrigen;
  private String nombreDestino;
  private ArrayList<Segmento> segmentos = new ArrayList<>();

  public int getIdRuta() {
    return idRuta;
  }

  public void setIdRuta(int idRuta) {
    this.idRuta = idRuta;
  }

  public String getNombre() {
    return nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
  }

  public int getIdLandingOrigen() {
    return idLandingOrigen;
  }

  public void setIdLandingOrigen(int idLandingOrigen) {
    this.idLandingOrigen = idLandingOrigen;
  }

  public int getIdLandingDestino() {
    return idLandingDestino;
  }

  public void setIdLandingDestino(int idLandingDestino) {
    this.idLandingDestino = idLandingDestino;
  }

  public String getEstado() {
    return estado;
  }

  public void setEstado(String estado) {
    this.estado = estado;
  }

  public String getNombreOrigen() {
    return nombreOrigen;
  }

  public void setNombreOrigen(String nombreOrigen) {
    this.nombreOrigen = nombreOrigen;
  }

  public String getNombreDestino() {
    return nombreDestino;
  }

  public void setNombreDestino(String nombreDestino) {
    this.nombreDestino = nombreDestino;
  }
  public ArrayList<Segmento> getSegmentos() {
    return segmentos;
  }

  public void setSegmentos(ArrayList<Segmento> segmentos) {
    this.segmentos = segmentos;
  }

  // La capacidad disponible de la ruta es la menor de sus segmentos.
  public long getCapacidadDisponible() {

    if (segmentos.isEmpty()) {
      return 0;
    }

    long menor = segmentos.get(0).getCapacidadDisponible();

    for (Segmento segmento : segmentos) {
      if (segmento.getCapacidadDisponible() < menor) {
        menor = segmento.getCapacidadDisponible();
      }
    }

    return Math.max(0, menor);
  }
}
