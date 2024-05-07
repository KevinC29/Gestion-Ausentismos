-- Utilizar la base de datos
USE gestion_personal;

-- drop trigger tr_check_insert_vacacion_solicitud_validacion;

DELIMITER //
CREATE TRIGGER tr_check_insert_vacacion_solicitud_validacion BEFORE INSERT ON Vacacion_Solicitud
FOR EACH ROW
BEGIN
    DECLARE v_pers_nombre VARCHAR(50);
    DECLARE v_pers_empresa_departamento INT;
    DECLARE v_pers_cedula_jefe INT;
    DECLARE v_departamento INT;
    DECLARE v_pers_fecha_inicio_contrato DATE;
    DECLARE v_pers_total_dias_trabajados INT;
    DECLARE v_pers_fecha_habilitacion_vacaciones DATE;
    DECLARE v_fecha_departamento DATE;
    DECLARE v_count INT;
    DECLARE v_count_id INT;
    DECLARE v_estado ENUM ('Pendiente', 'En curso', 'Finalizada');
    
    
    -- Obtener pers_nombre, pers_cedula_jefe
	SELECT em_dep_id, pers_nombre, pers_cedula_jefe, pers_fecha_inicio_contrato, pers_total_dias_trabajados, pers_fecha_habilitacion_vacaciones
    INTO v_pers_empresa_departamento,v_pers_nombre, v_pers_cedula_jefe, v_pers_fecha_inicio_contrato, v_pers_total_dias_trabajados, v_pers_fecha_habilitacion_vacaciones
	FROM Personal
	WHERE pers_cedula = NEW.pers_cedula;
    
    -- Obtener el id del area en la tabla empresa_departamento
	SELECT dep_id INTO v_departamento
	FROM empresa_departamento
	WHERE em_dep_id = v_pers_empresa_departamento;
    
    -- Obtener la fecha de la planificacion del area en la tabla departamento
    SELECT dep_fecha_max_planificacion INTO v_fecha_departamento
	FROM departamento
	WHERE dep_id = v_departamento;
    
    -- Verificar si el usuario ya tiene una solicitud pendiente
    SELECT COUNT(*) INTO v_count
    FROM Vacacion_Solicitud
    WHERE pers_cedula = NEW.pers_cedula AND vac_sol_estado = 'Pendiente';
    
    IF v_count > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una solicitud de vacaciones pendiente';
	END IF;
    
    IF v_fecha_departamento <= CURDATE() THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Termino la fecha permitida por el departamento para realizar solicitudes,  
        realice una petición de habilitar el sistema con la justificación correspondiente al jefe de TH.';
	END IF;

	IF v_pers_fecha_habilitacion_vacaciones <= DATE_ADD(v_pers_fecha_inicio_contrato, INTERVAL v_pers_total_dias_trabajados DAY) THEN
		IF LENGTH(NEW.pers_cedula) > 10 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo pers_cedula debe tener máximo 10 dígitos.';
		END IF;

		-- Validar vac_sol_numero_oficio
		IF LENGTH(NEW.vac_sol_dias_tomados) > 2 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_dias_tomados no puede tener más de 2 dígitos.';
		END IF;
		
		IF LENGTH(NEW.vac_sol_numero_oficio) > 5 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_numero_oficio no puede tener más de 5 dígitos.';
		END IF;
		
		IF NEW.vac_sol_estado != 'Pendiente' THEN
			SET NEW.vac_sol_estado = 'Pendiente';
		END IF;
        
        IF NEW.vac_sol_firma_jefe IS NOT NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_firma_jefe no puede firmarse aun.';
        END IF;
        
        IF NEW.vac_sol_cedula_autoriza IS NOT NULL OR NEW.vac_sol_nombre_autoriza IS NOT NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usted ya tiene un jefe asignado';
		END IF;
		-- Asignar valor a vac_sol_cedula_autoriza si pers_cedula_jefe es NULL
		IF v_pers_cedula_jefe IS NULL THEN
			SET v_pers_cedula_jefe = NEW.pers_cedula;
		END IF;
		-- Calcular vac_sol_fecha_hasta
		SET NEW.vac_sol_fecha_hasta = DATE_ADD(NEW.vac_sol_fecha_desde, INTERVAL NEW.vac_sol_dias_tomados DAY);

		-- Actualizar los campos necesarios en el registro
		SET NEW.vac_sol_fecha_creacion = NOW();
		SET NEW.vac_sol_cedula_autoriza = v_pers_cedula_jefe;
		SET NEW.vac_sol_usuario_beneficiario = v_pers_nombre;
		SET NEW.vac_sol_nombre_autoriza = (SELECT pers_nombre FROM Personal WHERE pers_cedula = NEW.vac_sol_cedula_autoriza);
    ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aun no cumple con la cantidad de dias trabajados necesarios';
    END IF;
END //
DELIMITER ;

