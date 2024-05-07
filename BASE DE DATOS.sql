SET GLOBAL event_scheduler = ON;
-- Crear la base de datos
CREATE DATABASE gestion_personal;

-- Utilizar la base de datos
USE gestion_personal;

-- Crear tabla Empresa
CREATE TABLE Empresa (
  em_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  em_nombre VARCHAR(50) DEFAULT 'Empresa',
  em_direccion VARCHAR(50) DEFAULT 'Ecuador',
  em_telefono VARCHAR(10) DEFAULT '9999999999'
);

-- Crear tabla Departamento
CREATE TABLE Departamento (
  dep_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dep_nombre VARCHAR(50) DEFAULT 'Completar',
  dep_fecha_max_planificacion DATE NOT NULL
);

-- Crear tabla Empresa_Departamento
CREATE TABLE Empresa_Departamento (
  em_dep_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  em_id INT UNSIGNED  NOT NULL,
  dep_id INT UNSIGNED  NOT NULL,
  FOREIGN KEY (em_id) REFERENCES Empresa(em_id) ON DELETE RESTRICT,
  FOREIGN KEY (dep_id) REFERENCES Departamento(dep_id) ON DELETE RESTRICT
);

-- Crear tabla Personal

CREATE TABLE Personal (
  pers_cedula INT UNSIGNED NOT NULL UNIQUE,
  em_dep_id INT UNSIGNED NOT NULL,
  pers_cedula_jefe INT UNSIGNED  DEFAULT NULL,
  pers_nombre VARCHAR(50) DEFAULT 'Completar',
  pers_cargo VARCHAR(50) DEFAULT 'Completar',
  pers_direccion VARCHAR(100) DEFAULT 'Completar',
  pers_correo VARCHAR(100) DEFAULT 'Completar',
  pers_direccion_padres VARCHAR(100) DEFAULT 'Completar',
  pers_numero_referencia_familiar VARCHAR(10) DEFAULT '9999999999',
  pers_numero_celular VARCHAR(10) DEFAULT '9999999999',
  pers_backup_principal VARCHAR(100) DEFAULT 'Completar',
  pers_backup_secundario VARCHAR(100) DEFAULT 'Completar',
  pers_fecha_inicio_contrato DATE NOT NULL,
  pers_fecha_fin_contrato DATE NOT NULL,
  pers_total_dias_trabajados INT UNSIGNED DEFAULT 0,
  pers_total_dias_vacaciones INT UNSIGNED DEFAULT 0,
  pers_fecha_habilitacion_vacaciones DATE NOT NULL,
  PRIMARY KEY (pers_cedula),
  FOREIGN KEY (em_dep_id) REFERENCES Empresa_Departamento (em_dep_id) ON DELETE RESTRICT,
  FOREIGN KEY (pers_cedula_jefe) REFERENCES Personal (pers_cedula) ON DELETE RESTRICT
);

-- Crear tabla Saldo_Vacacion
CREATE TABLE Saldo_Vacacion (
  sal_vac_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  pers_cedula INT UNSIGNED  NOT NULL,
  sal_vac_remuneracion INT UNSIGNED DEFAULT 0,
  sal_vac_dias_disponibles INT UNSIGNED  DEFAULT 0,
  sal_vac_horas_disponibles INT UNSIGNED  DEFAULT 0,
  sal_vac_dias_tomados INT UNSIGNED  DEFAULT 0,
  sal_vac_horas_tomadas INT UNSIGNED  DEFAULT 0,
  sal_vac_dias_anio_actual INT UNSIGNED  DEFAULT 0,
  sal_vac_dias_un_anio INT UNSIGNED  DEFAULT 0,
  sal_vac_dias_dos_anios INT UNSIGNED  DEFAULT 0,
  sal_vac_periodo YEAR NOT NULL,
  FOREIGN KEY (pers_cedula) REFERENCES Personal(pers_cedula) ON DELETE RESTRICT
);

-- Crear tabla Planificacion_Vacacion
CREATE TABLE Planificacion_Vacacion (
  pla_vac_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  pers_cedula INT UNSIGNED  NOT NULL,
  pla_vac_numero_oficio INT UNSIGNED  NOT NULL UNIQUE,
  pla_vac_fecha_creacion DATETIME,
  pla_vac_usuario_creacion VARCHAR(50) DEFAULT 'Completar',
  pla_vac_usuario_beneficiario VARCHAR(50) DEFAULT NULL,
  pla_vac_fecha_desde DATETIME NOT NULL,
  pla_vac_dias_tomados INT UNSIGNED  NOT NULL,
  pla_vac_fecha_hasta DATETIME NOT NULL,
  pla_vac_estado_planificacion ENUM('Pendiente', 'En curso', 'Finalizada') DEFAULT 'Pendiente',
  FOREIGN KEY (pers_cedula) REFERENCES Personal(pers_cedula) ON DELETE RESTRICT
);

