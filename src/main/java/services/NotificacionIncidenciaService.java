package services;

import beans.Usuario;
import beans.networkoperator.Incidencia;
import beans.networkoperator.Segmento;
import beans.networkoperator.Servicio;
import daos.UsuarioDao;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.SegmentoDao;
import daos.networkoperator.ServicioDao;
import jakarta.mail.MessagingException;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificacionIncidenciaService {

    private static final Logger LOGGER = Logger.getLogger(NotificacionIncidenciaService.class.getName());

    private final EmailService emailService = new EmailService();
    private final UsuarioDao usuarioDao = new UsuarioDao();
    private final IncidenciaDao incidenciaDao = new IncidenciaDao();
    private final SegmentoDao segmentoDao = new SegmentoDao();
    private final ServicioDao servicioDao = new ServicioDao();

    public void notificarRegistro(int idIncidencia, int idUsuario) {
        try {
            Usuario usuario = usuarioDao.obtenerUsuario(idUsuario);
            if (usuario == null || usuario.getCorreo() == null || usuario.getCorreo().isBlank()) {
                LOGGER.warning("No se pudo notificar la incidencia " + idIncidencia + ": el usuario no tiene un correo válido.");
                return;
            }

            Incidencia incidencia = incidenciaDao.obtenerIncidencia(idIncidencia);
            if (incidencia == null) {
                LOGGER.warning("No se pudo notificar la incidencia " + idIncidencia + ": no existe.");
                return;
            }

            String asunto = "OceanLink - Incidencia " + incidencia.getCodigo() + " registrada";

            StringBuilder contenido = new StringBuilder();
            contenido.append("Hola ").append(usuario.getNombre()).append(",\n\n");
            contenido.append("Se registró correctamente la siguiente incidencia en OceanLink.\n\n");

            contenido.append(construirDetalle(incidencia, idIncidencia));
            contenido.append("\nEste es un mensaje automático de OceanLink.");

            emailService.enviarCorreo(usuario.getCorreo(), asunto, contenido.toString());
            LOGGER.info("Notificación enviada para la incidencia " + incidencia.getCodigo());

        } catch (MessagingException | RuntimeException e) {
            LOGGER.log(Level.WARNING, "No se pudo enviar la notificación de la incidencia " + idIncidencia, e);
        }
    }

    public void notificarCambioEstado(int idIncidencia, int idUsuario, String estadoAnterior) {
        try {
            Usuario usuario = usuarioDao.obtenerUsuario(idUsuario);
            if (usuario == null || usuario.getCorreo() == null || usuario.getCorreo().isBlank()) {
                LOGGER.warning("No se pudo notificar el cambio de estado de la incidencia " + idIncidencia + ": el usuario no tiene un correo válido.");
                return;
            }

            // Solo se notifica al Network Operator
            if (usuario.getRol() == null || usuario.getRol().getIdRol() != 4) {
                return;
            }

            Incidencia incidencia = incidenciaDao.obtenerIncidencia(idIncidencia);
            if (incidencia == null) {
                LOGGER.warning("No se pudo notificar el cambio de estado de la incidencia " + idIncidencia + ": no existe.");
                return;
            }

            // Para mostrar el estado anterior con tildes
            Incidencia anterior = new Incidencia();
            anterior.setEstado(estadoAnterior);

            String asunto = "OceanLink - Incidencia " + incidencia.getCodigo() + " actualizada";

            StringBuilder contenido = new StringBuilder();
            contenido.append("Hola ").append(usuario.getNombre()).append(",\n\n");
            contenido.append("Cambiaste el estado de la incidencia ").append(incidencia.getCodigo())
                     .append(" de \"").append(anterior.getEstadoTexto())
                     .append("\" a \"").append(incidencia.getEstadoTexto()).append("\".\n\n");
            contenido.append(construirDetalle(incidencia, idIncidencia));
            contenido.append("\nEste es un mensaje automático de OceanLink.");

            emailService.enviarCorreo(usuario.getCorreo(), asunto, contenido.toString());
            LOGGER.info("Notificación de cambio de estado enviada para la incidencia " + incidencia.getCodigo());

        } catch (MessagingException | RuntimeException e) {
            LOGGER.log(Level.WARNING, "No se pudo enviar la notificación de cambio de estado de la incidencia " + idIncidencia, e);
        }
    }

    // Arma los datos de la incidencia, segmentos y servicios afectados
    private String construirDetalle(Incidencia incidencia, int idIncidencia) {
        ArrayList<Segmento> segmentos = segmentoDao.listarSegmentosDeIncidencia(idIncidencia);
        ArrayList<Servicio> servicios = servicioDao.listarServiciosAfectados(idIncidencia);

        StringBuilder detalle = new StringBuilder();
        detalle.append("DETALLES DE LA INCIDENCIA\n\n");
        detalle.append("Código: ").append(incidencia.getCodigo()).append("\n");
        detalle.append("Título: ").append(incidencia.getTitulo()).append("\n");
        detalle.append("Severidad: ").append(incidencia.getSeveridadTexto()).append("\n");
        detalle.append("Estado: ").append(incidencia.getEstadoTexto()).append("\n");
        detalle.append("Fecha de registro: ").append(incidencia.getFechaRegistro()).append("\n");
        detalle.append("Descripción: ").append(incidencia.getDescripcion()).append("\n\n");

        detalle.append("SEGMENTOS AFECTADOS\n\n");
        for (Segmento s : segmentos) {
            detalle.append("- ").append(s.getCodigo()).append("\n");
        }

        detalle.append("\nSERVICIOS Y CLIENTES AFECTADOS\n\n");
        if (servicios.isEmpty()) {
            detalle.append("Ningún servicio activo pasa por los segmentos de esta incidencia.\n");
        } else {
            for (Servicio sv : servicios) {
                detalle.append("- SRV-").append(sv.getIdServicio())
                         .append(" (").append(sv.getSolicitud().getCliente().getNombre()).append(")\n");
            }
        }
        return detalle.toString();
    }
}
