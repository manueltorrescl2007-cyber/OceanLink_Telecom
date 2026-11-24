package services;

import beans.Rol;
import beans.Usuario;
import daos.RolDao;
import daos.UsuarioDao;
import jakarta.mail.MessagingException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificacionAdminService {

  private static final Logger LOGGER = Logger.getLogger(NotificacionAdminService.class.getName());
  private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  private final EmailService emailService = new EmailService();
  private final UsuarioDao usuarioDao = new UsuarioDao();
  private final RolDao rolDao = new RolDao();

  public void notificarCreacionUsuario(Usuario nuevoUsuario, String contrasenaPlana, Usuario adminEjecutor) {
    try {
      if (nuevoUsuario == null || nuevoUsuario.getCorreo() == null || nuevoUsuario.getCorreo().isBlank()) {
        LOGGER.warning("No se pudo enviar correo de bienvenida: usuario sin correo válido.");
        return;
      }

      String nombreRol = obtenerNombreRol(nuevoUsuario.getRol());
      String fechaHora = LocalDateTime.now().format(FORMATO_FECHA);
      String ejecutadoPor = (adminEjecutor != null && adminEjecutor.getNombre() != null)
        ? adminEjecutor.getNombre()
        : "Administrador de OceanLink";

      String asunto = "OceanLink - Bienvenido(a), credenciales de acceso";

      StringBuilder contenido = new StringBuilder();
      contenido.append("Hola ").append(nuevoUsuario.getNombre()).append(",\n\n");
      contenido.append("Tu cuenta de usuario ha sido creada en la plataforma OceanLink Telecom.\n\n");

      contenido.append("DATOS DE TU CUENTA\n\n");
      contenido.append("Nombre: ").append(nuevoUsuario.getNombre()).append("\n");
      contenido.append("Correo (usuario): ").append(nuevoUsuario.getCorreo()).append("\n");
      contenido.append("Contraseña inicial: ").append(contrasenaPlana).append("\n");
      contenido.append("Rol asignado: ").append(nombreRol).append("\n");
      contenido.append("Fecha de registro: ").append(fechaHora).append("\n");
      contenido.append("Registrado por: ").append(ejecutadoPor).append("\n\n");

      contenido.append("Por seguridad, te recomendamos cambiar tu contraseña desde tu perfil al iniciar sesión.\n");
      contenido.append("Este es un mensaje automático de OceanLink.");

      emailService.enviarCorreo(nuevoUsuario.getCorreo(), asunto, contenido.toString());
      LOGGER.info("Correo de credenciales enviado a " + nuevoUsuario.getCorreo());

    } catch (MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo enviar el correo de creación de usuario", e);
    }
  }

  public void notificarCambioInfraestructura(String tipoElemento,
                                             String accionRealizada,
                                             String identificadorElemento,
                                             String detalleCambio,
                                             boolean esAlertaCritica,
                                             Usuario adminEjecutor) {
    try {
      ArrayList<Usuario> usuariosActivos = usuarioDao.listarUsuarios(-1, "activo");
      if (usuariosActivos == null || usuariosActivos.isEmpty()) {
        return;
      }

      List<String> destinatarios = new ArrayList<>();
      for (Usuario u : usuariosActivos) {
        if (u.getCorreo() == null || u.getCorreo().isBlank() || u.getRol() == null) {
          continue;
        }
        int idRol = u.getRol().getIdRol();
        boolean debeNotificarse = esAlertaCritica || idRol == 1 || idRol == 2;
        if (debeNotificarse) {
          destinatarios.add(u.getCorreo().trim());
        }
      }

      if (destinatarios.isEmpty()) {
        return;
      }

      String fechaHora = LocalDateTime.now().format(FORMATO_FECHA);
      String ejecutadoPor = (adminEjecutor != null && adminEjecutor.getNombre() != null)
        ? adminEjecutor.getNombre()
        : "Administrador de OceanLink";

      String prefijo = esAlertaCritica ? "[ALERTA INFRAESTRUCTURA] " : "[OceanLink Infraestructura] ";
      String asunto = prefijo + tipoElemento + " " + identificadorElemento + " - " + accionRealizada;

      StringBuilder contenido = new StringBuilder();
      contenido.append("Estimado equipo de OceanLink,\n\n");
      contenido.append("Se ha registrado una actualización en la infraestructura de red.\n\n");
      contenido.append("DETALLES DEL CAMBIO\n\n");
      contenido.append("Elemento: ").append(tipoElemento).append("\n");
      contenido.append("Identificador: ").append(identificadorElemento).append("\n");
      contenido.append("Acción: ").append(accionRealizada).append("\n");
      contenido.append("Detalle: ").append(detalleCambio).append("\n");
      contenido.append("Realizado por: ").append(ejecutadoPor).append("\n");
      contenido.append("Fecha y hora: ").append(fechaHora).append("\n\n");
      contenido.append("Este es un mensaje automático de OceanLink.");

      emailService.enviarCorreoMasivo(destinatarios, asunto, contenido.toString());
      LOGGER.info("Notificación de infraestructura enviada en BCC a " + destinatarios.size() + " usuario(s) para " + identificadorElemento);

    } catch (MessagingException | RuntimeException e) {
      LOGGER.log(Level.WARNING, "No se pudo enviar la notificación de cambio en infraestructura", e);
    }
  }

  private String obtenerNombreRol(Rol rol) {
    if (rol == null) {
      return "No especificado";
    }
    if (rol.getNombre() != null && !rol.getNombre().isBlank()) {
      return rol.getNombre();
    }
    ArrayList<Rol> roles = rolDao.listarRoles();
    if (roles != null) {
      for (Rol r : roles) {
        if (r.getIdRol() == rol.getIdRol()) {
          return r.getNombre();
        }
      }
    }
    return "Rol ID " + rol.getIdRol();
  }
}
