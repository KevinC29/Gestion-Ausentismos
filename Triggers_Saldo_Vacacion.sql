-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE TRIGGER tr_check_insert_saldo_vacacion_validacion BEFORE INSERT ON Saldo_Vacacion
FOR EACH ROW
BEGIN
	DECLARE s_count INT;

    IF LENGTH(NEW.pers_cedula) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
    END IF;
    
    SELECT COUNT(*) INTO v_count
	FROM Saldo_Vacacion
	WHERE pers_cedula = NEW.pers_cedula;
        
	IF v_count > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El personal ingresado ya tiene un registro de saldo de vacacion';
    END IF;
    
END //
DELIMITER ;


-- drop trigger tr_check_update_saldo_vacacion_validacion;
DELIMITER //
CREATE TRIGGER tr_check_update_saldo_vacacion_validacion BEFORE UPDATE ON Saldo_Vacacion
FOR EACH ROW
BEGIN
	SET NEW.sal_vac_dias_disponibles = NEW.sal_vac_dias_anio_actual + NEW.sal_vac_dias_un_anio + NEW.sal_vac_dias_dos_anios;

	IF NEW.sal_vac_dias_disponibles < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_dias_disponibles no puede ser menor a 0';
    END IF;
    
    IF NEW.pers_cedula != OLD.pers_cedula THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula no se puede modificar';
    END IF;
    
    IF NEW.sal_vac_remuneracion  < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_remuneracion no puede ser menor a 0';
    END IF;
    
    IF NEW.sal_vac_dias_tomados < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_dias_tomados no puede ser menor a 0';
    END IF;
    
    IF NEW.sal_vac_horas_tomadas  < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_horas_tomadas no puede ser menor a 0';
    END IF;
    
    IF NEW.sal_vac_dias_anio_actual  < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_dias_anio_actual no puede ser menor a 0';
    END IF;
    
    IF NEW.sal_vac_dias_un_anio  < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_dias_un_anio no puede ser menor a 0';
    END IF;
    
    IF NEW.sal_vac_dias_dos_anios  < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo sal_vac_dias_dos_anios no puede ser menor a 0';
    END IF;
    
    IF NEW.pers_cedula != OLD.pers_cedula THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula no se puede modificar';
    END IF;
    
    IF NEW.sal_vac_horas_tomadas > 24 THEN
		SET NEW.sal_vac_dias_tomados = NEW.sal_vac_dias_tomados + FLOOR(NEW.sal_vac_horas_tomadas / 24);
		SET NEW.sal_vac_horas_tomadas = NEW.sal_vac_horas_tomadas % 24;
	END IF;
    
    IF NEW.sal_vac_horas_disponibles < 0 AND  NEW.sal_vac_dias_anio_actual > 0 THEN
		SET NEW.sal_vac_dias_anio_actual = NEW.sal_vac_dias_anio_actual - 1;
		SET NEW.sal_vac_horas_disponibles = NEW.sal_vac_horas_disponibles + 24;
	ELSEIF NEW.sal_vac_horas_disponibles < 0 AND NEW.sal_vac_dias_un_anio > 0  THEN
		SET NEW.sal_vac_dias_un_anio = NEW.sal_vac_dias_un_anio - 1;
		SET NEW.sal_vac_horas_disponibles = NEW.sal_vac_horas_disponibles + 24;
	ELSEIF NEW.sal_vac_horas_disponibles < 0 AND NEW.sal_vac_dias_dos_anios > 0 THEN
		SET NEW.sal_vac_dias_dos_anios = NEW.sal_vac_dias_dos_anios - 1;
		SET NEW.sal_vac_horas_disponibles = NEW.sal_vac_horas_disponibles + 24;
    END IF;
END //
DELIMITER ;