-- Utilizar la base de datos
USE gestion_personal;
CREATE VIEW view_formulario_solicitud AS
SELECT
  e.em_nombre AS NombreEmpresa,
  p.pers_nombre AS NombresEmpleado,
  sv.sal_vac_periodo AS PeriodoVacaciones,
  p.pers_cargo AS Cargo,
  v.vac_sol_fecha_desde AS FechaDesde,
  v.vac_sol_dias_tomados AS NumeroDias,
  v.vac_sol_firma_empleado AS FirmaEmpleado,
  v.vac_sol_firma_jefe AS FirmaJefe
FROM
  Empresa e
  JOIN Empresa_Departamento ed ON e.em_id = ed.em_id
  JOIN Departamento d ON ed.dep_id = d.dep_id
  JOIN Personal p ON ed.em_dep_id = p.em_dep_id
  JOIN Vacacion_Solicitud v ON p.pers_cedula = v.pers_cedula
  JOIN Saldo_Vacacion sv ON p.pers_cedula = sv.pers_cedula;

CREATE VIEW view_informe_periodos AS
SELECT
  e.em_nombre AS NombreEmpresa,
  p.pers_nombre AS NombresEmpleado,
  sv.sal_vac_periodo AS PeriodoVacaciones,
  sv.sal_vac_dias_tomados AS DiasOcupados,
  sv.sal_vac_dias_anio_actual AS DiasPendientes,
  sv.sal_vac_dias_tomados AS TotalDiasOcupados,
  sv.sal_vac_dias_disponibles AS TotalDiasPendientes
FROM
  Empresa e
  JOIN Empresa_Departamento ed ON e.em_id = ed.em_id
  JOIN Departamento d ON ed.dep_id = d.dep_id
  JOIN Personal p ON ed.em_dep_id = p.em_dep_id
  JOIN Saldo_Vacacion sv ON p.pers_cedula = sv.pers_cedula;

CREATE VIEW view_informe_vacaciones_area AS
SELECT
  e.em_nombre AS NombreEmpresa,
  d.dep_nombre AS Area,
  p.pers_nombre AS NombreEmpleado,
  vs.vac_sol_fecha_desde AS FechaDesde,
  vs.vac_sol_fecha_hasta AS FechaHasta,
  vs.vac_sol_dias_tomados AS NumeroDias,
  p.pers_backup_principal AS Reemplazo
FROM
  Empresa e
  JOIN Empresa_Departamento ed ON e.em_id = ed.em_id
  JOIN Departamento d ON ed.dep_id = d.dep_id
  JOIN Personal p ON ed.em_dep_id = p.em_dep_id
  JOIN Vacacion_Solicitud vs ON p.pers_cedula = vs.pers_cedula
WHERE
  vs.vac_sol_estado = 'Aprobada'
ORDER BY
  d.dep_nombre;

-- drop view view_informe_ausentismos_area_sin_vacacion;
-- Create the new view
CREATE VIEW view_informe_ausentismos_area_sin_vacacion AS
SELECT e.em_nombre AS Empresa,
       cp.cat_per_periodo AS Periodo,
       cp.cat_per_tipo AS TipoAusentismo,
       d.dep_nombre AS Area,
       ROUND(SUM(pe.perm_duracion_dias), 2) AS 'Total días de ausentismo',
       CASE
           WHEN t.total_dias_categ = 0 THEN '0.00%'  -- If total_dias_categ is 0, set the percentage to 0%
           ELSE CONCAT(ROUND((SUM(pe.perm_duracion_dias) / t.total_dias_categ) * 100, 2), '%')
       END AS 'Porcentaje en referencia al total de días de todas las áreas'
FROM Ausente aus
JOIN Permiso pe ON aus.perm_id = pe.perm_id
JOIN Catalogo_Permisos cp ON pe.cat_per_id = cp.cat_per_id
JOIN Personal p ON pe.pers_cedula = p.pers_cedula
JOIN Empresa_Departamento ed ON p.em_dep_id = ed.em_dep_id
JOIN Departamento d ON ed.dep_id = d.dep_id
JOIN Empresa e ON ed.em_id = e.em_id
JOIN (
    SELECT cp.cat_per_tipo AS Categoria, SUM(pe.perm_duracion_dias) AS total_dias_categ
    FROM Ausente aus
    JOIN Permiso pe ON aus.perm_id = pe.perm_id
    JOIN Catalogo_Permisos cp ON pe.cat_per_id = cp.cat_per_id
    GROUP BY cp.cat_per_tipo
) AS t ON cp.cat_per_tipo = t.Categoria
WHERE cp.cat_per_tipo != 'Vacaciones'
GROUP BY e.em_id, cp.cat_per_periodo, cp.cat_per_tipo, d.dep_nombre, t.total_dias_categ;

CREATE VIEW view_informe_ausentismos_area_sin_vacacion_2 AS
SELECT d.dep_nombre AS Area,
       CASE
           WHEN p.pers_cedula_jefe IS NULL THEN 'Jefe de Área'
           ELSE (SELECT pers_nombre FROM Personal WHERE pers_cedula = p.pers_cedula_jefe)
       END AS JefeArea,
       CONCAT(p.pers_nombre, ' (', p.pers_cedula, ')') AS Empleado,
       cp.cat_per_tipo AS TipoAusentismo,
       SUM(pe.perm_duracion_dias) AS Dias,
       SUM(pe.perm_duracion_dias) AS 'Total días por empleado',
       SUM(pe.perm_duracion_dias) AS 'Total días por área'
FROM Departamento d
LEFT JOIN Empresa_Departamento ed ON d.dep_id = ed.dep_id
LEFT JOIN Personal p ON ed.em_dep_id = p.em_dep_id
LEFT JOIN Permiso pe ON p.pers_cedula = pe.pers_cedula
LEFT JOIN Catalogo_Permisos cp ON pe.cat_per_id = cp.cat_per_id
WHERE cp.cat_per_tipo != 'Vacaciones' AND pe.perm_estado_solicitud_permiso = 'Aprobada'
GROUP BY d.dep_id, p.pers_cedula, cp.cat_per_tipo;

