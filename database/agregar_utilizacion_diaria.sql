-- =====================================================================
-- OceanLink - Agregar la tabla utilizacion_diaria a una BD que YA existe
-- (no borra ni modifica ninguna tabla; se puede ejecutar más de una vez)
--
-- Después de ejecutarlo, en Workbench: Database > Reverse Engineer...
-- para que el modelo (diagrama) incluya la tabla nueva.
--
-- Para DESHACER este cambio:   DROP TABLE IF EXISTS ocean_link.utilizacion_diaria;
-- =====================================================================
USE ocean_link;

CREATE TABLE IF NOT EXISTS `utilizacion_diaria` (
  `fecha` DATE NOT NULL,
  `capacidad_total` INT UNSIGNED NOT NULL,
  `capacidad_ocupada` INT UNSIGNED NOT NULL DEFAULT '0',
  `capacidad_reservada` INT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`fecha`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------
-- (OPCIONAL) Datos de prueba para la demo: llena los días ANTERIORES de esta semana
-- (desde el lunes hasta ayer) usando la capacidad total actual de los segmentos.
-- El día de hoy NO se llena: lo guarda la página al abrir "Estado de la red".
-- INSERT IGNORE: si un día ya tiene datos reales, no se toca.
-- ---------------------------------------------------------------------
INSERT IGNORE INTO utilizacion_diaria (fecha, capacidad_total, capacidad_ocupada, capacidad_reservada)
SELECT DATE_SUB(CURDATE(), INTERVAL d.dias_atras DAY),
       t.total,
       ROUND(t.total * d.pct_ocupada / 100),
       ROUND(t.total * d.pct_reservada / 100)
FROM (SELECT 1 AS dias_atras, 58 AS pct_ocupada, 7 AS pct_reservada
      UNION ALL SELECT 2, 55, 8
      UNION ALL SELECT 3, 57, 6
      UNION ALL SELECT 4, 52, 9
      UNION ALL SELECT 5, 50, 8
      UNION ALL SELECT 6, 47, 10) d
CROSS JOIN (SELECT SUM(capacidad_total) AS total FROM segmentos) t
WHERE d.dias_atras <= WEEKDAY(CURDATE());   -- WEEKDAY: lunes = 0 ... domingo = 6 (solo días de ESTA semana)

SELECT * FROM utilizacion_diaria ORDER BY fecha;
