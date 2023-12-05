--Mostrar todo el detalle de la matricula de los estudiantes, ordenar por numero de cuenta o código. Utilizar joins y mostrar los
--siguientes campos:
--Código del alumno
--Número de cuenta
--Nombre completo del alumno
--Codigo alterno de la sección
--Hora de inicio (Formato con AM/PM)
--Hora final (Formato con AM/PM)
--Días
--Nombre de la asignatura
--Nombre completo del maestro
---Periodo
--- Estado de la matricula
select * from tbl_matricula;
SELECT * FROM TBL_aLUMNOS;
SELECT * FROM TBL_PERSONAS




SELECT A.CODIGO_ALUMNO,
       A.NUMERO_CUENTA,
       P.NOMBRE || ' ' || P.APELLIDO AS NOMBRE_COMPLETO,
       S.CODIGO_ALTERNO,
       TO_CHAR(S.HORA_INICIO, 'hh:mi am') AS HORA_INICIO,  
       TO_CHAR(S.HORA_FIN, 'hh:mi am') AS HORA_FIN,
       S.DIAS,
       ASG.NOMBRE_ASIGNATURA,
       P2.NOMBRE || ' ' || P2.APELLIDO AS NOMBRE_COMPLETO_MAESTRO,
       PR.NOMBRE_PERIODO,
       EM.NOMBRE_ESTADO
FROM TBL_MATRICULA M
INNER JOIN TBL_SECCION S ON M.CODIGO_SECCION = S.CODIGO_SECCION
INNER JOIN TBL_ASIGNATURAS ASG ON S.CODIGO_ASIGNATURA = ASG.CODIGO_ASIGNATURA  
INNER JOIN TBL_MAESTROS MS ON S.CODIGO_MAESTRO = MS.CODIGO_MAESTRO
INNER JOIN TBL_PERSONAS P2 ON MS.CODIGO_MAESTRO = P2.CODIGO_PERSONA
INNER JOIN TBL_PERIODOS PR ON S.CODIGO_PERIODO = PR.CODIGO_PERIODO 
INNER JOIN TBL_ALUMNOS A ON M.CODIGO_ALUMNO = A.CODIGO_ALUMNO
INNER JOIN TBL_PERSONAS P ON A.CODIGO_ALUMNO = P.CODIGO_PERSONA  
INNER JOIN TBL_ESTADOS_MATRICULA EM ON M.CODIGO_ESTADO_MATRICULA = EM.CODIGO_ESTADO_MATRICULA
ORDER BY A.NUMERO_CUENTA, A.CODIGO_ALUMNO


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

 
 SELECT INITCAP(P.NOMBRE || ' ' || P.APELLIDO) AS NOMBRE_COMPLETO,  
       C.NOMBRE_CAMPUS AS CAMPUS_ACTUAL,
       L.NOMBRE_LUGAR AS LUGAR_NACIMIENTO,
       L2.NOMBRE_LUGAR AS LUGAR_RESIDENCIA,       
       (SELECT COUNT(*) 
        FROM TBL_HISTORIAL H
        INNER JOIN TBL_DETALLE_EVALUACION DE ON H.CODIGO_HISTORIAL = DE.CODIGO_HISTORIAL
        WHERE H.CODIGO_ALUMNO = A.CODIGO_ALUMNO
        AND DE.VALOR_NOTA >= 65) AS ASIGNATURAS_APROBADAS,
       (SELECT COUNT(*)
        FROM TBL_HISTORIAL H
        INNER JOIN TBL_DETALLE_EVALUACION DE ON H.CODIGO_HISTORIAL = DE.CODIGO_HISTORIAL
        WHERE H.CODIGO_ALUMNO = A.CODIGO_ALUMNO
        AND DE.VALOR_NOTA < 65) AS ASIGNATURAS_REPROBADAS,
       (SELECT COUNT(*) 
        FROM TBL_CARRERAS_X_ALUMNOS 
        WHERE CODIGO_ALUMNO = A.CODIGO_ALUMNO) AS CARRERAS_MATRICULADAS,
       TRUNC(SYSDATE - P.FECHA_NACIMIENTO) AS DIAS_TRANSCURRIDOS   
FROM TBL_ALUMNOS A, TBL_PERSONAS P, TBL_CAMPUS C, 
     TBL_LUGARES L, TBL_LUGARES L2
WHERE A.CODIGO_ALUMNO = P.CODIGO_PERSONA
AND P.CODIGO_CAMPUS = C.CODIGO_CAMPUS  
AND P.CODIGO_LUGAR_NACIMIENTO = L.CODIGO_LUGAR(+)
AND P.CODIGO_LUGAR_RESIDENCIA = L2.CODIGO_LUGAR(+)


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


