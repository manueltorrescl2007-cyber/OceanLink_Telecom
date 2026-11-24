package services;

import beans.Usuario;
import jakarta.mail.MessagingException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificacionSupervisorService {

  private static final Logger LOGGER = Logger.getLogger(NotificacionSupervisorService.class.getName());
  private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  private final EmailService emailService = new EmailService();

  public void notificarDescargaReporte(Usuario supervisor,
                                       String nombreReporte,
                                       String resumenFiltros,
                                       int totalRegistros,
                                       String nombreArchivo) {
    try {
      if (supervisor == null || supervisor.getCorreo() == null || supervisor.getCorreo().isBlank()) {
        LOGGER.warning("No se pudo enviar la notificación de reporte: el supervisor en sesión no tiene un correo válido.");
        return;
      }

      String fechaEmision = LocalDateTime.now().format(FORMATO_FECHA);
      String asunto = "OceanLink - Reporte descargado: " + nombreReporte;

      StringBuilder contenido = new StringBuilder();
      contenido.append("Hola ").append(supervisor.getNombre()).append(",\n\n");
      contenido.append("Se ha generado y descargado un reporte operativo desde tu cuenta de Supervisor en OceanLink.\n\n");

      contenido.append("DETALLES DEL REPORTE EXPORTADO\n\n");
      contenido.append("Tipo de reporte: ").append(nombreReporte).append("\n");
      contenido.append("Archivo generado: ").append(nombreArchivo).append("\n");
      contenido.append("Criterios aplicados: ").append(resumenFiltros).append("\n");
      contenido.append("Total de registros incluidos: ").append(totalRegistros).append("\n");
      contenido.append("Fecha y hora de descarga: ").append(fechaEmision).append("\n\n");

      contenido.append("Este es un mensaje automático de OceanLink. ");
      contenido.append("Si no reconoces esta descarga, comunícate con administracion@oceanlink.com.\n");

      emailService.enviarCorreo(supervisor.getCorreo(), asunto, contenido.toString());
      LOGGER.info("Notificación de descarga de reporte enviada a " + supervisor.getCorreo());

    } catch (MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo enviar la notificación por correo del reporte descargado", e);
    }
  }
}
