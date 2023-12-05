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


