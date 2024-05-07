-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE TRIGGER tr_check_insert_planificacion_vacacion_validacion BEFORE INSERT ON Planificacion_Vacacion
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.pers_cedula) > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
    END IF;

    -- Validar campo pla_vac_numero_oficio
    IF CHAR_LENGTH(NEW.pla_vac_numero_oficio) > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pla_vac_numero_oficio debe tener máximo 5 dígitos.';
    END IF;
	
    IF NEW.pla_vac_usuario_beneficiario != NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usted no puede asignar otros usuarios beneficiarios';
    END IF;
    
    IF NEW.pla_vac_estado_planificacion != 'Pendiente' THEN
		SET NEW.pla_vac_estado_planificacion = 'Pendiente';
    END IF;
    
    -- Asignar valor a campo pla_vac_usuario_beneficiario
    SET NEW.pla_vac_usuario_beneficiario = (
        SELECT pers_nombre
        FROM Personal
        WHERE pers_cedula = NEW.pers_cedula
    );
    
    SET NEW.pla_vac_fecha_creacion = NOW();
    
    -- Calcular valor para campo pla_vac_fecha_hasta
    SET NEW.pla_vac_fecha_hasta = NEW.pla_vac_fecha_desde + INTERVAL NEW.pla_vac_dias_tomados DAY;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_update_planificacion_vacacion_validacion BEFORE UPDATE ON Planificacion_Vacacion
FOR EACH ROW
BEGIN
    IF NEW.pers_cedula != OLD.pers_cedula THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula no se puede modificar';
    END IF;

    -- Validar campo pla_vac_numero_oficio
    IF NEW.pla_vac_numero_oficio != OLD.pla_vac_numero_oficio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pla_vac_numero_oficio no se puede modificar';
    END IF;
    
    IF NEW.pla_vac_usuario_beneficiario != OLD.pla_vac_usuario_beneficiario THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usted no puede modificar el usuario beneficiario';
    END IF;
    
    IF NEW.pla_vac_fecha_creacion != OLD.pla_vac_fecha_creacion THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo pla_vac_fecha_creacion';
    END IF;
    
    IF NEW.pla_vac_estado_planificacion = 'Pendiente' AND OLD.pla_vac_estado_planificacion = 'Finalizado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo pla_vac_estado_planificacion a pendiente una vez finalizado';
    END IF;
    
    IF NEW.pla_vac_estado_planificacion = 'Pendiente' AND OLD.pla_vac_estado_planificacion = 'En curso' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo pla_vac_estado_planificacion a pendiente una vez en curso';
    END IF;
    
    IF NEW.pla_vac_estado_planificacion = 'En curso' AND OLD.pla_vac_estado_planificacion = 'Finalizado' THEN
		-- CALL planificacion_modificacion_vacacion_solicitud(NEW.pla_vac_id);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo pla_vac_estado_planificacion a En curso una vez finalizado';
    END IF;
    
    -- Calcular valor para campo pla_vac_fecha_hasta
    SET NEW.pla_vac_fecha_hasta = NEW.pla_vac_fecha_desde + INTERVAL NEW.pla_vac_dias_tomados DAY;
END //
DELIMITER ;

-- drop trigger tr_check_update_planificacion_vacacion_creacion_solicitud;
-- Trigger que permite crear una solicitud si el estado de una planificacion pasa a en curso
DELIMITER //

CREATE TRIGGER tr_check_update_planificacion_vacacion_creacion_solicitud AFTER UPDATE ON Planificacion_Vacacion
FOR EACH ROW
BEGIN

    IF NEW.pla_vac_estado_planificacion = 'En curso' AND OLD.pla_vac_estado_planificacion = 'Pendiente' THEN
        CALL planificacion_creacion_vacacion_solicitud(NEW.pla_vac_id);
    END IF;
END //

DELIMITER ;