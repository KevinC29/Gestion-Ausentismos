-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE PROCEDURE crear_permiso_vacaciones_solicitud(
    IN p_vac_sol_id INT,
    IN p_pers_cedula INT,
    IN p_vac_sol_numero_oficio INT,
    IN p_vac_sol_cedula_autoriza VARCHAR(50),
    IN p_vac_sol_nombre_autoriza VARCHAR(50),
    IN p_vac_sol_fecha_aprobacion DATETIME,
    IN p_vac_sol_fecha_creacion DATETIME,
    IN p_vac_sol_fecha_desde DATETIME,
    IN p_vac_sol_fecha_hasta DATETIME,
    IN p_vac_sol_dias_tomados INT,
    IN p_vac_sol_firma_jefe VARCHAR(50)
)
BEGIN
    DECLARE v_cat_per_id INT;
    
    -- Obtiene el ID de la categoría "Vacaciones"
    SELECT cat_per_id INTO v_cat_per_id
    FROM Catalogo_Permisos
    WHERE cat_per_tipo = 'Vacaciones';
    
    -- Inserta un registro en la tabla Permisos
    INSERT INTO Permiso (cat_per_id, vac_sol_id, pers_cedula, perm_numero_oficio, perm_cedula_autoriza, perm_nombre_autoriza, perm_fecha_registro, perm_fecha_pedido, perm_fecha_hora_inicio, perm_fecha_hora_fin, perm_duracion_dias, perm_estado_solicitud_permiso , perm_firma_jefe, perm_fecha_aprobacion)
    VALUES (v_cat_per_id, p_vac_sol_id, p_pers_cedula, p_vac_sol_numero_oficio  ,p_vac_sol_cedula_autoriza, p_vac_sol_nombre_autoriza, p_vac_sol_fecha_aprobacion, p_vac_sol_fecha_creacion, p_vac_sol_fecha_desde, p_vac_sol_fecha_hasta, p_vac_sol_dias_tomados, 'Aprobada', p_vac_sol_firma_jefe, p_vac_sol_fecha_aprobacion);
    
END //
DELIMITER ;