-- drop trigger tr_check_update_vacacion_solicitud_validacion;
DELIMITER //
CREATE TRIGGER tr_check_update_vacacion_solicitud_validacion BEFORE UPDATE ON Vacacion_Solicitud
FOR EACH ROW
BEGIN
    DECLARE v_pers_nombre VARCHAR(50);
    DECLARE v_pers_cedula_jefe INT;
    
    IF OLD.vac_sol_estado = 'Pendiente' THEN
		-- Evitar modificar los campos necesarios en el registro
		IF NEW.pers_cedula  != OLD.pers_cedula  THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo pers_cedula';
		END IF;

		-- Obtener pers_cedula_jefe
		SELECT pers_cedula_jefe INTO v_pers_cedula_jefe
		FROM Personal
		WHERE pers_cedula = NEW.pers_cedula;

		-- Asignar valor a vac_sol_cedula_autoriza si pers_cedula_jefe es NULL
		IF v_pers_cedula_jefe IS NULL THEN
			SET v_pers_cedula_jefe = NEW.pers_cedula;
		END IF;

		SET NEW.vac_sol_cedula_autoriza = v_pers_cedula_jefe;
		SET NEW.vac_sol_nombre_autoriza = (SELECT pers_nombre FROM Personal WHERE pers_cedula = NEW.vac_sol_cedula_autoriza);
		
		-- Evitar modificar los campos necesarios en el registro
		IF NEW.vac_sol_numero_oficio  != OLD.vac_sol_numero_oficio  THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo vac_sol_numero_oficio';
		END IF;
		
		-- Evitar modificar los campos necesarios en el registro
		IF NEW.vac_sol_fecha_creacion != OLD.vac_sol_fecha_creacion THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo vac_sol_fecha_creacion';
		END IF;
		
		IF NEW.vac_sol_usuario_beneficiario != OLD.vac_sol_usuario_beneficiario THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo vac_sol_usuario_beneficiario';
		END IF;
		
		IF NEW.vac_sol_usuario_creacion != OLD.vac_sol_usuario_creacion  THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el campo vac_sol_usuario_creacion';
		END IF;
		
		IF NEW.vac_sol_estado = 'Pendiente' AND NEW.vac_sol_firma_jefe != NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_firma_jefe no puede firmarse aun.';
		END IF;
		
		IF NEW.vac_sol_estado != 'Aprobada' AND OLD.vac_sol_estado = 'Aprobada' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar el estado una vez aprobado';
		END IF;
		
		IF NEW.vac_sol_estado != 'Negada' AND OLD.vac_sol_estado = 'Negada' THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar el estado una vez negado';
		END IF;
		
		IF NEW.vac_sol_estado = 'Pendiente' AND NEW.vac_sol_firma_empleado != NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_firma_empleado no puede firmarse aun.';
		END IF;
		
		IF NEW.vac_sol_estado = 'Pendiente' AND  NEW.vac_sol_fecha_aprobacion != NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo vac_sol_fecha_aprobacion no puede asignarse aun.';
		END IF;

		-- Calcular y actualizar vac_sol_fecha_hasta
		SET NEW.vac_sol_fecha_hasta = DATE_ADD(NEW.vac_sol_fecha_desde, INTERVAL NEW.vac_sol_dias_tomados DAY);
    ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar este registro si fue aprobado o negado';
    END IF;
END //
DELIMITER ;

-- drop trigger tr_check_update_vacacion_solicitud_permiso;
-- Trigger que genera un permiso en caso de cambiar el estado a aprobado
DELIMITER //
CREATE TRIGGER tr_check_update_vacacion_solicitud_permiso BEFORE UPDATE ON Vacacion_Solicitud
FOR EACH ROW
BEGIN
    DECLARE vac_sol_dias_tomados INT;
    DECLARE sal_vac_disponibles INT;
    
    -- Obtiene el valor de vac_sol_dias_tomados
    SELECT NEW.vac_sol_dias_tomados INTO vac_sol_dias_tomados;
    
    -- Obtiene la cantidad de días disponibles de vacaciones
    SELECT sal_vac_dias_disponibles INTO sal_vac_disponibles
    FROM Saldo_Vacacion
    WHERE pers_cedula = NEW.pers_cedula;
    
    -- Validación de días disponibles de vacaciones
    IF vac_sol_dias_tomados <= sal_vac_disponibles AND NEW.vac_sol_fecha_desde >= CURDATE() THEN
        -- Actualiza el estado de la solicitud según la condición
        IF NEW.vac_sol_estado = 'Aprobada' THEN
            -- Actualiza los campos de aprobación
            SET NEW.vac_sol_firma_jefe = NEW.vac_sol_cedula_autoriza,
                NEW.vac_sol_firma_empleado = NEW.pers_cedula,
                NEW.vac_sol_fecha_aprobacion = NOW();
            
            -- Llama al primer procedimiento almacenado para actualizar el saldo de vacaciones
            -- CALL actualizar_saldo_vacaciones_solicitud(NEW.pers_cedula, vac_sol_dias_tomados);
            
            -- Llama al segundo procedimiento almacenado para crear un registro en la tabla Permisos
            -- CALL crear_permiso_vacaciones_solicitud(NEW.vac_sol_id, NEW.pers_cedula, OLD.vac_sol_numero_oficio, NEW.vac_sol_cedula_autoriza, NEW.vac_sol_nombre_autoriza, NEW.vac_sol_fecha_aprobacion, NEW.vac_sol_fecha_creacion, NEW.vac_sol_fecha_desde, NEW.vac_sol_fecha_hasta, vac_sol_dias_tomados, NEW.vac_sol_firma_jefe);
        
        ELSEIF NEW.vac_sol_estado = 'Negada' THEN
            -- Actualiza los campos de rechazo
            SET NEW.vac_sol_motivo_rechazo = 'No puede ausentarse',
                NEW.vac_sol_firma_jefe = NEW.vac_sol_cedula_autoriza,
                NEW.vac_sol_firma_empleado = NEW.pers_cedula,
                NEW.vac_sol_fecha_aprobacion = NOW();
        END IF;
    ELSE
        -- Actualiza los campos en caso de no tener días disponibles
        SET NEW.vac_sol_estado = 'Negada',
            NEW.vac_sol_motivo_rechazo = 'No cuenta con días disponibles de vacaciones o la fecha par realizar la aprobar la solicitud expiro',
            NEW.vac_sol_firma_jefe = NEW.vac_sol_cedula_autoriza,
            NEW.vac_sol_firma_empleado = NEW.pers_cedula,
            NEW.vac_sol_fecha_aprobacion = NOW();
    END IF;
    
    -- Calcular y actualizar vac_sol_fecha_hasta en caso de que se modifique los dias tomados
    SET NEW.vac_sol_fecha_hasta = DATE_ADD(NEW.vac_sol_fecha_desde, INTERVAL NEW.vac_sol_dias_tomados DAY);
