package services;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailService {
  public void enviarCorreo(String destinatario,
                           String asunto,
                           String contenido) throws MessagingException {

    // Validacion de los datos recibidos
    if (destinatario == null || destinatario.isBlank()
        || asunto == null || asunto.isBlank()
        || contenido == null || contenido.isBlank())
     {
        throw new IllegalArgumentException("El destinatario, asunto y contenido son obligatorios.");
    }

    // Configuración SMTP
    String host = obtenerVariableObligatoria("SMTP_HOST");
    String puerto = obtenerVariableObligatoria("SMTP_PORT");
    String usuario = obtenerVariableObligatoria("SMTP_USER");
    String password = obtenerVariableObligatoria("SMTP_PASSWORD");
    String remitente = obtenerVariableObligatoria("SMTP_FROM");

    // Configuración de propiedad del servidor SMTP
    Properties propiedades = new Properties();

    propiedades.put("mail.smtp.host", host);
    propiedades.put("mail.smtp.port", puerto);
    propiedades.put("mail.smtp.auth", "true");
    propiedades.put("mail.smtp.starttls.enable", "true");

    // Crear sesion de jakarta mail

    Session sesion = Session.getInstance(propiedades, new Authenticator() {
      @Override
      protected PasswordAuthentication getPasswordAuthentication() {
        return new PasswordAuthentication(usuario, password);
      }
    });

    // Construccion del mensaje
    MimeMessage mensaje = new MimeMessage(sesion);

    mensaje.setFrom(new InternetAddress(remitente));

    mensaje.setRecipient(Message.RecipientType.TO,
                          new InternetAddress(destinatario, true));

    mensaje.setSubject(asunto, "UTF-8");
    mensaje.setText(contenido, "UTF-8");

    // Envio del mensaje
    Transport.send(mensaje);





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
