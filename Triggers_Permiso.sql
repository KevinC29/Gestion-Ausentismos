-- Utilizar la base de datos
USE gestion_personal;


-- drop trigger tr_check_insert_permiso_validacion;
DELIMITER //
CREATE TRIGGER tr_check_insert_permiso_validacion BEFORE INSERT ON Permiso
FOR EACH ROW
BEGIN
	DECLARE v_cat_per_numero_dias INT;
    DECLARE v_count INT;
    DECLARE v_count_aux INT;
	DECLARE v_cat_per_numero_horas INT;
    DECLARE v_pers_cedula_jefe INT;
	DECLARE v_perm_nombre_autoriza VARCHAR(50);
    DECLARE v_cat_per_tipo ENUM('Enfermedad', 'Maternidad', 'Paternidad', 'Duelo', 'Asunto Personal', 'Estudios', 'Actividad Politica', 'Vacaciones');
	
    -- Obtener valores de cat_per_numero_dias y cat_per_numero_horas
	IF LENGTH(NEW.pers_cedula) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
	END IF;
    
    IF NEW.pers_cedula IS NULL OR NEW.cat_per_id  IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar la cedula para crear un permiso.';
	END IF;

	IF LENGTH(NEW.perm_numero_oficio) > 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_numero_oficio no puede tener más de 5 dígitos.';
	END IF;
    
    IF NEW.perm_fecha_hora_inicio = NOW() THEN
		SET NEW.perm_estado = 'En curso';
	ELSE
		SET NEW.perm_estado = 'Pendiente';
    END IF;
    
    SELECT cat_per_tipo, cat_per_numero_dias, cat_per_numero_horas INTO v_cat_per_tipo, v_cat_per_numero_dias, v_cat_per_numero_horas
	FROM Catalogo_Permisos
	WHERE cat_per_id = NEW.cat_per_id;
    
    IF v_cat_per_tipo != 'Vacaciones' THEN
		SET NEW.vac_sol_id = NULL;
    END IF;
    
    IF NEW.vac_sol_id IS NULL AND v_cat_per_tipo != 'Vacaciones' THEN
        
		IF NEW.perm_firma_jefe IS NOT NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_firma_jefe no puede ser firmado aun.';
		END IF;

        -- Asignar valores a perm_duracion_dias y perm_duracion_horas
        SET NEW.perm_duracion_dias = v_cat_per_numero_dias;
        SET NEW.perm_duracion_horas = v_cat_per_numero_horas;

        IF v_cat_per_tipo = 'Actividad Politica' THEN
            SET NEW.perm_remuneracion = 'Si';
        END IF;

        -- Asignar valor a perm_cedula_autoriza
        SELECT pers_cedula_jefe INTO v_pers_cedula_jefe
        FROM Personal
        WHERE pers_cedula = NEW.pers_cedula;

        IF v_pers_cedula_jefe IS NULL THEN
            SET v_pers_cedula_jefe = NEW.pers_cedula;
        END IF;

        -- Asignar valor a perm_nombre_autoriza
        SELECT pers_nombre INTO v_perm_nombre_autoriza
        FROM Personal
        WHERE pers_cedula = v_pers_cedula_jefe;

        -- Asignar valores
        SET NEW.perm_fecha_registro = NOW();
        SET NEW.perm_cedula_autoriza = v_pers_cedula_jefe;
        SET NEW.perm_nombre_autoriza = (SELECT pers_nombre FROM Personal WHERE pers_cedula = NEW.perm_cedula_autoriza);
        SET NEW.perm_fecha_hora_inicio = NEW.perm_fecha_pedido;
        SET NEW.perm_fecha_hora_fin = DATE_ADD(NEW.perm_fecha_hora_inicio, INTERVAL NEW.perm_duracion_dias DAY) + INTERVAL NEW.perm_duracion_horas HOUR;
        
        IF NEW.perm_estado_solicitud_permiso != 'Pendiente' THEN
			SET NEW.perm_estado_solicitud_permiso = 'Pendiente';
        END IF;
        
        IF NEW.perm_estado != 'Pendiente' THEN
			SET NEW.perm_estado = 'Pendiente';
        END IF;
	ELSE
		-- Verificar si el usuario ya tiene una solicitud aprobada
		SELECT COUNT(*) INTO v_count_aux
		FROM Permiso
		WHERE vac_sol_id = NEW.vac_sol_id;
        
        IF v_count_aux = 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un registro con el id de la solicitud ingresada';
        END IF;
        
        SELECT COUNT(*) INTO v_count
		FROM Vacacion_Solicitud
		WHERE pers_cedula = NEW.pers_cedula
        AND vac_sol_numero_oficio = NEW.perm_numero_oficio
        AND vac_sol_estado = 'Aprobada'
        AND vac_sol_id = NEW.vac_sol_id;	
        
        IF v_count = 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden registrar permisos por vacaciones sin una previa solicitud de vacaciones';
        END IF;
        
        
    END IF;