END //
DELIMITER ;

-- drop trigger trg_vacacion_solicitud_email_insert;
DELIMITER //
CREATE TRIGGER trg_vacacion_solicitud_email_insert AFTER INSERT ON Vacacion_Solicitud
FOR EACH ROW
BEGIN
    DECLARE co_accion VARCHAR(100);
    DECLARE v_pers_nombre VARCHAR(50);
    
    -- Obtener pers_nombre, pers_cedula_jefe
	SELECT pers_nombre INTO v_pers_nombre
	FROM Personal
	WHERE pers_cedula = NEW.pers_cedula;

    SET co_accion = CONCAT('Se ingreso la solicitud (Estado: ', NEW.vac_sol_estado, ')');
    
    -- Insertar el nuevo registro en la tabla "Email"
    INSERT INTO Correo (co_nombre_solicitud, co_accion)
    VALUES (v_pers_nombre, co_accion);
END //
DELIMITER ;

-- drop trigger trg_vacacion_solicitud_email_update;
DELIMITER //
CREATE TRIGGER trg_vacacion_solicitud_email_update AFTER UPDATE ON Vacacion_Solicitud
FOR EACH ROW
BEGIN
	DECLARE co_accion VARCHAR(100);
    DECLARE co_count INT;
	-- Verifica si hay un registro en la tabla Planificacion_Vacacion
    
    IF NEW.vac_sol_estado = 'Aprobada' OR NEW.vac_sol_estado = 'Negada' THEN
		SELECT COUNT(*) INTO co_count
		FROM Planificacion_Vacacion
		WHERE pers_cedula = NEW.pers_cedula AND pla_vac_numero_oficio = NEW.vac_sol_numero_oficio;
    END IF;
    
    IF co_count > 0 THEN
		UPDATE Planificacion_Vacacion
		SET pla_vac_estado_planificacion = 'Finalizada'
		WHERE pers_cedula = NEW.pers_cedula AND pla_vac_numero_oficio = NEW.vac_sol_numero_oficio;
    END IF;

	IF NEW.vac_sol_estado = 'Aprobada' THEN
		-- Llama al primer procedimiento almacenado para actualizar el saldo de vacaciones
		CALL actualizar_saldo_vacaciones_solicitud(NEW.pers_cedula, New.vac_sol_dias_tomados);
            
		-- Llama al segundo procedimiento almacenado para crear un registro en la tabla Permisos
		CALL crear_permiso_vacaciones_solicitud(NEW.vac_sol_id, NEW.pers_cedula, NEW.vac_sol_numero_oficio, 
		NEW.vac_sol_cedula_autoriza, NEW.vac_sol_nombre_autoriza, NEW.vac_sol_fecha_aprobacion, 
		NEW.vac_sol_fecha_creacion, NEW.vac_sol_fecha_desde, NEW.vac_sol_fecha_hasta, NEW.vac_sol_dias_tomados, NEW.vac_sol_firma_jefe);
    END IF;
    
    SET co_accion = CONCAT('Se modifico la solicitud (Estado: ', NEW.vac_sol_estado, ') (Revisor: ', NEW.vac_sol_nombre_autoriza, ')' );
    
    -- Insertar el nuevo registro en la tabla "Email"
    INSERT INTO Correo (co_nombre_solicitud, co_accion)
    VALUES (NEW.vac_sol_usuario_beneficiario, co_accion);
END //
DELIMITER ;