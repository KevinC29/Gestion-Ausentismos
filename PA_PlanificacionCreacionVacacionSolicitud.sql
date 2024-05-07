-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE PROCEDURE planificacion_creacion_vacacion_solicitud(IN p_pla_vac_id INT)
BEGIN
    DECLARE v_pers_cedula INT;
    DECLARE v_pla_vac_numero_oficio INT;
    -- DECLARE v_pla_vac_usuario_beneficiario VARCHAR(50);
    DECLARE v_pla_vac_fecha_desde DATETIME;
    DECLARE v_pla_vac_dias_tomados INT;
    -- DECLARE v_pers_cedula_jefe INT;
    -- DECLARE v_pers_nombre_autoriza VARCHAR(50);
    
    -- Obtener los datos de la planificación
    SELECT pers_cedula, pla_vac_numero_oficio, pla_vac_fecha_desde, pla_vac_dias_tomados
    INTO v_pers_cedula, v_pla_vac_numero_oficio, v_pla_vac_fecha_desde, v_pla_vac_dias_tomados
    FROM Planificacion_Vacacion
    WHERE pla_vac_id = p_pla_vac_id;
    
    -- Insertar en Vacacion_Solicitud
    INSERT INTO Vacacion_Solicitud (pers_cedula, vac_sol_numero_oficio, vac_sol_fecha_desde, vac_sol_dias_tomados)
    VALUES (v_pers_cedula, v_pla_vac_numero_oficio, v_pla_vac_fecha_desde, v_pla_vac_dias_tomados);
END //

DELIMITER ;
