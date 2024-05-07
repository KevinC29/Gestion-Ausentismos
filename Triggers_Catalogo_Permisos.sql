-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE TRIGGER tr_check_insert_catalogo_permisos_validacion BEFORE INSERT ON Catalogo_Permisos
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.cat_per_numero_dias) > 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El campo cat_per_numero_dias no puede tener más de 2 dígitos.';
    END IF;
    
    IF LENGTH(NEW.cat_per_numero_horas) > 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El campo cat_per_numero_horas no puede tener más de 2 dígitos.';
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM Catalogo_Permisos
        WHERE cat_per_tipo = NEW.cat_per_tipo AND cat_per_periodo = NEW.cat_per_periodo
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe un registro para la combinación de cat_per_tipo y cat_per_periodo especificados.';
    END IF;
    
    IF NEW.cat_per_tipo  = 'Enfermedad' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = TRUE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Maternidad' THEN
		SET NEW.cat_per_numero_dias = 90;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    IF NEW.cat_per_tipo  = 'Paternidad' THEN
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Duelo' THEN
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
	IF NEW.cat_per_tipo  = 'Asunto Personal' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 3;
        SET NEW.cat_per_justificacion = TRUE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Estudios' THEN
        IF NEW.cat_per_numero_dias > 15 OR (NEW.cat_per_numero_dias = 15 AND NEW.cat_per_numero_horas > 0) THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'El campo cat_per_numero_horas no puede ser mayor a 15 dias';
        END IF;
        
        IF NEW.cat_per_numero_horas != 0 THEN
			IF  NEW.cat_per_numero_horas > 24 THEN
				SET NEW.cat_per_numero_dias = NEW.cat_per_numero_dias + FLOOR(NEW.cat_per_numero_horas / 24);
                SET NEW.cat_per_numero_horas = NEW.cat_per_numero_horas % 24;
			ELSE
				SET NEW.cat_per_numero_dias = 0;
            END IF;
        END IF;
        
        IF NEW.cat_per_numero_dias != 0 THEN
			SET NEW.cat_per_numero_horas = 0;
        END IF;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Actividad Politica' THEN
		SET NEW.cat_per_numero_dias = 10;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Vacaciones' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_numero_horas > 24 THEN
        SET NEW.cat_per_numero_dias = NEW.cat_per_numero_dias + FLOOR(NEW.cat_per_numero_horas / 24);
        SET NEW.cat_per_numero_horas = NEW.cat_per_numero_horas % 24;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_update_catalogo_permisos_validacion BEFORE UPDATE ON Catalogo_Permisos
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.cat_per_numero_dias) > 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El campo cat_per_numero_dias no puede tener más de 3 dígitos.';
    END IF;
    
    IF LENGTH(NEW.cat_per_numero_horas) > 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El campo cat_per_numero_horas no puede tener más de 2 dígitos.';
    END IF;
    
    IF NEW.cat_per_tipo  = 'Enfermedad' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = TRUE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Maternidad' THEN
		SET NEW.cat_per_numero_dias = 90;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Paternidad' THEN
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Duelo' THEN
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
	IF NEW.cat_per_tipo  = 'Asunto Personal' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 3;
        SET NEW.cat_per_justificacion = TRUE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Estudios' THEN
        IF NEW.cat_per_numero_dias > 15 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'El campo cat_per_numero_horas no puede ser mayor a 15 dias';
        END IF;
        
        IF NEW.cat_per_numero_horas != 0 THEN
			SET NEW.cat_per_numero_dias = 0;
        END IF;
        
        IF NEW.cat_per_numero_dias != 0 THEN
			SET NEW.cat_per_numero_horas = 0;
        END IF;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Actividad Politica' THEN
		SET NEW.cat_per_numero_dias = 10;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    IF NEW.cat_per_tipo  = 'Vacaciones' THEN
		SET NEW.cat_per_numero_dias = 0;
        SET NEW.cat_per_numero_horas = 0;
        SET NEW.cat_per_justificacion = FALSE;
    END IF;
    
    
    IF NEW.cat_per_numero_horas > 24 THEN
        SET NEW.cat_per_numero_dias = NEW.cat_per_numero_dias + FLOOR(NEW.cat_per_numero_horas / 24);
        SET NEW.cat_per_numero_horas = NEW.cat_per_numero_horas % 24;
    END IF;
END //
DELIMITER ;