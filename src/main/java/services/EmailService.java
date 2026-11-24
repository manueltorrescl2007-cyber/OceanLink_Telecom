package services;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.List;
import java.util.Properties;

public class EmailService {
  public void enviarCorreo(String destinatario,
                           String asunto,
                           String contenido) throws MessagingException {

    // Validacion de los datos recibidos
    if (destinatario == null || destinatario.isBlank()
      || asunto == null || asunto.isBlank()
      || contenido == null || contenido.isBlank()) {
      throw new IllegalArgumentException("El destinatario, asunto y contenido son obligatorios.");
    }

    Session sesion = crearSesion();
    String remitente = obtenerVariableObligatoria("SMTP_FROM");

    // Construccion del mensaje
    MimeMessage mensaje = new MimeMessage(sesion);
    mensaje.setFrom(new InternetAddress(remitente));
    mensaje.setRecipient(Message.RecipientType.TO, new InternetAddress(destinatario, true));
    mensaje.setSubject(asunto, "UTF-8");
    mensaje.setText(contenido, "UTF-8");

    // Envio del mensaje
    Transport.send(mensaje);
  }

  public void enviarCorreoMasivo(List<String> destinatarios,
                                 String asunto,
                                 String contenido) throws MessagingException {
    if (destinatarios == null || destinatarios.isEmpty()
      || asunto == null || asunto.isBlank()
      || contenido == null || contenido.isBlank()) {
      throw new IllegalArgumentException("Los destinatarios, asunto y contenido son obligatorios.");
    }

    Session sesion = crearSesion();
    String remitente = obtenerVariableObligatoria("SMTP_FROM");

    InternetAddress[] direcciones = new InternetAddress[destinatarios.size()];
    for (int i = 0; i < destinatarios.size(); i++) {
      direcciones[i] = new InternetAddress(destinatarios.get(i), true);
    }

    MimeMessage mensaje = new MimeMessage(sesion);
    mensaje.setFrom(new InternetAddress(remitente));
    mensaje.setRecipient(Message.RecipientType.TO, new InternetAddress(remitente));
    mensaje.setRecipients(Message.RecipientType.BCC, direcciones);
    mensaje.setSubject(asunto, "UTF-8");
    mensaje.setText(contenido, "UTF-8");

    Transport.send(mensaje);
  }

  private Session crearSesion() {
    String host = obtenerVariableObligatoria("SMTP_HOST");
    String puerto = obtenerVariableObligatoria("SMTP_PORT");
    String usuario = obtenerVariableObligatoria("SMTP_USER");
    String password = obtenerVariableObligatoria("SMTP_PASSWORD");

    Properties propiedades = new Properties();
    propiedades.put("mail.smtp.host", host);
    propiedades.put("mail.smtp.port", puerto);
    propiedades.put("mail.smtp.auth", "true");
    propiedades.put("mail.smtp.starttls.enable", "true");

    return Session.getInstance(propiedades, new Authenticator() {
      @Override
      protected PasswordAuthentication getPasswordAuthentication() {
        return new PasswordAuthentication(usuario, password);
      }
    });
  }

  // Creamos una funcion que obtiene una variable del entorno y comprueba que exista
  private String obtenerVariableObligatoria(String nombre) {
    String valor = System.getenv(nombre);

    if (valor == null || valor.isBlank()) {
      throw new IllegalArgumentException("No se ha configurado la variable del entorno");
    }

    return valor.trim();
  }
}
