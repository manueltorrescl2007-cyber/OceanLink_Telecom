
package services;

import beans.Usuario;
import beans.maintenance.Mantenimiento;
import daos.UsuarioDao;
import jakarta.mail.MessagingException;

import java.time.format.DateTimeFormatter;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificacionService {

  // Declaramos emailService se comunicara con mailtrap
  private final EmailService emailService = new EmailService();

  // Declaramos usuario Dao para obtener la información del usuario mediante MySQL
  private final UsuarioDao usuarioDao = new UsuarioDao();

  private static final Logger LOGGER =
    Logger.getLogger(NotificacionService.class.getName());

  private static final DateTimeFormatter FORMATO_FECHA =
    DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  public void notificarCreacion(Mantenimiento mantenimiento) {

    try {

      // intentamos recuperar el id del responsable del mantenimiento
      Usuario responsable =
        usuarioDao.obtenerUsuario(mantenimiento.getIdUsuario());


      // Identificamos que el responsable no sea nulo (exista)
      if (responsable == null
        || responsable.getCorreo() == null
        || responsable.getCorreo().isBlank()) {

        LOGGER.warning(
          "No se pudo notificar la creación: "
            + "el responsable no tiene un correo válido."
        );
        return;
      }

      // Asunto del correo
      String asunto =
        "OceanLink - Nuevo mantenimiento registrado";

      // Declaramos Stringbuilder para poder construir el correo mediante multiples fragmentos de texto
      StringBuilder contenido = new StringBuilder();

      contenido.append("Hola ")
        .append(responsable.getNombre())
        .append(",\n\n");

      contenido.append(
        "Se ha registrado un nuevo mantenimiento a tu cargo"
          + "en OceanLink.\n\n"
      );

      // Imprimimos en el correo la información del mantenimiento

      contenido.append("DETALLES DEL MANTENIMIENTO\n\n");

      contenido.append("Código: ")
        .append(mantenimiento.getIdMantenimiento())
        .append("\n");

      contenido.append("Tipo: ")
        .append(mantenimiento.getTipo())
        .append("\n");

      contenido.append("Prioridad: ")
        .append(mantenimiento.getPrioridad())
        .append("\n");

      contenido.append("Segmento: ")
        .append(mantenimiento.getIdSegmento())
        .append("\n");

      contenido.append("Fecha de inicio: ")
        .append(mantenimiento.getFechaInicio()
          .format(FORMATO_FECHA))
        .append("\n");

      contenido.append("Fecha de fin: ")
        .append(mantenimiento.getFechaFin()
          .format(FORMATO_FECHA))
        .append("\n");

      contenido.append("Descripción: ")
        .append(mantenimiento.getDescripcionGeneral())
        .append("\n\n");

      contenido.append(
        "Este es un mensaje automático de OceanLink." + " Si no reconoce esta operación, pongase en contacto con el servicio de administracion@oceanlink.com\n"
        + "\nRecuerde no compartir sus credenciales con otros usuarios");

      // 4. Enviar el correo
      emailService.enviarCorreo(
        responsable.getCorreo(),
        asunto,
        contenido.toString()
      );

      LOGGER.info(
        "Notificación de creación enviada a Mailtrap "
          + "para el mantenimiento "
          + mantenimiento.getIdMantenimiento()
      );


      // Si mailtrap esta caido temporalmente entonces se registra el error y no lo envia al servlet
    } catch (MessagingException | RuntimeException e) {

      LOGGER.log(
        Level.WARNING,
        "No se pudo enviar la notificación de creación "
          + "del mantenimiento "
          + mantenimiento.getIdMantenimiento(),
        e
      );
    }
  }

  // AHORA NOTIFICAMOS UNA REPROGRAMACIÓN, PARA ESO NECESITAMOS EL MANTENIMIENTO ANTERIOR Y EL REPROGRAMADO
  public void notificarReprogramacion(
    Mantenimiento anterior,
    Mantenimiento actualizado
  ) {

    try {

      // Identificamos al responsable
      Usuario responsable =
        usuarioDao.obtenerUsuario(anterior.getIdUsuario());

      if (responsable == null
        || responsable.getCorreo() == null
        || responsable.getCorreo().isBlank()) {

        LOGGER.warning(
          "No se pudo notificar la reprogramación: "
            + "responsable sin correo válido."
        );
        return;
      }

      // Preparar el asunto
      String asunto =
        "OceanLink - Mantenimiento reprogramado";

      // Construccón del mensaje
      StringBuilder contenido = new StringBuilder();

      contenido.append("Estimado(a) ")
        .append(responsable.getNombre())
        .append(",\n\n");

      contenido.append(
        "Le informamos que se han modificado "
          + "las fechas de un mantenimiento asignado a su cargo.\n\n"
      );

      contenido.append("DETALLES DEL MANTENIMIENTO\n");

      contenido.append("Código: ")
        .append(actualizado.getIdMantenimiento())
        .append("\n\n");

      contenido.append("FECHAS ANTERIORES\n");

      contenido.append("Inicio: ")
        .append(anterior.getFechaInicio().format(FORMATO_FECHA))
        .append("\n");

      contenido.append("Fin: ")
        .append(anterior.getFechaFin().format(FORMATO_FECHA))
        .append("\n\n");

      contenido.append("FECHAS ACTUALIZADAS\n");

      contenido.append("Inicio: ")
        .append(actualizado.getFechaInicio().format(FORMATO_FECHA))
        .append("\n");

      contenido.append("Fin: ")
        .append(actualizado.getFechaFin().format(FORMATO_FECHA))
        .append("\n\n");

      contenido.append(
        "Este es un mensaje automático de OceanLink. Si no reconoce esta operación, pongase en contacto con administracion@oceanlink.com" +
          "\n\nRecuerde no compartir sus credenciales con otros usuarios"
      );

      // 4. Enviar el correo
      emailService.enviarCorreo(
        responsable.getCorreo(),
        asunto,
        contenido.toString()
      );

      LOGGER.info(
        "Notificación de reprogramación enviada para "
          + "el mantenimiento "
          + actualizado.getIdMantenimiento()
      );


      // En caso mailtrap este caido, no enviamos nada al servlet
    } catch (MessagingException | RuntimeException e) {

      LOGGER.log(
        Level.WARNING,
        "No se pudo enviar la notificación de reprogramación "
          + "del mantenimiento "
          + actualizado.getIdMantenimiento(),
        e
      );
    }
  }



  public void notificarCancelacion(Mantenimiento mantenimiento) {

    try {

      // Recuperar al responsable
      Usuario responsable =
        usuarioDao.obtenerUsuario(mantenimiento.getIdUsuario());

      if (responsable == null
        || responsable.getCorreo() == null
        || responsable.getCorreo().isBlank()) {

        LOGGER.warning(
          "No se pudo notificar la cancelación: "
            + "responsable sin correo válido."
        );
        return;
      }

      // Preparar el asunto
      String asunto =
        "OceanLink - Mantenimiento cancelado";

      // Construir el contenido
      StringBuilder contenido = new StringBuilder();

      contenido.append("Estimado(a) ")
        .append(responsable.getNombre())
        .append(",\n\n");

      contenido.append(
        "Le informamos que su solicitud de cancelación del siguiente mantenimiento ha sido ejecutada.\n\n"
      );

      contenido.append("DETALLES DEL MANTENIMIENTO\n\n");

      contenido.append("Código: ")
        .append(mantenimiento.getIdMantenimiento())
        .append("\n");

      contenido.append("Tipo: ")
        .append(mantenimiento.getTipo())
        .append("\n");

      contenido.append("Prioridad: ")
        .append(mantenimiento.getPrioridad())
        .append("\n");

      contenido.append("Segmento: ")
        .append(mantenimiento.getIdSegmento())
        .append("\n");

      contenido.append("Fecha de inicio programada: ")
        .append(mantenimiento.getFechaInicio().format(FORMATO_FECHA))
        .append("\n");

      contenido.append("Fecha de fin programada: ")
        .append(mantenimiento.getFechaFin().format(FORMATO_FECHA))
        .append("\n\n");

      contenido.append(
        "El mantenimiento ya no se encuentra programado "
          + "para su ejecución.\n\n"
      );

      contenido.append(
        "Este es un mensaje automático de OceanLink. Si no reconoce esta operación, pongase en contacto con administracion@oceanlink.com"
        + "\n\nRecuerde no compartir sus credenciales con otros usuarios."
      );

      // Enviar el correo
      emailService.enviarCorreo(
        responsable.getCorreo(),
        asunto,
        contenido.toString()
      );

      LOGGER.info(
        "Notificación de cancelación enviada para "
          + "el mantenimiento "
          + mantenimiento.getIdMantenimiento()
      );

    } catch (MessagingException | RuntimeException e) {

      LOGGER.log(
        Level.WARNING,
        "No se pudo enviar la notificación de cancelación "
          + "del mantenimiento "
          + mantenimiento.getIdMantenimiento(),
        e
      );
    }
  }

}
