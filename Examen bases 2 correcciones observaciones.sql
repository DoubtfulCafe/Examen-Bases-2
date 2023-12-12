
--Mostrar el listado de los estudiantes con la siguiente información (Para los cruces utilizar productos cartesianos y el operador (+) y with
--en caso de usar subconsultas):
--Nombre completo con cada inicial en mayúscula.
--Campus actual.
--Lugar de nacimiento (No utilizar las tablas de municipio, departamento, etc).
--Lugar de residencia (No utilizar las tablas de municipio, departamento, etc).
--Cantidad de asignaturas aprobadas (promedio según historial >= 65)
--Cantidad de asignaturas reprobadas (promedio según historial < 65)
--Cantidad de carreras matriculadas
--La cantidad de días transcurridos desde su fecha de nacimiento

 SELECT c.nombre, a.promedio, d.nombre_asignatura ,d.cantidad_unidades_valorativas
FROM tbl_historial a
JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
JOIN tbl_personas c ON c.codigo_persona = a.codigo_alumno
JOIN tbl_asignaturas d ON d.codigo_asignatura=b.codigo_asignatura
WHERE codigo_alumno = 1;

SELECT 
    distinct(c.nombre) AS nombre_estudiante,
    
    (SELECT COUNT(*) FROM tbl_historial WHERE codigo_alumno = c.codigo_persona AND promedio >= 65) AS clases_aprobadas,
    (SELECT COUNT(*) FROM tbl_historial WHERE codigo_alumno = c.codigo_persona AND promedio < 65) AS clases_reprobadas
FROM 
    tbl_historial a
JOIN 
    tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
JOIN 
    tbl_personas c ON c.codigo_persona = a.codigo_alumno
JOIN 
    tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
WHERE 
    codigo_alumno = 1;

SELECT 
    INITCAP(B.NOMBRE || ' ' || B.APELLIDO) AS NOMBRE_COMPLETO,
    C.NOMBRE_CAMPUS AS CAMPUS_ACTUAL,
    D.NOMBRE_LUGAR AS LUGAR_NACIMIENTO,
    E.NOMBRE_LUGAR AS LUGAR_RESIDENCIA,       
    (
        SELECT COUNT(*) 
        FROM tbl_historial w
        WHERE w.codigo_alumno = b.codigo_persona 
        AND promedio >= 65
    ) AS ASIGNATURAS_APROBADAS,
    (
        SELECT COUNT(*)
        FROM tbl_historial w
        WHERE w.codigo_alumno = b.codigo_persona
        AND promedio < 65
    ) AS ASIGNATURAS_REPROBADAS,
    (
        SELECT COUNT(*) 
        FROM TBL_CARRERAS_X_ALUMNOS 
        WHERE CODIGO_ALUMNO = A.CODIGO_ALUMNO
    ) AS CARRERAS_MATRICULADAS,
    TRUNC(SYSDATE - B.FECHA_NACIMIENTO) AS DIAS_TRANSCURRIDOS   
FROM 
    TBL_ALUMNOS A
JOIN 
    TBL_PERSONAS B ON A.CODIGO_ALUMNO = B.CODIGO_PERSONA
JOIN 
    TBL_CAMPUS C ON B.CODIGO_CAMPUS = C.CODIGO_CAMPUS
LEFT JOIN 
    TBL_LUGARES D ON B.CODIGO_LUGAR_NACIMIENTO = D.CODIGO_LUGAR
LEFT JOIN 
    TBL_LUGARES E ON B.CODIGO_LUGAR_RESIDENCIA = E.CODIGO_LUGAR;
 

--Mostrar los alumnos con Magna Cum Laude (>= 90 promedio <=94) para cada carrera, puede darse el caso de que un estudiante tenga
--más de una carrera y en ambas sea Magna Cum Laude. Para este ejercicio NO utilizar el campo PROMEDIO_CARRERA de la tabla
--TBL_CARRERA_X_ALUMNOS, en su lugar hacer el cálculo del historial académico.
--(Para los cruces utilizar productos cartesianos y el operador (+) y with en caso de usar subconsultas):
--Información a mostrar:
--Nombre completo con cada inicial en mayúscula.
--Número de cuenta.
--Carrera
--Cantidad de asignaturas cursadas
-- Promedio para dicha carrera:  UV * Promedio por asignatura/Sumatoria del total de UV por carrera.


WITH 
    ClasesCursadas AS (
        SELECT
            codigo_alumno,
            COUNT(*) AS Cantidad_clases_cursadas
        FROM tbl_historial
        WHERE codigo_alumno = 1
        GROUP BY codigo_alumno
    ),

    UVTotales AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas) AS uv_totales
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    UVxPromedio AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) AS uv_x_promedio
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    TotalUVxPromedios AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) AS total_uv_x_promedios
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    PromedioPonderado AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) / SUM(d.cantidad_unidades_valorativas) AS promedio_ponderado
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    )