-- Crear tabla Vacacion_Solicitud
CREATE TABLE Vacacion_Solicitud (
  vac_sol_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  pers_cedula INT UNSIGNED  NOT NULL,
  -- pla_vac_id INT UNSIGNED  DEFAULT NULL,
  vac_sol_numero_oficio INT UNSIGNED NOT NULL UNIQUE,
  vac_sol_fecha_creacion DATETIME NULL,
  vac_sol_usuario_creacion VARCHAR(50) DEFAULT 'Completar',
  vac_sol_usuario_beneficiario VARCHAR(50) DEFAULT NULL,
  vac_sol_fecha_desde DATETIME NOT NULL,
  vac_sol_dias_tomados INT UNSIGNED  NOT NULL,
  vac_sol_fecha_hasta DATETIME DEFAULT NULL,
  vac_sol_cedula_autoriza VARCHAR(50) DEFAULT NULL,
  vac_sol_nombre_autoriza VARCHAR(50) DEFAULT NULL,
  vac_sol_estado ENUM('Pendiente', 'Aprobada', 'Negada') DEFAULT 'Pendiente',
  vac_sol_motivo_rechazo TEXT DEFAULT NULL,
  vac_sol_firma_jefe VARCHAR(50) DEFAULT NULL,
  vac_sol_firma_empleado VARCHAR(50) DEFAULT NULL,
  vac_sol_fecha_aprobacion DATETIME DEFAULT NULL,
  FOREIGN KEY (pers_cedula) REFERENCES Personal(pers_cedula) ON DELETE RESTRICT
  -- FOREIGN KEY (pla_vac_id) REFERENCES Planificacion_Vacacion(pla_vac_id) ON DELETE RESTRICT
);

-- Crear tabla Catalogo_Permisos
CREATE TABLE Catalogo_Permisos (
  cat_per_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  cat_per_tipo ENUM('Enfermedad', 'Maternidad', 'Paternidad', 'Duelo', 'Asunto Personal', 'Estudios', 'Actividad Politica', 'Vacaciones') NOT NULL,
  cat_per_descripcion TEXT DEFAULT NULL,
  cat_per_periodo YEAR NOT NULL,
  cat_per_numero_dias INT UNSIGNED  DEFAULT 0,
  cat_per_numero_horas INT UNSIGNED  DEFAULT 0,
  cat_per_justificacion BOOLEAN DEFAULT FALSE
);

-- Crear tabla Permiso
CREATE TABLE Permiso (
  perm_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  cat_per_id INT UNSIGNED NOT NULL,
  vac_sol_id INT UNSIGNED DEFAULT NULL,
  pers_cedula INT UNSIGNED  NOT NULL,
  perm_numero_oficio INT UNSIGNED NOT NULL UNIQUE,
  perm_cedula_autoriza VARCHAR(50) DEFAULT NULL,
  perm_nombre_autoriza VARCHAR(50) DEFAULT NULL,
  perm_fecha_registro DATETIME NOT NULL,
  perm_fecha_pedido DATETIME NOT NULL,
  perm_fecha_hora_inicio DATETIME NOT NULL,
  perm_fecha_hora_fin DATETIME NULL,
  perm_duracion_dias INT UNSIGNED  DEFAULT 0,
  perm_duracion_horas INT UNSIGNED  DEFAULT 0,
  perm_remuneracion ENUM('Si', 'No') DEFAULT 'No',
  perm_observacion TEXT DEFAULT NULL,
  perm_archivo_respaldo TEXT DEFAULT NULL,
  perm_estado_solicitud_permiso ENUM('Pendiente', 'Aprobada', 'Negada') DEFAULT 'Pendiente',
  perm_firma_jefe VARCHAR(50) DEFAULT NULL,
  perm_fecha_aprobacion DATETIME DEFAULT NULL,
  perm_estado ENUM('Pendiente', 'En curso', 'Finalizado') DEFAULT 'Pendiente',
  FOREIGN KEY (cat_per_id) REFERENCES Catalogo_Permisos(cat_per_id) ON DELETE RESTRICT,
  FOREIGN KEY (vac_sol_id) REFERENCES Vacacion_Solicitud(vac_sol_id) ON DELETE RESTRICT,
  FOREIGN KEY (pers_cedula) REFERENCES Personal(pers_cedula) ON DELETE RESTRICT
);

-- Crear tabla Ausente
CREATE TABLE Ausente (
  aus_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  perm_id INT UNSIGNED UNIQUE NOT NULL,
  aus_cedula_jefe VARCHAR(50) DEFAULT 'Completar',
  aus_firma_jefe VARCHAR(50) DEFAULT 'Completar',
  aus_estado BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (perm_id) REFERENCES Permiso(perm_id) ON DELETE RESTRICT
);

-- Crear tabla Auditoria
CREATE TABLE Auditoria (
  aud_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  aud_usuario VARCHAR(50),
  aud_fecha DATETIME,
  aud_nombre_tabla VARCHAR(150),
  aud_accion VARCHAR(150),
  aud_dato_actual VARCHAR(1000),
  aud_dato_modificado VARCHAR(1000),
  aud_justificacion TEXT 
);

-- Crear tabla Login_Sistema
CREATE TABLE Login_Sistema (
  log_sis_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  log_sis_usuario VARCHAR(50),
  log_sis_fecha_hora_ingreso DATETIME,
  log_sis_id_sesion VARCHAR(36) NOT NULL
);


CREATE TABLE Correo (
  co_id INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  co_nombre_solicitud VARCHAR(150) NOT NULL,
  co_accion VARCHAR(150) NOT NULL
);