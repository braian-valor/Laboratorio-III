-- Para que una captura sea tenida en cuenta en el torneo, debe pertenecer a una especie registrada en la tabla de Especies.

-- A) El trofeo de oro del torneo es para aquel que haya capturado el pez más pesado entre todos los peces. Puede haber más de un ganador del trofeo. Listar Apellido y nombre, especie de pez que capturó y el pesaje del mismo.
Select Top 1 With Ties 
	P.APELLIDO,
	P.NOMBRE,
	E.ESPECIE,
	C.PESO
From PARTICIPANTES P
Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
Inner Join ESPECIES E ON C.IDESPECIE = E.IDESPECIE
Order by C.PESO Desc
Go

-- B) Listar todos los participantes que no hayan pescado ningún tipo de bagre.
Select * From PARTICIPANTES Where IDPARTICIPANTE Not In(
	Select Distinct P.IDPARTICIPANTE
	From PARTICIPANTES P
	Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
	Inner Join ESPECIES E ON C.IDESPECIE = E.IDESPECIE
	Where E.ESPECIE Like '%BAGRE%'
)
Go

-- C) Listar los participantes cuyo promedio de pesca (en kilos) sea mayor a 20. Listar apellido, nombre y promedio de kilos.
Select 
	P.IDPARTICIPANTE,
	P.APELLIDO,
	P.NOMBRE,
	AVG(C.PESO) as 'Promedio de Kilos'
From PARTICIPANTES P
Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
Inner Join ESPECIES E ON C.IDESPECIE = E.IDESPECIE
Group by P.IDPARTICIPANTE, P.APELLIDO, P.NOMBRE
Having AVG(C.PESO) > 20
Go

-- D) Por cada especie, listar la cantidad de participantes que la han capturado.
Select
	E.ESPECIE,
	COUNT(Distinct C.IDPARTICIPANTE) as 'Cantidad de participantes que lo capturaron'
From ESPECIES E
Left Join CAPTURAS C ON E.IDESPECIE = C.IDESPECIE
Group by E.ESPECIE
Go

-- E) Listar apellido y nombre del participante y nombre de la especie de cada pez que haya capturado el pescador/a. Si alguna especie de pez no ha sido pescado nunca entonces deberá aparecer en el listado de todas formas pero sin relacionarse con ningún pescador. El listado debe aparecer ordenado por nombre de especie de manera creciente. La combinación apellido y nombre y nombre de la especie debe aparecer sólo una vez este listado.
Select Distinct
	P.APELLIDO,
	P.NOMBRE,
	E.ESPECIE
From PARTICIPANTES P
Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
Right Join ESPECIES E ON C.IDESPECIE = E.IDESPECIE
Order by E.ESPECIE asc
Go

-- F) El trofeo de plata de la competencia se lo adjudica quien haya capturado la mayor cantidad de kilos en total y nunca haya capturado un pez por debajo del peso mínimo de la especie.
Select Top 1
	P.IDPARTICIPANTE,
	P.APELLIDO,
	P.NOMBRE,
	SUM(C.PESO) as CantKilosTotal
From PARTICIPANTES P
Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
Where C.IDESPECIE Is Not Null And P.IDPARTICIPANTE Not In(
	Select Distinct P.IDPARTICIPANTE
	From PARTICIPANTES P
	Inner Join CAPTURAS C ON P.IDPARTICIPANTE = C.IDPARTICIPANTE
	Inner Join ESPECIES E ON C.IDESPECIE = E.IDESPECIE
	Where C.PESO < E.PESO_MINIMO
)
Group by P.IDPARTICIPANTE, P.APELLIDO, P.NOMBRE
Order by CantKilosTotal Desc
Go

