package utils;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class PasswordUtil {

  private static final String PREFIJO = "PBKDF2$";
  private static final int ITERACIONES = 210_000;
  private static final int LONGITUD_CLAVE = 256;
  private static final int LONGITUD_SALT = 16;

  private static final SecureRandom RANDOM = new SecureRandom();

  private PasswordUtil() {
  }

  public static String hashPassword(String password) {

    if (password == null || password.isEmpty()) {
      throw new IllegalArgumentException(
        "La contraseña no puede estar vacía."
      );
    }

    byte[] salt = new byte[LONGITUD_SALT];
    RANDOM.nextBytes(salt);

    byte[] hash = derivarHash(
      password.toCharArray(),
      salt,
      ITERACIONES
    );

    return PREFIJO
      + ITERACIONES + "$"
      + Base64.getEncoder().encodeToString(salt) + "$"
      + Base64.getEncoder().encodeToString(hash);
  }

  public static boolean verificarPassword(
    String password,
    String guardada
  ) {

    if (password == null || guardada == null) {
      return false;
    }

    // Compatibilidad temporal con las contraseñas antiguas
    // que se guardaron directamente en MySQL.
    if (!esHashAlmacenado(guardada)) {
      return MessageDigest.isEqual(
        password.getBytes(StandardCharsets.UTF_8),
        guardada.getBytes(StandardCharsets.UTF_8)
      );
    }

    String[] partes = guardada.split("\\$", -1);

    if (partes.length != 4 || !"PBKDF2".equals(partes[0])) {
      return false;
    }

    try {
      int iteraciones = Integer.parseInt(partes[1]);

      // Evita aceptar parámetros de hash fuera de los límites
      // esperados por esta implementación.
      if (iteraciones < 10_000 || iteraciones > 1_000_000) {
        return false;
      }

      byte[] salt = Base64.getDecoder().decode(partes[2]);
      byte[] hashEsperado =
        Base64.getDecoder().decode(partes[3]);

      byte[] hashCalculado = derivarHash(
        password.toCharArray(),
        salt,
        iteraciones
      );

      return MessageDigest.isEqual(
        hashEsperado,
        hashCalculado
      );

    } catch (IllegalArgumentException e) {
      return false;
    }
  }

  public static boolean esHashAlmacenado(String valor) {
    return valor != null && valor.startsWith(PREFIJO);
  }

  private static byte[] derivarHash(
    char[] password,
    byte[] salt,
    int iteraciones
  ) {

    PBEKeySpec especificacion = new PBEKeySpec(
      password,
      salt,
      iteraciones,
      LONGITUD_CLAVE
    );

    try {
      SecretKeyFactory fabrica =
        SecretKeyFactory.getInstance(
          "PBKDF2WithHmacSHA256"
        );

      return fabrica.generateSecret(especificacion).getEncoded();

    } catch (GeneralSecurityException e) {
      throw new IllegalStateException(
        "No se pudo procesar la contraseña.",
        e
      );

    } finally {
      especificacion.clearPassword();
    }
  }
}
