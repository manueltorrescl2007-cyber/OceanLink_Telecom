
package pruebas;

import jakarta.mail.MessagingException;
import services.EmailService;

public class EmailServicePrueba {

  public static void main(String[] args) {

    // Creamos una instancia del servicio de correo
    EmailService emailService = new EmailService();

    try {

      // Enviamos un correo de prueba
      emailService.enviarCorreo(
        "administracion@oceanlink.test",
        "Prueba de OceanLink",
        "¡Hola! Este es un correo de prueba "
          + "enviado desde el proyecto OceanLink."
      );

      System.out.println("Correo enviado correctamente a Mailtrap.");

    } catch (MessagingException | IllegalStateException
             | IllegalArgumentException e) {

      System.out.println("No se pudo enviar el correo.");
      e.printStackTrace();
    }
  }
}
