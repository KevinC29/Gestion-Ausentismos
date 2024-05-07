-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE TRIGGER tr_check_update_login_sesion_validacion BEFORE UPDATE ON login_sistema
FOR EACH ROW
BEGIN
IF NEW.log_sis_usuario != OLD.log_sis_usuario OR NEW.log_sis_fecha_hora_ingreso != OLD.log_sis_fecha_hora_ingreso OR NEW.log_sis_id_sesion != OLD.log_sis_id_sesion THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro no se puede modificar';
END IF;
END //
DELIMITER ;