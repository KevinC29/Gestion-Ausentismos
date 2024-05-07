-- Utilizar la base de datos
USE gestion_personal;


-- DROP trigger tr_auditoria_personal_create;
-- DROP trigger tr_auditoria_personal_update;
-- DROP trigger tr_auditoria_personal_delete;

DELIMITER //
CREATE TRIGGER tr_auditoria_personal_create AFTER INSERT ON Personal
FOR EACH ROW
BEGIN
  -- Variables para almacenar la información
  DECLARE accion VARCHAR(150);
  DECLARE dato_actual VARCHAR(10);
  DECLARE dato_modificado VARCHAR(1000);
  DECLARE justificacion TEXT;
  
  -- Determinar la acción realizada (inserción)
  SET accion = 'Inserción';
  SET dato_actual = NULL;
  SET dato_modificado = JSON_OBJECT('pers_cedula', NEW.pers_cedula, 'em_dep_id', NEW.em_dep_id, 'pers_cedula_jefe', NEW.pers_cedula_jefe, 'pers_nombre', NEW.pers_nombre, 'pers_cargo', NEW.pers_cargo, 'pers_direccion', NEW.pers_direccion, 'pers_correo', NEW.pers_correo, 'pers_direccion_padres', NEW.pers_direccion_padres, 'pers_numero_referencia_familiar', NEW.pers_numero_referencia_familiar, 'pers_numero_celular', NEW.pers_numero_celular, 'pers_backup_principal', NEW.pers_backup_principal, 'pers_backup_secundario', NEW.pers_backup_secundario, 'pers_fecha_inicio_contrato', NEW.pers_fecha_inicio_contrato, 'pers_fecha_fin_contrato', NEW.pers_fecha_fin_contrato, 'pers_total_dias_trabajados', NEW.pers_total_dias_trabajados, 'pers_total_dias_vacaciones', NEW.pers_total_dias_vacaciones, 'pers_fecha_habilitacion_vacaciones', NEW.pers_fecha_habilitacion_vacaciones);
  
  -- Obtener la justificación del cambio
  SET justificacion = CONCAT('Dato erroneo - ', accion);
  
  -- Insertar el registro de auditoría en la tabla "Auditoria"
  INSERT INTO Auditoria (aud_usuario, aud_fecha, aud_nombre_tabla, aud_accion, aud_dato_actual, aud_dato_modificado, aud_justificacion)
  VALUES (CURRENT_USER(), NOW(), 'Personal', accion, dato_actual, dato_modificado, justificacion);
END //
DELIMITER //

