-- 1) Listado con las localidades, su ID, nombre y el nombre de la provincia a la que pertenece.
Select 
	L.IDLocalidad,
	L.Localidad,
	P.Provincia
From Localidades L
Inner Join Provincias P ON L.IDProvincia = P.IDProvincia
Go

-- 2) Listado que informe el ID de la multa, el monto a abonar y los datos del agente que la realizó. Debe incluir los apellidos y nombres de los agentes. Así como también la fecha de nacimiento y la edad.
Select 
	M.IDMulta,
	M.Monto,
	A.Apellidos,
	A.Nombres,
	A.FechaNacimiento,
	DATEDIFF(YEAR, 0, GETDATE() - CAST(A.FechaNacimiento as datetime)) as 'Edad'
From Multas M
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Go

-- 3) Listar todos los datos de todas las multas realizadas por agentes que a la fecha de hoy tengan más de 5 años de antigüedad.
Select M.* From Multas M
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Where DATEDIFF(YEAR, FechaIngreso, GETDATE()) > 5
Go

-- 4) Listar todos los datos de todas las multas cuyo importe de referencia supere los $15000.
Select M.* From Multas M
Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
Where TI.ImporteReferencia > 15000
Go

-- 5) Listar los nombres y apellidos de los agentes, sin repetir, que hayan labrado multas en la provincia de Buenos Aires o en Cordoba.
Select distinct A.Nombres, A.Apellidos
From Agentes A
Inner Join Multas M ON A.IDAgente = M.IDAgente
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Inner Join Provincias P ON L.IDProvincia = P.IDProvincia
Where P.IDProvincia = 1 Or P.IDProvincia = 2
Go

-- 6) Listar los nombres y apellidos de los agentes, sin repetir, que hayan labrado multas del tipo "Exceso de velocidad".
Select A.Nombres, A.Apellidos
From Agentes A
Inner Join Multas M ON A.IDAgente = M.IDAgente
Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
Where TI.IDTipoInfraccion = 1
Go

-- 7) Listar apellidos y nombres de los agentes que no hayan labrado multas.
Select A.Apellidos, A.Nombres, M.IDAgente
From Agentes A
Left Join Multas M ON A.IDAgente = M.IDAgente
Where M.IDAgente Is Null
Go

-- 8) Por cada multa, lista el nombre de la localidad y provincia, el tipo de multa, los apellidos y nombres de los agentes y su legajo, el monto de la multa y la diferencia en pesos en relación al tipo de infracción cometida.
Select M.IDMulta, L.Localidad, P.Provincia, TI.Descripcion, A.Apellidos, A.Nombres, A.Legajo, M.Monto, TI.ImporteReferencia,
(M.Monto - TI.ImporteReferencia) as Diferencia
From Multas M
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Inner Join Provincias P ON L.IDProvincia = P.IDProvincia
Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Go

-- 9) Listar las localidades en las que no se hayan registrado multas.
Select L.IDLocalidad, L.Localidad From Localidades L
Left Join Multas M ON L.IDLocalidad = M.IDLocalidad
Where M.IDLocalidad Is Null
Go

-- 10) Listar los datos de las multas pagadas que se hayan labrado en la provincia de Buenos Aires.
Select 
	M.*
From Multas M
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Inner Join Provincias P ON L.IDProvincia = P.IDProvincia
Where P.IDProvincia = 1 And M.Pagada = 0
Go

-- 11) Listar el ID de la multa, la patente, el monto y el importe de referencia a partir del tipo de infracción cometida. También incluir una columna llamada TipoDeImporte a partir de las siguientes condiciones:

-- 'Punitorio' si el monto de la multa es mayor al importe de referencia
-- 'Leve' si el monto de la multa es menor al importe de referencia
-- 'Justo' si el monto de la multa es igual al importe de referencia
Select M.IDMulta, M.Patente, M.Monto, TI.Descripcion, TI.ImporteReferencia,
	Case
		When M.Monto > TI.ImporteReferencia Then 'Punitorio'
		When M.Monto < TI.ImporteReferencia Then 'Leve'
		When M.Monto = TI.ImporteReferencia Then 'Justo'
	End as 'Tipo de Importe'
From Multas M
Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
Go

select * From Agentes
select * From Localidades
select * From Multas 
select * From Provincias
select * From TipoInfracciones
Go