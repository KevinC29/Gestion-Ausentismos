-- Utilizar la base de datos
USE gestion_personal;

DELIMITER //
CREATE EVENT ev_actualizar_estado_permiso
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO
BEGIN

    UPDATE Permiso
    SET perm_estado = 'Finalizado'
    WHERE perm_fecha_hora_fin <= NOW()
    AND perm_estado != 'Finalizado';
END //
DELIMITER ;