END //
DELIMITER ;

-- drop trigger tr_check_update_permiso_validacion;
DELIMITER //
CREATE TRIGGER tr_check_update_permiso_validacion BEFORE UPDATE ON Permiso
FOR EACH ROW
BEGIN
	DECLARE v_pers_cedula_jefe INT;
	DECLARE v_perm_nombre_autoriza VARCHAR(50);
    DECLARE v_cat_per_tipo ENUM('Enfermedad', 'Maternidad', 'Paternidad', 'Duelo', 'Asunto Personal', 'Estudios', 'Actividad Politica', 'Vacaciones');
	DECLARE v_cat_per_numero_dias INT;
	DECLARE v_cat_per_numero_horas INT;
    
	-- Evitar modificar los campos necesarios en el registro
	-- IF NEW.vac_sol_id IS NOT NULL THEN
		-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este registro no se puede modificar';
	-- END IF;
    
    IF NEW.perm_estado_solicitud_permiso != 'Aprobada' AND OLD.perm_estado_solicitud_permiso = 'Aprobada' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_estado_solicitud_permiso no se puede modificar';
	END IF;
    
    IF NEW.perm_estado_solicitud_permiso != 'Negada' AND OLD.perm_estado_solicitud_permiso = 'Negada' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_estado_solicitud_permiso no se puede modificar';
	END IF;
    
    IF NEW.vac_sol_id IS NULL THEN
		IF NEW.pers_cedula != OLD.pers_cedula THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula no se puede modificar';
		END IF;
		
		IF NEW.vac_sol_id != OLD.vac_sol_id THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_id no se puede modificar';
		END IF;
		
		IF NEW.perm_numero_oficio != OLD.perm_numero_oficio THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_numero_oficio';
		END IF;
		
		IF NEW.perm_fecha_registro != OLD.perm_fecha_registro THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_registro  ';
		END IF;
		
		IF NEW.perm_estado_solicitud_permiso = 'Pendiente' AND NEW.perm_estado != 'Pendiente'  THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_estado no puede ser modificado.';
		END IF;
		
		IF NEW.perm_firma_jefe IS NOT NULL AND NEW.perm_estado_solicitud_permiso = 'Pendiente' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_firma_jefe no puede ser firmado aun.';
		END IF;
		
		SELECT cat_per_tipo, cat_per_numero_dias, cat_per_numero_horas INTO v_cat_per_tipo, v_cat_per_numero_dias, v_cat_per_numero_horas
		FROM Catalogo_Permisos
		WHERE cat_per_id = NEW.cat_per_id;

		-- Asignar valores a perm_duracion_dias y perm_duracion_horas
        IF v_cat_per_tipo != 'Enfermedad' THEN
			SET NEW.perm_duracion_dias = v_cat_per_numero_dias;
			SET NEW.perm_duracion_horas = v_cat_per_numero_horas;
		END IF;
        
		IF v_cat_per_tipo = 'Actividad Politica' THEN
			SET NEW.perm_remuneracion = 'Si';
		ELSE
			SET NEW.perm_remuneracion = 'No';
		END IF;

		-- Asignar valor a perm_cedula_autoriza
		SELECT pers_cedula_jefe INTO v_pers_cedula_jefe
		FROM Personal
		WHERE pers_cedula = NEW.pers_cedula;

		IF v_pers_cedula_jefe IS NULL THEN
			SET v_pers_cedula_jefe = NEW.pers_cedula;
		END IF;

		-- Asignar valor a perm_nombre_autoriza
		SELECT pers_nombre INTO v_perm_nombre_autoriza
		FROM Personal
		WHERE pers_cedula = v_pers_cedula_jefe;

		-- Asignar valores
		SET NEW.perm_cedula_autoriza = v_pers_cedula_jefe;
		SET NEW.perm_nombre_autoriza = (SELECT pers_nombre FROM Personal WHERE pers_cedula = NEW.perm_cedula_autoriza);
		SET NEW.perm_fecha_hora_inicio = NEW.perm_fecha_pedido;
		SET NEW.perm_fecha_hora_fin = DATE_ADD(NEW.perm_fecha_hora_inicio, INTERVAL NEW.perm_duracion_dias DAY) + INTERVAL NEW.perm_duracion_horas HOUR;
    ELSE
		IF NEW.cat_per_id != OLD.cat_per_id THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo cat_per_id no se puede modificar';
		END IF;
        
        IF NEW.vac_sol_id != OLD.vac_sol_id THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_id no se puede modificar';
		END IF;
        
        IF NEW.perm_estado_solicitud_permiso != OLD.perm_estado_solicitud_permiso THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo perm_estado_solicitud_permiso no se puede modificar';
		END IF;
        
		IF NEW.pers_cedula != OLD.pers_cedula THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula no se puede modificar';
		END IF;
        
        IF NEW.perm_numero_oficio != OLD.perm_numero_oficio THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_numero_oficio';
		END IF;

		IF NEW.perm_cedula_autoriza != OLD.perm_cedula_autoriza THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_cedula_autoriza';
		END IF;

		IF NEW.perm_nombre_autoriza != OLD.perm_nombre_autoriza THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_nombre_autoriza';
		END IF;

		IF NEW.perm_fecha_registro != OLD.perm_fecha_registro THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_registro';
		END IF;

		IF NEW.perm_fecha_pedido != OLD.perm_fecha_pedido THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_pedido';
		END IF;

		-- IF NEW.perm_fecha_hora_inicio != OLD.perm_fecha_hora_inicio THEN
			-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_hora_inicio';
		-- END IF;

		IF NEW.perm_fecha_hora_fin != OLD.perm_fecha_hora_fin THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_hora_fin';
		END IF;

		IF NEW.perm_duracion_dias != OLD.perm_duracion_dias THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_duracion_dias';
		END IF;

		IF NEW.perm_duracion_horas != OLD.perm_duracion_horas THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_duracion_horas';
		END IF;

		IF NEW.perm_remuneracion != OLD.perm_remuneracion THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_remuneracion';
		END IF;

		IF NEW.perm_observacion != OLD.perm_observacion THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_observacion';
		END IF;

		IF NEW.perm_archivo_respaldo != OLD.perm_archivo_respaldo THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_archivo_respaldo';
		END IF;

		IF NEW.perm_estado_solicitud_permiso != OLD.perm_estado_solicitud_permiso THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_estado_solicitud_permiso';
		END IF;

		IF NEW.perm_firma_jefe != OLD.perm_firma_jefe THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_firma_jefe';
		END IF;

		IF NEW.perm_fecha_aprobacion != OLD.perm_fecha_aprobacion THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo perm_fecha_aprobacion';
		END IF;
    END IF;
