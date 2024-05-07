INSERT INTO Empresa (em_nombre, em_direccion, em_telefono)
VALUES
  ('Empresa A', 'Dirección A', '1111111111'),
  ('Empresa B', 'Dirección B', '2222222222'),
  ('Empresa C', 'Dirección C', '3333333333'),
  ('Empresa D', 'Dirección D', '4444444444');


INSERT INTO Departamento (dep_nombre, dep_fecha_max_planificacion)
VALUES
  ('Departamento A', '2023-08-01'),
  ('Departamento B', '2023-08-01'),
  ('Departamento C', '2023-08-01'),
  ('Departamento D', '2023-08-01');


INSERT INTO Empresa_Departamento (em_id, dep_id)
VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (2, 1),
  (2, 3),
  (2, 4),
  (3, 3),
  (3, 4);

INSERT INTO Catalogo_Permisos (
  cat_per_tipo, cat_per_descripcion, cat_per_periodo, cat_per_numero_dias,
  cat_per_numero_horas
)
VALUES
  ('Enfermedad', 'Descripción Enfermedad', 2023, 0, 0),
  ('Maternidad', 'Descripción Maternidad', 2023, 0, 0),
  ('Paternidad', 'Descripción Paternidad', 2023, 15, 0),
  ('Vacaciones', 'Descripción Vacaciones', 2023, 0, 0),
  ('Actividad Politica', 'Descripción Actividad Politica', 2023, 10, 0),
  ('Estudios', 'Descripción Estudios', 2023, 15, 0),
  ('Asunto Personal', 'Descripción Asunto Personal', 2023, 0, 3),
  ('Duelo', 'Descripción Duelo', 2023, 3, 0);
  
INSERT INTO Personal (
  pers_cedula, em_dep_id, pers_cedula_jefe, pers_nombre, pers_cargo, pers_direccion, pers_correo,
  pers_direccion_padres, pers_numero_referencia_familiar, pers_numero_celular,
  pers_backup_principal, pers_backup_secundario, pers_fecha_inicio_contrato, pers_fecha_fin_contrato,
  pers_total_dias_trabajados, pers_total_dias_vacaciones, pers_fecha_habilitacion_vacaciones
)
VALUES
  (123456789, 1, NULL, 'Empleado A', 'Cargo A', 'Dirección A', 'correoA@example.com', 'Dirección padres A',
   '111111111', '111111111', 'Backup principal A', 'Backup secundario A', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (234567890, 2, NULL, 'Empleado B', 'Cargo B', 'Dirección B', 'correoB@example.com', 'Dirección padres B',
   '222222222', '222222222', 'Backup principal B', 'Backup secundario B', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (345678901, 3, NULL, 'Empleado C', 'Cargo C', 'Dirección C', 'correoC@example.com', 'Dirección padres C',
   '333333333', '333333333', 'Backup principal C', 'Backup secundario C', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (456789012, 4, NULL, 'Empleado D', 'Cargo D', 'Dirección D', 'correoD@example.com', 'Dirección padres D',
   '444444444', '444444444', 'Backup principal D', 'Backup secundario D', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (345678902, 5, NULL, 'Empleado E', 'Cargo E', 'Dirección E', 'correoE@example.com', 'Dirección padres E',
   '555555555', '555555555', 'Backup principal E', 'Backup secundario E', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (345678905, 6, NULL, 'Empleado F', 'Cargo F', 'Dirección F', 'correoF@example.com', 'Dirección padres F',
   '666666666', '666666666', 'Backup principal F', 'Backup secundario F', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (345678991, 7, NULL, 'Empleado G', 'Cargo G', 'Dirección G', 'correoG@example.com', 'Dirección padres G',
   '777777777', '777777777', 'Backup principal G', 'Backup secundario G', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
  (345678911, 1, 456789012, 'Empleado H', 'Cargo H', 'Dirección H', 'correoH@example.com', 'Dirección padres H',
   '888888888', '888888888', 'Backup principal H', 'Backup secundario H', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345878920, 2, 456789012, 'Empleado I', 'Cargo I', 'Dirección I', 'correoH@example.com', 'Dirección padres I',
   '888888888', '888888888', 'Backup principal I', 'Backup secundario I', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345068920, 3, 456789012, 'Empleado J', 'Cargo J', 'Dirección J', 'correoH@example.com', 'Dirección padres J',
   '888888888', '888888888', 'Backup principal J', 'Backup secundario J', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345268920, 4, 456789012, 'Empleado K', 'Cargo K', 'Dirección K', 'correoH@example.com', 'Dirección padres K',
   '888888888', '888888888', 'Backup principal K', 'Backup secundario K', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345665920, 5, 456789012, 'Empleado L', 'Cargo L', 'Dirección L', 'correoH@example.com', 'Dirección padres L',
   '888888888', '888888888', 'Backup principal L', 'Backup secundario L', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345667920, 6, 456789012, 'Empleado M', 'Cargo M', 'Dirección M', 'correoH@example.com', 'Dirección padres M',
   '888888888', '888888888', 'Backup principal M', 'Backup secundario M', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01'),
   (345668910, 7, 456789012, 'Empleado N', 'Cargo N', 'Dirección N', 'correoH@example.com', 'Dirección padres N',
   '888888888', '888888888', 'Backup principal N', 'Backup secundario N', '2023-01-01', '2026-12-31', 0, 15, '2023-04-01');

UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '123456789');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '234567890');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345068920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345268920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345665920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345667920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345668910');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345678901');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345678902');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345678905');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345678911');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345678991');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '345878920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '360' WHERE (`pers_cedula` = '456789012');

UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '123456789');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '234567890');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345068920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345268920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345665920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345667920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345668910');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345678901');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345678902');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345678905');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345678911');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345678991');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '345878920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '720' WHERE (`pers_cedula` = '456789012');


UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '1080' WHERE (`pers_cedula` = '123456789');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '1080' WHERE (`pers_cedula` = '234567890');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '1080' WHERE (`pers_cedula` = '345068920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '1080' WHERE (`pers_cedula` = '345268920');
UPDATE `gestion_personal`.`personal` SET `pers_total_dias_trabajados` = '1080' WHERE (`pers_cedula` = '345665920');


INSERT INTO Planificacion_Vacacion (
  pers_cedula, pla_vac_numero_oficio, pla_vac_usuario_creacion, pla_vac_fecha_desde, pla_vac_dias_tomados
)
VALUES
  (123456789, 1, 'Usuario A', '2023-08-01', 15),
  (123456789, 2, 'Usuario B', '2023-08-01', 7),
  (123456789, 3, 'Usuario C', '2023-08-01', 10),
  (123456789, 4, 'Usuario D', '2023-08-02', 5),
  (345678901, 5, 'Usuario E', '2023-08-05', 6),
  (345678901, 6, 'Usuario F', '2023-08-01', 5),
  (345678901, 7, 'Usuario G', '2023-08-01', 7),
  (345668910, 8, 'Usuario H', '2023-08-01', 4),
  (345668910, 9, 'Usuario I', '2023-08-02', 6),
  (345668910, 10, 'Usuario J', '2023-08-02', 7),
  (345068920, 11, 'Usuario K', '2023-08-05', 7),
  (345068920, 12, 'Usuario L', '2023-08-05', 2),
  (345068920, 13, 'Usuario M', '2023-08-05', 15);


UPDATE `gestion_personal`.`planificacion_vacacion` SET `pla_vac_estado_planificacion` = 'En curso' WHERE (`pla_vac_id` = '1');
UPDATE `gestion_personal`.`planificacion_vacacion` SET `pla_vac_estado_planificacion` = 'En curso' WHERE (`pla_vac_id` = '5');
UPDATE `gestion_personal`.`planificacion_vacacion` SET `pla_vac_estado_planificacion` = 'En curso' WHERE (`pla_vac_id` = '8');
UPDATE `gestion_personal`.`planificacion_vacacion` SET `pla_vac_estado_planificacion` = 'En curso' WHERE (`pla_vac_id` = '11');


UPDATE `gestion_personal`.`vacacion_solicitud` SET `vac_sol_estado` = 'Negada' WHERE (`vac_sol_id` = '1');
UPDATE `gestion_personal`.`vacacion_solicitud` SET `vac_sol_estado` = 'Aprobada' WHERE (`vac_sol_id` = '3');

UPDATE `gestion_personal`.`planificacion_vacacion` SET `pla_vac_estado_planificacion` = 'Pendiente' WHERE (`pla_vac_id` = '1');




INSERT INTO correo (
  co_accion, co_nombre_solicitud
)
VALUES
('Se registro la solicitud 1', 'Usuario 1'),
('Se modifico la solicitud 2', 'Usuario 2'),
('Se registro la solicitud 1', 'Usuario 3'),
('Se modifico la solicitud 2', 'Usuario 4');

INSERT INTO Vacacion_Solicitud (
  pers_cedula, vac_sol_numero_oficio,
  vac_sol_usuario_creacion, vac_sol_fecha_desde,
  vac_sol_dias_tomados
)
VALUES
  (345878920,105, 'Usuario A', '2023-08-10', 5),
  (345678991,106, 'Usuario B', '2023-08-15', 7),
  (345268920,107, 'Usuario C', '2023-08-18', 4),
  (345678905,108, 'Usuario D', '2023-08-25', 6);


INSERT INTO Permiso (
  cat_per_id, vac_sol_id, pers_cedula, perm_numero_oficio,
  perm_fecha_registro, perm_fecha_pedido
)
VALUES
  -- Para la categoría 'Enfermedad'
  (1, NULL, 123456789, 120, NOW(), '2023-08-01'),
  (1, NULL, 234567890, 121, NOW(), '2023-08-02'),
  -- Para la categoría 'Maternidad'
  (2, NULL, 123456789, 122, NOW(), '2023-08-03'),
  (2, NULL, 345678902, 123, NOW(), '2023-08-04'),
  -- Para la categoría 'Paternidad'
  (3, NULL, 123456789, 124, NOW(), '2023-08-05'),
  (3, NULL, 345678911, 125, NOW(), '2023-08-06'),
  -- Para la categoría 'Actividad Política'
  (7, NULL, 234567890, 126, NOW(), '2023-08-07'),
  (7, NULL, 345678991, 127, NOW(), '2023-08-08'),
  -- Para la categoría 'Estudios'
  (6, NULL, 123456789, 128, NOW(), '2023-08-09'),
  (6, NULL, 345878920, 129, NOW(), '2023-08-10'),
  -- Para la categoría 'Asunto Personal'
  (5, NULL, 123456789, 130, NOW(), '2023-08-11'),
  (5, NULL, 345068920, 131, NOW(), '2023-08-12'),
  -- Para la categoría 'Duelo'
  (8, NULL, 234567890, 132, NOW(), '2023-08-13'),
  (8, NULL, 345665920, 133, NOW(), '2023-08-14');


UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '22');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '23');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Negada' WHERE (`perm_id` = '19');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '18');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Negada' WHERE (`perm_id` = '17');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Negada' WHERE (`perm_id` = '16');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '15');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Negada' WHERE (`perm_id` = '14');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '13');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Negada' WHERE (`perm_id` = '12');
UPDATE `gestion_personal`.`permiso` SET `perm_estado_solicitud_permiso` = 'Aprobada' WHERE (`perm_id` = '11');
