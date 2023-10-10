-- 1) Listado con la cantidad de agentes.
Select COUNT(*) as 'Cantidad de Agentes' From Agentes
Go

-- 2) Listado con importe de referencia promedio de los tipos de infracciones.
Select AVG(ImporteReferencia) as 'Promedio de los tipos de infracciones' From TipoInfracciones
Go

-- 3) Listado con la suma de los montos de las multas. Indistintamente de si fueron pagadas o no.
Select SUM(Monto) as 'Monto Total de Multas' From Multas
Go

-- 4) Listado con la cantidad de pagos que se realizaron.
Select COUNT(*) as 'Cantidad de Pagos Realizados' From Pagos
Go

-- 5) Listado con la cantidad de multas realizadas en la provincia de Buenos Aires.
--	  NOTA: Utilizar el nombre 'Buenos Aires' de la provincia.
Select COUNT(*) as 'Cantidad de Multas en Buenos Aires'
From Multas M 
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Where L.Localidad Like 'La Plata'
Go

-- 6) Listado con el promedio de antigüedad de los agentes que se encuentren activos.
Select AVG(DATEDIFF(YEAR, FechaIngreso, GETDATE()) * 1.0) as 'Antiguedad Promedio de los Agentes Activos' From Agentes Where Activo = 1
Go

-- 7) Listado con el monto más elevado que se haya registrado en una multa.
Select MAX(Monto) as 'Monto mas Elevado en una Multa' From Multas 
Go

-- 8) Listado con el importe de pago más pequeño que se haya registrado.
Select MIN(Importe) as 'Importe de Pago mas Chico' From Pagos  
Go

-- 9) Por cada agente, listar Legajo, Apellidos y Nombres y la cantidad de multas que registraron.
Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres,
	COUNT(M.IDMulta) as 'Cantidad de Multas Registradas'
From Agentes A
Left Join Multas M ON A.IDAgente = M.IDAgente
Group by A.Legajo, A.Apellidos, A.Nombres
Go

-- 10) Por cada tipo de infracción, listar la descripción y el promedio de montos de las multas asociadas a dicho tipo de infracción.
Select TI.Descripcion, AVG(M.Monto) as 'Promedio de Multas'
From TipoInfracciones TI 
Inner Join Multas M ON TI.IDTipoInfraccion = M.IDTipoInfraccion
Group by TI.Descripcion
Go

-- 11) Por cada multa, indicar la fecha, la patente, el importe de la multa y la cantidad de pagos realizados. Solamente mostrar la información de las multas que hayan sido pagadas en su totalidad.
Select CAST(M.FechaHora as date) as 'Fecha', M.Patente, M.Monto, COUNT(P.IDMulta) as 'Cantidad de Pagos Realizados' 
From Multas M
Left Join Pagos P ON M.IDMulta = P.IDMulta
Group by M.FechaHora, M.Patente, M.Monto
Having SUM(M.Monto) <= SUM(P.Importe)
Go

-- 12) Listar todos los datos de las multas que hayan registrado más de un pago.
Select M.IDMulta, M.IDLocalidad, M.IDTipoInfraccion, M.IDAgente, M.Patente, M.Monto, M.FechaHora, M.Pagada 
From Multas M 
Inner Join Pagos P ON M.IDMulta = P.IDMulta
Group by M.IDMulta, M.IDLocalidad, M.IDTipoInfraccion, M.IDAgente, M.Patente, M.Monto, M.FechaHora, M.Pagada
Having COUNT(*) > 1
Go

-- 13) Listar todos los datos de todos los agentes que hayan registrado multas con un monto que en promedio que supere los $10000.
Select A.IDAgente, A.Legajo, A.Nombres, A.Apellidos, A.FechaNacimiento, A.FechaIngreso, A.Sueldo, A.Email, A.Telefono, A.Celular, A.Activo 
From Agentes A 
Inner Join Multas M ON A.IDAgente = M.IDAgente
Group by A.IDAgente, A.Legajo, A.Nombres, A.Apellidos, A.FechaNacimiento, A.FechaIngreso, A.Sueldo, A.Email, A.Telefono, A.Celular, A.Activo 
Having AVG(M.Monto) > 10000
Go

-- 14) Listar el tipo de infracción que más cantidad de multas haya registrado.
Select Top(1) TI.IDTipoInfraccion, TI.Descripcion, COUNT(*) as 'cantidadMultas'
From TipoInfracciones TI
Inner Join Multas M ON TI.IDTipoInfraccion = M.IDTipoInfraccion
Group by TI.IDTipoInfraccion, TI.Descripcion
Order by cantidadMultas desc
Go

-- 15) Listar por cada patente, la cantidad de infracciones distintas que se cometieron.
Select M.Patente, COUNT(Distinct M.IDTipoInfraccion) as 'Cantidad de Infracciones'
From Multas M 
Group by M.Patente
Go

-- 16) Listar por cada patente, el texto literal 'Multas pagadas' y el monto total de los pagos registrados por esa patente. Además, por cada patente, el texto literal 'Multas por pagar' y el monto total de lo que se adeuda.
Select
	M.IDMulta,
	M.Patente,
	M.FechaHora,
	M.Monto,
	ISNULL(SUM(P.Importe), 0) as 'Monto Total de Pagos Registrados',
	--ISNULL((SUM(P.Importe) - M.Monto), M.Monto) as 'Monto Total que se adeuda',
	Case
		When SUM(P.Importe) >= M.Monto Then 0
		Else M.Monto
	End as 'Monto Total que se adeuda',

	Case
		When SUM(P.Importe) >= M.Monto Then 'Multas Pagadas'
		Else 'Multas por Pagar'
	End as 'Estado'
From Multas M
Left Join Pagos P ON M.IDMulta = P.IDMulta
Group by M.IDMulta ,M.Patente, M.FechaHora, M.Monto
Order by M.Patente asc
Go

-- 17) Listado con los nombres de los medios de pagos que se hayan utilizado más de 3 veces.
Select 
	MP.Nombre
From MediosPago MP
Inner Join Pagos P ON MP.IDMedioPago = P.IDMedioPago
Group by MP.Nombre
Having COUNT(P.IDMedioPago) > 3
Go

-- 18) Los legajos, apellidos y nombres de los agentes que hayan labrado más de 2 multas con tipos de infracciones distintas.
Select
	A.Legajo,
	A.Apellidos,
	A.Nombres
From Agentes A
Inner Join Multas M ON A.IDAgente = M.IDAgente 
Group by A.IDAgente, A.Legajo, A.Apellidos, A.Nombres
Having COUNT(Distinct M.IDTipoInfraccion) > 2
Go

-- 19) El total recaudado en concepto de pagos discriminado por nombre de medio de pago.
Select 
	MP.Nombre,
	SUM(P.Importe) as 'Total Recaudado'
From Pagos P
Inner Join MediosPago MP ON P.IDMedioPago = MP.IDMedioPago
Group by MP.IDMedioPago, MP.Nombre
Go

-- 20) Un listado con el siguiente formato:

--	   Descripción		Tipo		Recaudado
--	   ------------		---------	---------
--	   Tigre			Localidad	$xxxx
--     San Fernando		Localidad	$xxxx
--     Rosario			Localidad	$xxxx
--     Buenos Aires		Provincia	$xxxx
--     Santa Fe			Provincia	$xxxx
--     Argentina		País		$xxxx



Select * From Provincias
Select * From Localidades
Select * From Multas order by IDLocalidad asc
Select * From Pagos 

Select * From MediosPago
Select * From TipoInfracciones
Select * From Agentes