END //
DELIMITER ;

-- drop trigger tr_check_update_permiso_validacion_estado;
-- Trigger para aprobar el permiso
DELIMITER //
CREATE TRIGGER tr_check_update_permiso_validacion_estado BEFORE UPDATE ON Permiso
FOR EACH ROW
BEGIN
    DECLARE v_saldo_dias INT;
    DECLARE v_saldo_horas INT;
    DECLARE v_sal_vac_dias_anio_actual INT;
    DECLARE v_sal_vac_dias_un_anio INT;
    DECLARE v_sal_vac_dias_dos_anios INT;
    DECLARE v_pers_cedula_jefe INT;
    DECLARE v_cat_per_tipo ENUM('Enfermedad', 'Maternidad', 'Paternidad', 'Duelo', 'Asunto Personal', 'Estudios', 'Actividad Politica', 'Vacaciones');

    -- Obtener pers_cedula_jefe
    SELECT pers_cedula_jefe INTO v_pers_cedula_jefe
    FROM Personal
    WHERE pers_cedula = NEW.pers_cedula;

    -- Asignar valor a perm_cedula_autoriza si pers_cedula_jefe es NULL
    IF v_pers_cedula_jefe IS NULL THEN
        SET NEW.perm_cedula_autoriza = NEW.pers_cedula;
    END IF;

    -- Obtener el tipo de cat_per_id
    SELECT cat_per_tipo INTO v_cat_per_tipo
    FROM Catalogo_Permisos
    WHERE cat_per_id = NEW.cat_per_id;

    -- Validar perm_duracion_dias y perm_duracion_horas en Saldo_Vacacion
    SELECT sal_vac_dias_disponibles, sal_vac_horas_disponibles, sal_vac_dias_anio_actual, sal_vac_dias_un_anio, sal_vac_dias_dos_anios
    INTO v_saldo_dias, v_saldo_horas, v_sal_vac_dias_anio_actual, v_sal_vac_dias_un_anio, v_sal_vac_dias_dos_anios
    FROM Saldo_Vacacion
    WHERE pers_cedula = NEW.pers_cedula;
    
	IF NEW.vac_sol_id IS NULL THEN
		IF v_cat_per_tipo NOT IN ('Maternidad', 'Paternidad') THEN 
			IF (NEW.perm_duracion_dias * 24 + NEW.perm_duracion_horas ) < (v_saldo_dias * 24 + v_saldo_horas) THEN
				-- Realizar acciones adicionales cuando vac_sol_id es NULL
				IF NEW.perm_estado_solicitud_permiso = 'Negada' THEN
					SET NEW.perm_firma_jefe = NEW.perm_cedula_autoriza;
					SET NEW.perm_estado = 'Finalizado';
					SET NEW.perm_observacion = 'No puede ausentarse';
					SET NEW.perm_fecha_aprobacion = NOW();
				
                ELSEIF NEW.perm_estado_solicitud_permiso = 'Aprobada' THEN
					IF v_cat_per_tipo IN ('Asunto Personal', 'Estudios') THEN 
                        IF v_saldo_horas = 0 AND  v_sal_vac_dias_anio_actual > 0 THEN
							SET v_sal_vac_dias_anio_actual = v_sal_vac_dias_anio_actual - 1;
							SET v_saldo_horas = v_saldo_horas + 24;
                            
                            UPDATE Saldo_Vacacion
							SET sal_vac_horas_disponibles = v_saldo_horas, 
								sal_vac_dias_anio_actual = v_sal_vac_dias_anio_actual
							WHERE pers_cedula = NEW.pers_cedula;
                            
						ELSEIF v_saldo_horas = 0 AND v_sal_vac_dias_un_anio > 0  THEN
							SET v_sal_vac_dias_un_anio = v_sal_vac_dias_un_anio - 1;
							SET v_saldo_horas = v_saldo_horas + 24;
                            
                            UPDATE Saldo_Vacacion
							SET sal_vac_horas_disponibles = v_saldo_horas,
								sal_vac_dias_un_anio = v_sal_vac_dias_un_anio
							WHERE  pers_cedula = NEW.pers_cedula;
						
                        ELSEIF v_saldo_horas = 0 AND v_sal_vac_dias_dos_anios > 0 THEN
							SET v_sal_vac_dias_dos_anios = v_sal_vac_dias_dos_anios - 1;
							SET v_saldo_horas = v_saldo_horas + 24;
                            
                            UPDATE Saldo_Vacacion
							SET sal_vac_horas_disponibles = v_saldo_horas,
								sal_vac_dias_dos_anios = v_sal_vac_dias_dos_anios
							WHERE  pers_cedula = NEW.pers_cedula;
						END IF;
                    END IF;
                
					SET NEW.perm_firma_jefe = NEW.perm_cedula_autoriza;
                    SET NEW.perm_observacion = 'Su permiso ha sido aprobado';
					-- SET NEW.perm_estado = 'En curso';
					SET NEW.perm_fecha_aprobacion = NOW();
					-- Verificar las condiciones para ejecutar el procedimiento almacenado
					IF NEW.perm_estado_solicitud_permiso = 'Aprobada' AND OLD.perm_estado_solicitud_permiso = 'Pendiente' THEN
						IF v_cat_per_tipo NOT IN ('Enfermedad', 'Vacaciones') THEN
							-- Ejecutar procedimiento almacenado
							CALL actualizar_saldo_vacacion_permiso(NEW.pers_cedula, NEW.perm_duracion_dias, NEW.perm_duracion_horas);
						ELSEIF v_cat_per_tipo = 'Enfermedad' AND NEW.perm_archivo_respaldo IS NULL THEN
							-- Ejecutar procedimiento almacenado
							CALL actualizar_saldo_vacacion_permiso(NEW.pers_cedula, NEW.perm_duracion_dias, NEW.perm_duracion_horas);
						END IF;
					END IF;
				END IF;
			ELSE 
				SET NEW.perm_estado_solicitud_permiso = 'Negada';
				SET NEW.perm_firma_jefe = NEW.perm_cedula_autoriza;
				SET NEW.perm_estado = 'Finalizado';
				SET NEW.perm_observacion = 'No cuenta con días u horas disponibles';
				SET NEW.perm_fecha_aprobacion = NOW();
			END IF;
		ELSE
			SET NEW.perm_estado_solicitud_permiso = 'Aprobada';
			SET NEW.perm_firma_jefe = NEW.perm_cedula_autoriza;
			-- SET NEW.perm_estado = 'Finalizado';
			SET NEW.perm_observacion = 'Permiso autorizado';
			SET NEW.perm_fecha_aprobacion = NOW();
        END IF;
    END IF;
	IF  NEW.perm_fecha_hora_inicio >= NOW() AND NEW.perm_estado_solicitud_permiso = 'Aprobada' THEN
		SET NEW.perm_estado = 'En curso';
	ELSE
		SET NEW.perm_estado = 'Pendiente';
    END IF;
    
