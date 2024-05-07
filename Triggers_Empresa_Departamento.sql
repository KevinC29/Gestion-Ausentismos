-- Utilizar la base de datos
USE gestion_personal;

-- Tabla Empresa
DELIMITER //
CREATE TRIGGER tr_check_insert_empresa_departamento_validacion BEFORE INSERT ON Empresa_Departamento
FOR EACH ROW
BEGIN
	DECLARE ed_count INT;
    DECLARE ed_empresa INT;
    DECLARE ed_departamento INT;
    
    SELECT COUNT(*) INTO ed_empresa
	FROM Empresa
	WHERE em_id = NEW.em_id;
    
    IF ed_empresa = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el id de la empresa ingresada';
	END IF;
    
    SELECT COUNT(*) INTO ed_departamento
	FROM Departamento
	WHERE dep_id = NEW.dep_id;
    
    IF ed_departamento = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el id del departamento ingresado';
	END IF;
    
    -- Verificar si existe otro registro con el mismo em_dep_id y pers_cedula_jefe = NULL
	SELECT COUNT(*) INTO ed_count
	FROM Empresa_Departamento
	WHERE em_id = NEW.em_id AND dep_id = NEW.dep_id;
    
	IF ed_count > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe la relacion departamento con la empresa ingresada';
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_check_update_empresa_departamento_validacion BEFORE INSERT ON Empresa_Departamento
FOR EACH ROW
BEGIN
	DECLARE ed_count INT;
    DECLARE ed_empresa INT;
    DECLARE ed_departamento INT;
    
    SELECT COUNT(*) INTO ed_empresa
	FROM Empresa
	WHERE em_id = NEW.em_id;
    
    IF ed_empresa = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el id de la empresa ingresada';
	END IF;
    
    SELECT COUNT(*) INTO ed_departamento
	FROM Departamento
	WHERE dep_id = NEW.dep_id;
    
    IF ed_departamento = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el id del departamento ingresado';
	END IF;
    
    -- Verificar si existe otro registro con el mismo em_dep_id y pers_cedula_jefe = NULL
	SELECT COUNT(*) INTO ed_count
	FROM Empresa_Departamento
	WHERE em_id = NEW.em_id AND dep_id = NEW.dep_id;
    
	IF ed_count > 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe la relacion departamento con la empresa ingresada';
	END IF;
END //
DELIMITER ;