WITH StudentInfo AS (
  SELECT
    P.CODIGO_PERSONA,
    INITCAP(P.NOMBRE || ' ' || P.APELLIDO) AS NOMBRE_COMPLETO,
    Z.CODIGO_CARRERA,
    Z.CODIGO_ALUMNO,
    COUNT(DISTINCT H.CODIGO_ASIGNATURA) AS CANTIDAD_ASIGNATURAS,
    SUM(H.UV * H.PROMEDIO) / SUM(H.UV) AS PROMEDIO_CARRERA
  FROM
    TBL_PERSONAS P
    JOIN TBL_CARRERAS_X_ALUMNOS Z ON P.CODIGO_PERSONA = Z.CODIGO_ALUMNO
    JOIN TBL_HISTORIAL H ON P.CODIGO_PERSONA = H.CODIGO_ALUMNO
  GROUP BY
    P.CODIGO_PERSONA, P.NOMBRE, P.APELLIDO, Z.CODIGO_CARRERA, Z.CODIGO_ALUMNO
)
SELECT
  NOMBRE_COMPLETO,
  NUMERO_CUENTA,
  C.NOMBRE_CARRERA AS CARRERA,
  CANTIDAD_ASIGNATURAS,
  PROMEDIO_CARRERA
FROM
  StudentInfo SI
  JOIN TBL_CARRERAS C ON SI.CODIGO_CARRERA = C.CODIGO_CARRERA
WHERE
  SI.PROMEDIO_CARRERA BETWEEN 90 AND 94;


--Mostrar todas las carreras con la siguiente información:
--Código auxiliar de la carrera
--Nombre de la carrera
--Cantidad de asignaturas (No utilizar el campo de la tabla de carreras, calcularlo)
--Cantidad de unidades valorativas de la carrera (No utilizar el campo de la tabla de carreras, calcularlo)
--Cantidad de estudiantes
--Promedio en base del promedio de los estudiantes (Usar el campo promedio carrera de los estudiantes)
--Grado de la carrera
--Nombre del estudiante con mejor promedio (Usar el campo promedio carrera de los estudiantes)

SELECT C.NOMBRE_CARRERA,
       C.CODIGO_AUXILIAR,
       COUNT(DISTINCT A.CODIGO_ASIGNATURA) AS CANTIDAD_ASIGNATURAS,
       SUM (A.CANTIDAD_UNIDADES_VALORATIVAS)AS UV_CANTIDAD,
       COUNT(CXA.CODIGO_ALUMNO) AS TOTAL_ESTUDIANTES
      
       
    
    
FROM 
    TBL_CARRERAS C
    LEFT JOIN TBL_CARRERAS_X_ALUMNOS CXA ON (C.CODIGO_CARRERA = CXA.CODIGO_CARRERA)
    LEFT JOIN TBL_HISTORIAL H ON (CXA.CODIGO_ALUMNO = H.CODIGO_ALUMNO)
    LEFT JOIN TBL_ASIGNATURAS A ON (C.CODIGO_CARRERA = A.CODIGO_CARRERA)
    LEFT JOIN TBL_PERSONAS P ON (CXA.CODIGO_ALUMNO = P.CODIGO_PERSONA)
    
    GROUP BY C.NOMBRE_CARRERA,
       C.CODIGO_AUXILIAR



SELECT *
FROM  TBL_CARRERAS_X_ALUMNOS B

WITH CareerInfo AS (
  SELECT
    C.CODIGO_AUXILIAR,
    C.NOMBRE_CARRERA,
    COUNT(DISTINCT A.CODIGO_ASIGNATURA) AS CANTIDAD_ASIGNATURAS,
    SUM(A.UNIDADES_VALORATIVAS) AS CANTIDAD_UV,
    COUNT(DISTINCT CXA.CODIGO_ALUMNO) AS CANTIDAD_ESTUDIANTES,
    AVG(CXA.PROMEDIO_CARRERA) AS PROMEDIO_CARRERA,
    C.GRADO_CARRERA,
    FIRST_VALUE(P.NOMBRE || ' ' || P.APELLIDO) WITHIN GROUP (ORDER BY CXA.PROMEDIO_CARRERA DESC) AS MEJOR_PROMEDIO_NOMBRE
  FROM
    TBL_CARRERAS C
    LEFT JOIN TBL_CARRERAS_X_ALUMNOS CXA ON (C.CODIGO_CARRERA = CXA.CODIGO_CARRERA)
    LEFT JOIN TBL_HISTORIAL H ON (CXA.CODIGO_ALUMNO = H.CODIGO_ALUMNO)
    LEFT JOIN TBL_ASIGNATURAS A ON (H.CODIGO_ASIGNATURA = A.CODIGO_ASIGNATURA)
    LEFT JOIN TBL_PERSONAS P ON (CXA.CODIGO_ALUMNO = P.CODIGO_PERSONA)
  GROUP BY
    C.CODIGO_AUXILIAR, C.NOMBRE_CARRERA, C.GRADO_CARRERA
)
SELECT
  CI.CODIGO_AUXILIAR,
  CI.NOMBRE_CARRERA,
  CI.CANTIDAD_ASIGNATURAS,
  CI.CANTIDAD_UV,
  CI.CANTIDAD_ESTUDIANTES,
  CI.PROMEDIO_CARRERA,
  CI.GRADO_CARRERA,
  CI.MEJOR_PROMEDIO_NOMBRE AS MEJOR_PROMEDIO_ESTUDIANTE
FROM
  CareerInfo CI;