END //
DELIMITER ;

-- drop trigger tr_check_insert_permiso_validacion_estado_ausencia_vacacion;
-- Trigger para generar la ausencia
DELIMITER //
CREATE TRIGGER tr_check_insert_permiso_validacion_estado_ausencia_vacacion AFTER INSERT ON Permiso
FOR EACH ROW
BEGIN
	IF NEW.perm_estado = 'En curso' THEN
        INSERT IGNORE INTO Ausente (perm_id, aus_cedula_jefe, aus_firma_jefe)
		VALUES (NEW.perm_id, NEW.perm_cedula_autoriza, NEW.perm_nombre_autoriza);
    END IF;
END //
DELIMITER ;

-- drop trigger tr_check_update_permiso_validacion_estado_ausencia;
-- Trigger para generar la ausencia
DELIMITER //
CREATE TRIGGER tr_check_update_permiso_validacion_estado_ausencia AFTER UPDATE ON Permiso
FOR EACH ROW
BEGIN
	
	IF NEW.perm_estado = 'En curso' THEN
        INSERT IGNORE INTO Ausente (perm_id, aus_cedula_jefe, aus_firma_jefe)
		VALUES (NEW.perm_id, NEW.perm_cedula_autoriza, NEW.perm_nombre_autoriza);
    END IF;
    
	IF NEW.perm_estado = 'Finalizado' THEN
        UPDATE Ausente
        SET aus_estado = FALSE
        WHERE perm_id = OLD.perm_id;
    END IF;
END //
DELIMITER ;

