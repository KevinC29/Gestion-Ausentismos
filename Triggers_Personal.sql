-- Utilizar la base de datos
USE gestion_personal;

-- drop trigger tr_check_insert_personal_validacion;
-- drop trigger tr_check_update_personal_validacion;

DELIMITER //
CREATE TRIGGER tr_check_insert_personal_validacion BEFORE INSERT ON Personal
FOR EACH ROW
BEGIN
	DECLARE v_count INT;
    DECLARE v_cedula_jefe INT;
    DECLARE v_cedula_jefe_validacion BOOLEAN;
    
    IF NEW.pers_cedula_jefe IS NOT NULL THEN
		SET NEW.pers_cedula_jefe = NULL;
	END IF;
    
    -- Verificar si existe otro registro con el mismo em_dep_id y pers_cedula_jefe = NULL
	SELECT COUNT(*) INTO v_count
	FROM Personal
	WHERE em_dep_id = NEW.em_dep_id AND pers_cedula_jefe IS NULL;
    
    IF v_count = 0 THEN
		SET NEW.pers_cedula_jefe = NULL;
	ELSE
		SELECT pers_cedula INTO v_cedula_jefe
		FROM Personal
		WHERE em_dep_id = NEW.em_dep_id AND pers_cedula_jefe IS NULL;
		
        SET NEW.pers_cedula_jefe = v_cedula_jefe;
		-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo puede existir un jefe por departamento';
    END IF;
    
	IF LENGTH(NEW.pers_cedula) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
	END IF;
    
	IF LENGTH(NEW.pers_cedula_jefe) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula_jefe debe tener máximo 10 dígitos.';
	END IF;
        
	IF LENGTH(NEW.pers_numero_referencia_familiar ) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_numero_referencia_familiar  debe tener máximo 10 dígitos. ';
	END IF;
        
	IF LENGTH(NEW.pers_numero_celular) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_numero_celular debe tener máximo 10 dígitos ';
	END IF;
        
	IF NEW.pers_total_dias_trabajados <> 0 THEN
        SET NEW.pers_total_dias_trabajados = 0;
    END IF;
        
	IF NEW.pers_total_dias_vacaciones <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_total_dias_vacaciones debe ser mayor a 0.';
    END IF;
        
	IF NEW.pers_fecha_fin_contrato <= NEW.pers_fecha_inicio_contrato  THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_fecha_fin_contrato debe ser mayor a pers_fecha_inicio_contrato';
	END IF;
    
    IF NEW.pers_fecha_habilitacion_vacaciones <= NEW.pers_fecha_inicio_contrato THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_fecha_habilitación_vacaciones debe ser mayor a pers_fecha_inicio_contrato';
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_insert_personal_validacion_saldo_vacacion AFTER INSERT ON Personal
FOR EACH ROW
BEGIN    
	DECLARE periodo_actual YEAR;
	SET periodo_actual = YEAR(CURDATE());
    
    -- Verificar si ya existe un registro para el mismo período y persona en Saldo_Vacacion
    IF EXISTS (
        SELECT 1
        FROM Saldo_Vacacion
        WHERE pers_cedula = NEW.pers_cedula AND sal_vac_periodo = periodo_actual
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro en Saldo_Vacacion para el mismo período y persona.';
    END IF;
    
    INSERT INTO Saldo_Vacacion (pers_cedula, sal_vac_periodo)
    VALUES (NEW.pers_cedula, periodo_actual);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_update_personal_validacion BEFORE UPDATE ON Personal
FOR EACH ROW
BEGIN
	DECLARE v_count INT;
    DECLARE v_cedula_jefe INT;
    
    IF NEW.em_dep_id != OLD.em_dep_id THEN
		IF NEW.pers_cedula_jefe IS NOT NULL THEN
			SET NEW.pers_cedula_jefe = NULL;
		END IF;
		
		SELECT COUNT(*) INTO v_count
		FROM Personal
		WHERE em_dep_id = NEW.em_dep_id AND pers_cedula_jefe IS NULL;
		
		IF v_count = 0 THEN
			SET NEW.pers_cedula_jefe = NULL;
		ELSE
			SELECT pers_cedula INTO v_cedula_jefe
			FROM Personal
			WHERE em_dep_id = NEW.em_dep_id AND pers_cedula_jefe IS NULL;
			SET NEW.pers_cedula_jefe = v_cedula_jefe;
			-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo puede existir un jefe por departamento';
		END IF;
    END IF;
    
    IF LENGTH(NEW.pers_cedula) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
	END IF;
    
    IF NEW.pers_total_dias_trabajados < OLD.pers_total_dias_trabajados THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_total_dias_trabajados no puede ser menor al valor anterior';
	END IF;
        
	IF LENGTH(NEW.pers_cedula_jefe) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula_jefe debe tener máximo 10 dígitos.';
	END IF;
        
	IF LENGTH(NEW.pers_numero_referencia_familiar ) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_numero_referencia_familiar  debe tener máximo 10 dígitos. ';
	END IF;
        
	IF LENGTH(NEW.pers_numero_celular) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_numero_celular debe tener máximo 10 dígitos ';
	END IF;
        
	IF NEW.pers_total_dias_trabajados < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_total_dias_trabajados debe ser mayor a 0 ';
	END IF;
        
	IF NEW.pers_total_dias_vacaciones < 0 OR NEW.pers_total_dias_vacaciones = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_total_dias_vacaciones debe ser mayor a 0.';
	END IF;
        
	IF NEW.pers_fecha_fin_contrato <= NEW.pers_fecha_inicio_contrato  THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_fecha_fin_contrato debe ser mayor a pers_fecha_inicio_contrato';
	END IF;
    
    IF NEW.pers_fecha_habilitacion_vacaciones <= NEW.pers_fecha_inicio_contrato THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_fecha_habilitación_vacaciones debe ser mayor a pers_fecha_inicio_contrato';
    END IF;
END //
DELIMITER ;

-- Trigger que valida la cantidad de dias trabajos y actualiza su saldo de vacaciones
DELIMITER //
CREATE TRIGGER tr_check_update_personal_saldo_vacacion AFTER UPDATE ON Personal
FOR EACH ROW
BEGIN
   DECLARE cedula INT;
   DECLARE total_dias_trabajados INT;
   DECLARE total_dias_vacaciones INT;
   DECLARE periodo_actual YEAR;

   SELECT pers_cedula, pers_total_dias_trabajados, pers_total_dias_vacaciones INTO cedula, total_dias_trabajados, total_dias_vacaciones
   FROM Personal
   WHERE pers_cedula = NEW.pers_cedula;
   
   
   SET periodo_actual = YEAR(CURDATE());

   IF total_dias_trabajados % 360 = 0 THEN
      CALL actualizar_saldo_vacaciones_personal(cedula, total_dias_trabajados ,total_dias_vacaciones, periodo_actual);
   END IF;
END //
DELIMITER ;