-- Actualización del trigger para la auditoría de la tabla Personal
DELIMITER //
CREATE TRIGGER tr_auditoria_personal_update AFTER UPDATE ON Personal
FOR EACH ROW
BEGIN
  -- Variables para almacenar la información
  DECLARE accion VARCHAR(150);
  DECLARE dato_actual VARCHAR(1000);
  DECLARE dato_modificado VARCHAR(1000);
  DECLARE justificacion TEXT;
  
  -- Determinar la acción realizada (actualización)
  SET accion = 'Actualización';
  SET dato_actual = JSON_OBJECT('pers_cedula', OLD.pers_cedula, 'em_dep_id', OLD.em_dep_id, 'pers_cedula_jefe', OLD.pers_cedula_jefe, 'pers_nombre', OLD.pers_nombre, 'pers_cargo', OLD.pers_cargo, 'pers_direccion', OLD.pers_direccion, 'pers_correo', OLD.pers_correo, 'pers_direccion_padres', OLD.pers_direccion_padres, 'pers_numero_referencia_familiar', OLD.pers_numero_referencia_familiar, 'pers_numero_celular', OLD.pers_numero_celular, 'pers_backup_principal', OLD.pers_backup_principal, 'pers_backup_secundario', OLD.pers_backup_secundario, 'pers_fecha_inicio_contrato', OLD.pers_fecha_inicio_contrato, 'pers_fecha_fin_contrato', OLD.pers_fecha_fin_contrato, 'pers_total_dias_trabajados', OLD.pers_total_dias_trabajados, 'pers_total_dias_vacaciones', OLD.pers_total_dias_vacaciones, 'pers_fecha_habilitacion_vacaciones', OLD.pers_fecha_habilitacion_vacaciones);
  SET dato_modificado = JSON_OBJECT('pers_cedula', NEW.pers_cedula, 'em_dep_id', NEW.em_dep_id, 'pers_cedula_jefe', NEW.pers_cedula_jefe, 'pers_nombre', NEW.pers_nombre, 'pers_cargo', NEW.pers_cargo, 'pers_direccion', NEW.pers_direccion, 'pers_correo', NEW.pers_correo, 'pers_direccion_padres', NEW.pers_direccion_padres, 'pers_numero_referencia_familiar', NEW.pers_numero_referencia_familiar, 'pers_numero_celular', NEW.pers_numero_celular, 'pers_backup_principal', NEW.pers_backup_principal, 'pers_backup_secundario', NEW.pers_backup_secundario, 'pers_fecha_inicio_contrato', NEW.pers_fecha_inicio_contrato, 'pers_fecha_fin_contrato', NEW.pers_fecha_fin_contrato, 'pers_total_dias_trabajados', NEW.pers_total_dias_trabajados, 'pers_total_dias_vacaciones', NEW.pers_total_dias_vacaciones, 'pers_fecha_habilitacion_vacaciones', NEW.pers_fecha_habilitacion_vacaciones);
  
  -- Obtener la justificación del cambio
  SET justificacion = CONCAT('Dato erroneo - ', accion);
  
  -- Insertar el registro de auditoría en la tabla "Auditoria"
  INSERT INTO Auditoria (aud_usuario, aud_fecha, aud_nombre_tabla, aud_accion, aud_dato_actual, aud_dato_modificado, aud_justificacion)
  VALUES (CURRENT_USER(), NOW(), 'Personal', accion, dato_actual, dato_modificado, justificacion);
END //
DELIMITER //

-- Eliminación del trigger para la auditoría de la tabla Personal
DELIMITER //
CREATE TRIGGER tr_auditoria_personal_delete AFTER DELETE ON Personal
FOR EACH ROW
BEGIN
  -- Variables para almacenar la información
  DECLARE accion VARCHAR(150);
  DECLARE dato_actual VARCHAR(1000);
  DECLARE dato_modificado VARCHAR(10);
  DECLARE justificacion TEXT;
  
  -- Determinar la acción realizada (eliminación)
  SET accion = 'Eliminación';
  SET dato_actual = JSON_OBJECT('pers_cedula', OLD.pers_cedula, 'em_dep_id', OLD.em_dep_id, 'pers_cedula_jefe', OLD.pers_cedula_jefe, 'pers_nombre', OLD.pers_nombre, 'pers_cargo', OLD.pers_cargo, 'pers_direccion', OLD.pers_direccion, 'pers_correo', OLD.pers_correo, 'pers_direccion_padres', OLD.pers_direccion_padres, 'pers_numero_referencia_familiar', OLD.pers_numero_referencia_familiar, 'pers_numero_celular', OLD.pers_numero_celular, 'pers_backup_principal', OLD.pers_backup_principal, 'pers_backup_secundario', OLD.pers_backup_secundario, 'pers_fecha_inicio_contrato', OLD.pers_fecha_inicio_contrato, 'pers_fecha_fin_contrato', OLD.pers_fecha_fin_contrato, 'pers_total_dias_trabajados', OLD.pers_total_dias_trabajados, 'pers_total_dias_vacaciones', OLD.pers_total_dias_vacaciones, 'pers_fecha_habilitacion_vacaciones', OLD.pers_fecha_habilitacion_vacaciones);
  SET dato_modificado = NULL;
  
  -- Obtener la justificación del cambio
  SET justificacion = CONCAT('Dato erroneo - ', accion);
  
  -- Insertar el registro de auditoría en la tabla "Auditoria"
  INSERT INTO Auditoria (aud_usuario, aud_fecha, aud_nombre_tabla, aud_accion, aud_dato_actual, aud_dato_modificado, aud_justificacion)
  VALUES (CURRENT_USER(), NOW(), 'Personal', accion, dato_actual, dato_modificado, justificacion);
END //
DELIMITER ;