SELECT
    DISTINCT c.codigo_persona AS codigo_alumno,
    a.numero_cuenta,
    cxa.codigo_carrera,
    ca.nombre_carrera,
    INITCAP(c.nombre) || ' ' || INITCAP(c.apellido) AS nombre_completo,
    CC.Cantidad_clases_cursadas,
    PP.promedio_ponderado
FROM 
    tbl_personas c
JOIN 
    tbl_alumnos a ON c.codigo_persona = a.codigo_alumno
JOIN 
    tbl_carreras_x_alumnos cxa ON c.codigo_persona = cxa.codigo_alumno
JOIN 
    tbl_carreras ca ON cxa.codigo_carrera = ca.codigo_carrera
JOIN 
    ClasesCursadas CC ON c.codigo_persona = CC.codigo_alumno
LEFT JOIN 
    UVTotales UV ON c.codigo_persona = UV.codigo_alumno
LEFT JOIN 
    UVxPromedio UVxP ON c.codigo_persona = UVxP.codigo_alumno
LEFT JOIN
    TotalUVxPromedios TP ON c.codigo_persona = TP.codigo_alumno
LEFT JOIN
    PromedioPonderado PP ON c.codigo_persona = PP.codigo_alumno
WHERE
    PP.promedio_ponderado BETWEEN 90 AND 94;

---Almacenar el resultado de la consulta anterior en una tabla.
-- CREAMOS LA NUEVA TABLA
CREATE TABLE ALUMNOSXMAGNA (
    CODIGO_ALUMNO NUMBER,
    NOMBRE_COMPLETO VARCHAR2(255),
    NOMBRE_CARRERA VARCHAR2(255),
    PROMEDIO_PONDERADO NUMBER
);

-- INSERTAMOS LOS DATOS
INSERT INTO ALUMNOSXMAGNA (
    CODIGO_ALUMNO,
    NOMBRE_COMPLETO,
    NOMBRE_CARRERA,
    PROMEDIO_PONDERADO
)
--VOLVEMOS A ESCRIBIR EL SCRIPT PARA HACER UNA INSERSION CONTINUA
WITH 
    ClasesCursadas AS (
        SELECT
            codigo_alumno,
            COUNT(*) AS Cantidad_clases_cursadas
        FROM tbl_historial
        WHERE codigo_alumno = 1
        GROUP BY codigo_alumno
    ),

    UVTotales AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas) AS uv_totales
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    UVxPromedio AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) AS uv_x_promedio
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    TotalUVxPromedios AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) AS total_uv_x_promedios
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    ),

    PromedioPonderado AS (
        SELECT
            a.codigo_alumno,
            SUM(d.cantidad_unidades_valorativas * a.promedio) / SUM(d.cantidad_unidades_valorativas) AS promedio_ponderado
        FROM tbl_historial a
        JOIN tbl_seccion b ON a.codigo_seccion = b.codigo_seccion
        JOIN tbl_asignaturas d ON d.codigo_asignatura = b.codigo_asignatura
        WHERE a.codigo_alumno = 1
        GROUP BY a.codigo_alumno
    )

SELECT
    DISTINCT c.codigo_persona AS codigo_alumno,
    a.numero_cuenta,
    cxa.codigo_carrera,
    ca.nombre_carrera,
    INITCAP(c.nombre) || ' ' || INITCAP(c.apellido) AS nombre_completo,
    CC.Cantidad_clases_cursadas,
    PP.promedio_ponderado
FROM 
    tbl_personas c
JOIN 
    tbl_alumnos a ON c.codigo_persona = a.codigo_alumno
JOIN 
    tbl_carreras_x_alumnos cxa ON c.codigo_persona = cxa.codigo_alumno
JOIN 
    tbl_carreras ca ON cxa.codigo_carrera = ca.codigo_carrera
JOIN 
    ClasesCursadas CC ON c.codigo_persona = CC.codigo_alumno
LEFT JOIN 
    UVTotales UV ON c.codigo_persona = UV.codigo_alumno
LEFT JOIN 
    UVxPromedio UVxP ON c.codigo_persona = UVxP.codigo_alumno
LEFT JOIN
    TotalUVxPromedios TP ON c.codigo_persona = TP.codigo_alumno
LEFT JOIN
    PromedioPonderado PP ON c.codigo_persona = PP.codigo_alumno
WHERE
    PP.promedio_ponderado BETWEEN 90 AND 94;

SELECT * 
FROM ALUMNOSXMAGNA




--Mostrar que estudiantes tienen asignaturas matriculadas sin requisito
SELECT DISTINCT
    A.CODIGO_ALUMNO,
    INITCAP(P.NOMBRE || ' ' || P.APELLIDO) AS NOMBRE_COMPLETO
FROM
    TBL_ALUMNOS A
JOIN
    TBL_MATRICULA M ON A.CODIGO_ALUMNO = M.CODIGO_ALUMNO
JOIN
    TBL_PERSONAS P ON A.CODIGO_ALUMNO = P.CODIGO_PERSONA
WHERE
    M.CODIGO_ESTADO_MATRICULA = 1; 

    ---APENAS ESTABA PLANTEANDOLO 


