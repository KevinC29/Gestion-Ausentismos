-- Utilizar la base de datos
USE gestion_personal;
-- drop procedure actualizar_saldo_vacacion_permiso;
DELIMITER //
CREATE PROCEDURE actualizar_saldo_vacacion_permiso(
    IN p_pers_cedula INT,
    IN p_perm_duracion_dias INT,
    IN p_perm_duracion_horas INT
)
BEGIN
	DECLARE p_sal_vac_dias_disponibles INT;
    DECLARE p_sal_vac_horas_disponibles INT;
    DECLARE p_sal_vac_dias_anio_actual INT;
    DECLARE p_sal_vac_dias_un_anio INT;
    DECLARE p_sal_vac_dias_dos_anios INT;
    DECLARE t_sal_vac_dias_disponibles INT;
    DECLARE t_sal_vac_horas_disponibles INT;
    DECLARE t_sal_vac_dias_diferencia_uno INT;
    DECLARE t_sal_vac_dias_diferencia_dos INT;
    DECLARE t_sal_vac_dias_diferencia_tres INT;
    DECLARE t_sal_vac_dias_diferencia_cuatro INT;
    
    SELECT sal_vac_dias_disponibles, sal_vac_horas_disponibles, sal_vac_dias_anio_actual, sal_vac_dias_un_anio, sal_vac_dias_dos_anios
    INTO p_sal_vac_dias_disponibles, p_sal_vac_horas_disponibles, p_sal_vac_dias_anio_actual, p_sal_vac_dias_un_anio, p_sal_vac_dias_dos_anios
    FROM Saldo_Vacacion
    WHERE pers_cedula = p_pers_cedula;
    
    -- Se valida si tiene dias disponibles y la cantidad de horas llego a 0
    IF (p_sal_vac_dias_disponibles * 24) + p_sal_vac_horas_disponibles  > 0 THEN
        IF p_sal_vac_dias_anio_actual >= p_perm_duracion_dias  THEN
			UPDATE Saldo_Vacacion
			SET 
				sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
				sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
				sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
				sal_vac_dias_anio_actual = sal_vac_dias_anio_actual - p_perm_duracion_dias
			WHERE pers_cedula = p_pers_cedula;
            
		ELSEIF p_sal_vac_dias_anio_actual > 0 AND p_perm_duracion_dias > p_sal_vac_dias_anio_actual AND p_sal_vac_dias_un_anio > 0 THEN
			SET t_sal_vac_dias_diferencia_uno = p_perm_duracion_dias - p_sal_vac_dias_anio_actual; -- 10 -8 = 2
            SET t_sal_vac_dias_diferencia_dos = p_perm_duracion_dias - t_sal_vac_dias_diferencia_uno; -- 10 - 2 = 8
            
            IF p_sal_vac_dias_un_anio >= t_sal_vac_dias_diferencia_uno THEN
				UPDATE Saldo_Vacacion
				SET 
					sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
					sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
					sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
					sal_vac_dias_anio_actual = sal_vac_dias_anio_actual - t_sal_vac_dias_diferencia_dos,
					sal_vac_dias_un_anio = sal_vac_dias_un_anio - t_sal_vac_dias_diferencia_uno
				WHERE pers_cedula = p_pers_cedula;
                -- 8 -- 2
			ELSEIF p_sal_vac_dias_un_anio > 0 AND t_sal_vac_dias_diferencia_uno > p_sal_vac_dias_un_anio AND p_sal_vac_dias_dos_anios > 0 THEN
				SET t_sal_vac_dias_diferencia_tres = t_sal_vac_dias_diferencia_uno - p_sal_vac_dias_un_anio; -- 6
				SET t_sal_vac_dias_diferencia_cuatro = t_sal_vac_dias_diferencia_uno - t_sal_vac_dias_diferencia_tres; -- 2
                
                UPDATE Saldo_Vacacion
				SET 
					sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
					sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
					sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
					sal_vac_dias_anio_actual = sal_vac_dias_anio_actual - t_sal_vac_dias_diferencia_dos,
					sal_vac_dias_un_anio = sal_vac_dias_un_anio - t_sal_vac_dias_diferencia_cuatro,
                    sal_vac_dias_dos_anios = sal_vac_dias_dos_anios - t_sal_vac_dias_diferencia_tres
				WHERE pers_cedula = p_pers_cedula;
            END IF;
		ELSEIF p_sal_vac_dias_anio_actual > 0 AND p_perm_duracion_dias > p_sal_vac_dias_anio_actual AND p_sal_vac_dias_un_anio = 0 THEN
			SET t_sal_vac_dias_diferencia_uno = p_perm_duracion_dias - p_sal_vac_dias_anio_actual; -- 8 -2 = 6
            SET t_sal_vac_dias_diferencia_dos = p_perm_duracion_dias - t_sal_vac_dias_diferencia_uno; -- 8 - 6 = 2
			
			UPDATE Saldo_Vacacion
			SET 
				sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
				sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
				sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
				sal_vac_dias_anio_actual = sal_vac_dias_anio_actual - t_sal_vac_dias_diferencia_dos,
				sal_vac_dias_dos_anios = sal_vac_dias_dos_anios - t_sal_vac_dias_diferencia_uno
			WHERE pers_cedula = p_pers_cedula;
            
		ELSEIF p_sal_vac_dias_anio_actual = 0 AND p_sal_vac_dias_un_anio > 0 THEN
            IF p_sal_vac_dias_un_anio >= p_perm_duracion_dias THEN
				UPDATE Saldo_Vacacion
				SET 
					sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
					sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
					sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
					sal_vac_dias_un_anio = sal_vac_dias_un_anio - p_perm_duracion_dias
				WHERE pers_cedula = p_pers_cedula;
            ELSEIF p_sal_vac_dias_un_anio > 0 AND p_perm_duracion_dias > p_sal_vac_dias_un_anio THEN
				SET t_sal_vac_dias_diferencia_uno = p_perm_duracion_dias - p_sal_vac_dias_un_anio; -- 8 -2 = 6
				SET t_sal_vac_dias_diferencia_dos = p_perm_duracion_dias - t_sal_vac_dias_diferencia_uno; -- 8 - 6 = 2
                
                UPDATE Saldo_Vacacion
				SET 
					sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
					sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
					sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
					sal_vac_dias_un_anio = sal_vac_dias_un_anio - t_sal_vac_dias_diferencia_dos,
                    sal_vac_dias_dos_anios = sal_vac_dias_dos_anios - t_sal_vac_dias_diferencia_uno
				WHERE pers_cedula = p_pers_cedula;
            END IF;
            
		ELSEIF p_sal_vac_dias_anio_actual = 0 AND p_sal_vac_dias_un_anio = 0 AND p_sal_vac_dias_dos_anios > 0 THEN
			UPDATE Saldo_Vacacion
			SET 
				sal_vac_horas_disponibles = sal_vac_horas_disponibles - p_perm_duracion_horas,
				sal_vac_dias_tomados = sal_vac_dias_tomados + p_perm_duracion_dias,
				sal_vac_horas_tomadas = sal_vac_horas_tomadas + p_perm_duracion_horas,
				sal_vac_dias_dos_anios = sal_vac_dias_dos_anios - p_perm_duracion_dias
			WHERE pers_cedula = p_pers_cedula;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No cuenta con dias disponibles ni horas disponibles';
    END IF;
END //
DELIMITER ;

