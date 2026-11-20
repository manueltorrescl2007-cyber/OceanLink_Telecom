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

            ArrayList<Segmento> segmentos = segmentoDao.listarSegmentosDeIncidencia(idIncidencia);
            ArrayList<Servicio> servicios = servicioDao.listarServiciosAfectados(idIncidencia);

            String asunto = "OceanLink - Incidencia " + incidencia.getCodigo() + " registrada";

            StringBuilder contenido = new StringBuilder();
            contenido.append("Hola ").append(usuario.getNombre()).append(",\n\n");
            contenido.append("Se registró correctamente la siguiente incidencia en OceanLink.\n\n");

            contenido.append("DETALLES DE LA INCIDENCIA\n\n");
            contenido.append("Código: ").append(incidencia.getCodigo()).append("\n");
            contenido.append("Título: ").append(incidencia.getTitulo()).append("\n");
            contenido.append("Severidad: ").append(incidencia.getSeveridadTexto()).append("\n");
            contenido.append("Estado: ").append(incidencia.getEstadoTexto()).append("\n");
            contenido.append("Fecha de registro: ").append(incidencia.getFechaRegistro()).append("\n");
            contenido.append("Descripción: ").append(incidencia.getDescripcion()).append("\n\n");

            contenido.append("SEGMENTOS AFECTADOS\n\n");
            for (Segmento s : segmentos) {
                contenido.append("- ").append(s.getCodigo()).append("\n");
            }

            contenido.append("\nSERVICIOS Y CLIENTES AFECTADOS\n\n");
            if (servicios.isEmpty()) {
                contenido.append("Ningún servicio activo pasa por los segmentos de esta incidencia.\n");
            } else {
                for (Servicio sv : servicios) {
                    contenido.append("- SRV-").append(sv.getIdServicio())
                             .append(" (").append(sv.getSolicitud().getCliente().getNombre()).append(")\n");
                }
            }

            contenido.append("\nEste es un mensaje automático de OceanLink. Si no reconoce esta operación, póngase en contacto con administracion@oceanlink.com");

            emailService.enviarCorreo(usuario.getCorreo(), asunto, contenido.toString());
            LOGGER.info("Notificación enviada para la incidencia " + incidencia.getCodigo());

        } catch (MessagingException | RuntimeException e) {
            LOGGER.log(Level.WARNING, "No se pudo enviar la notificación de la incidencia " + idIncidencia, e);
        }
    }
}
