-- Utilizar la base de datos
USE gestion_personal;

-- drop trigger tr_check_insert_permiso_validacion;
DELIMITER //
CREATE TRIGGER tr_check_insert_permiso_validacion BEFORE INSERT ON Permiso
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

	SELECT COUNT(*) INTO v_count
	FROM Ausente
	WHERE perm_id = NEW.perm_id;
	
	IF v_count = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un ausente por el id del permiso ingresado';
	END IF;
        
END //
DELIMITER ;