-- Utilizar la base de datos
USE gestion_personal;

-- Tabla Empresa
DELIMITER //
CREATE TRIGGER tr_check_insert_empresa_validacion BEFORE INSERT ON Empresa
FOR EACH ROW
BEGIN
	IF LENGTH(NEW.em_telefono) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo em_telefono debe tener máximo 10 dígitos.';
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_update_empresa_validacion BEFORE UPDATE ON Empresa
FOR EACH ROW
BEGIN
	IF LENGTH(NEW.em_telefono) > 10 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El campo em_telefono debe tener máximo 10 dígitos.';
	END IF;
END //
DELIMITER ;