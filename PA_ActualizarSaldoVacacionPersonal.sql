-- Utilizar la base de datos
USE gestion_personal;

-- drop procedure actualizar_saldo_vacaciones_personal;
DELIMITER //
CREATE PROCEDURE actualizar_saldo_vacaciones_personal(IN p_cedula INT, IN p_total_dias_trabajados INT, IN p_total_dias_vacaciones INT, IN p_periodo_actual YEAR)
BEGIN
   DECLARE dias_anio_actual INT;
   DECLARE dias_un_anio INT;
   DECLARE dias_dos_anios INT;
   DECLARE periodo INT;
   DECLARE remuneracion INT;

   SELECT sal_vac_dias_anio_actual, sal_vac_dias_un_anio, sal_vac_dias_dos_anios, sal_vac_remuneracion, sal_vac_periodo INTO dias_anio_actual, dias_un_anio, dias_dos_anios, remuneracion, periodo
   FROM Saldo_Vacacion
   WHERE pers_cedula = p_cedula;

   IF p_total_dias_trabajados = 360 THEN
         SET dias_anio_actual = p_total_dias_vacaciones;
         SET periodo = p_periodo_actual;
   END IF;
	
   IF p_total_dias_trabajados != 360 THEN
	 IF dias_un_anio = p_total_dias_vacaciones AND dias_dos_anios = p_total_dias_vacaciones THEN
	  SET remuneracion = remuneracion + 50;
      SET dias_dos_anios = dias_un_anio;
      SET dias_un_anio = dias_anio_actual;
      SET dias_anio_actual = p_total_dias_vacaciones;
     ELSE
      SET dias_dos_anios = dias_un_anio;
      SET dias_un_anio = dias_anio_actual;
      SET dias_anio_actual = p_total_dias_vacaciones;
      END IF;
   END IF;

   -- Actualizar Saldo_Vacacion
   UPDATE Saldo_Vacacion
   SET sal_vac_dias_anio_actual = dias_anio_actual,
       sal_vac_dias_un_anio = dias_un_anio,
       sal_vac_dias_dos_anios = dias_dos_anios,
       sal_vac_remuneracion = remuneracion,
       sal_vac_periodo = periodo
   WHERE pers_cedula = p_cedula;
END //
DELIMITER ;
