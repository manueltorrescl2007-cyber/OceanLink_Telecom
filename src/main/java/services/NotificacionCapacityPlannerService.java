package services;

import beans.Usuario;
import beans.capacityplanner.Cliente;
import beans.capacityplanner.Servicio;
import beans.capacityplanner.Solicitud;
import daos.capacityplanner.ClienteDao;
import daos.capacityplanner.ServicioDao;
import daos.capacityplanner.ServicioDao.AlertaUtilizacion;
import daos.capacityplanner.SolicitudDao;
import jakarta.mail.MessagingException;

import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificacionCapacityPlannerService {
  private static final Logger LOGGER =
    Logger.getLogger(NotificacionCapacityPlannerService.class.getName());

  private final EmailService emailService = new EmailService();
  private final ClienteDao clienteDao = new ClienteDao();
  private final SolicitudDao solicitudDao = new SolicitudDao();
  private final ServicioDao servicioDao = new ServicioDao();

  public void notificarSolicitud(int idSolicitud, String estado) {
    try {
      Solicitud solicitud = solicitudDao.obtenerSolicitud(idSolicitud);
      if (solicitud == null) {
        LOGGER.warning("No se encontró la solicitud " + idSolicitud + " para notificar.");
        return;
      }

      String codigo = "SOL-" + idSolicitud;
      String contenido = """
        Tu solicitud de capacidad ha pasado al estado %s.

        Solicitud: %s
        Origen: %s
        Destino: %s
        Capacidad solicitada: %d Gbps
        """.formatted(estado, codigo, solicitud.getNombreOrigen(),
        solicitud.getNombreDestino(), solicitud.getCapacidadSolicitada());

      enviar(solicitud.getIdCliente(), "OceanLink - " + codigo + " · " + estado, contenido);
    } catch (SQLException | MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo notificar la solicitud " + idSolicitud, e);
    }
  }

  public void notificarServicio(int idServicio, String evento) {
    try {
      Servicio servicio = servicioDao.obtenerServicio(idServicio);
      if (servicio == null) {
        LOGGER.warning("No se encontró el servicio " + idServicio + " para notificar.");
        return;
      }

      Solicitud solicitud = solicitudDao.obtenerSolicitud(servicio.getIdSolicitud());
      if (solicitud == null) {
        LOGGER.warning("No se encontró la solicitud del servicio " + idServicio + " para notificar.");
        return;
      }

      String codigo = "SER-" + idServicio;
      String contenido = """
        %s.

        Servicio: %s
        Solicitud: SOL-%d
        Ruta: %s
        Capacidad del servicio: %d Gbps
        """.formatted(evento, codigo, servicio.getIdSolicitud(), servicio.getNombreRuta(),
        servicio.getCapacidadAsignada());

      enviar(solicitud.getIdCliente(), "OceanLink - " + codigo + " · " + evento, contenido);
    } catch (SQLException | MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo notificar el servicio " + idServicio, e);
    }
  }

  public void notificarUtilizacion(Usuario usuario, int idServicio,
                                   List<AlertaUtilizacion> alertas) {
    if (usuario.getCorreo() == null || usuario.getCorreo().isBlank()) {
      LOGGER.warning("El usuario " + usuario.getIdUsuario() + " no tiene correo para alertas.");
      return;
    }

    String codigo = "SER-" + idServicio;
    StringBuilder contenido = new StringBuilder("Hola ")
      .append(usuario.getNombre())
      .append(",\n\nAl activar ").append(codigo)
      .append(" aumentó el nivel de utilización de estos segmentos:\n\n");

    for (AlertaUtilizacion alerta : alertas) {
      contenido.append(String.format(Locale.forLanguageTag("es-PE"),
        "%s: %.2f %% (%s) → %.2f %% (%s)%n",
        alerta.codigo(),
        alerta.ocupadaAntes() * 100.0 / alerta.total(), alerta.nivelAntes(),
        alerta.ocupadaDespues() * 100.0 / alerta.total(), alerta.nivelDespues()));
    }

    try {
      emailService.enviarCorreo(usuario.getCorreo(),
        "OceanLink - Alerta de utilización · " + codigo, contenido.toString());
    } catch (MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo enviar la alerta del servicio " + codigo, e);
    }
  }

  private void enviar(int idCliente, String asunto, String contenido)
    throws SQLException, MessagingException {
    Cliente cliente = clienteDao.obtenerCliente(idCliente);
    if (cliente == null || cliente.getCorreo() == null || cliente.getCorreo().isBlank()) {
      LOGGER.warning("El cliente " + idCliente + " no tiene un correo para notificar.");
      return;
    }

    emailService.enviarCorreo(cliente.getCorreo(), asunto,
      "Hola " + cliente.getNombre() + ",\n\n" + contenido
        + "\nEste es un mensaje automático de OceanLink.");
  }
}
