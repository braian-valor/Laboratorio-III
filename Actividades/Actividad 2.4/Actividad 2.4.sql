-- 1) La patente, apellidos y nombres del agente que labró la multa y monto de aquellas multas que superan el monto promedio.
Select 
	M.Patente,
	A.Apellidos,
	A.Nombres,
	M.Monto
From Multas M
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Where M.Monto > (
	Select AVG(Monto) From Multas 
)
Go

-- 2) Las multas que sean más costosas que la multa más costosa por 'No respetar señal de stop'.
Select * From Multas Where Monto > (
	Select MAX(M.Monto) From Multas M
	Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
	Where TI.Descripcion Like 'No respetar señal de stop'
)
Go

-- 3) Los apellidos y nombres de los agentes que no hayan labrado multas en los dos primeros meses de 2023.
Select
	A.Apellidos,
	A.Nombres
From Agentes A Where A.IDAgente Not In (
	Select Distinct M.IDAgente From Multas M Where MONTH(M.FechaHora) = 1 Or MONTH(M.FechaHora) = 2 
)
Go

-- 4) Los apellidos y nombres de los agentes que no hayan labrado multas por 'Exceso de velocidad'.
Select 
	A.Apellidos,
	A.Nombres
From Agentes A
Where A.IDAgente Not In(
	Select Distinct M.IDAgente From Multas M
	Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
	Where TI.Descripcion Like 'Exceso de velocidad'
)
Go

-- 5) Los legajos, apellidos y nombre de los agentes que hayan labrado multas de todos los tipos de infracciones existentes.
Select A.Legajo, A.Apellidos, A.Nombres 
From Agentes A
Where (
	Select COUNT(Distinct IDTipoInfraccion) From Multas Where IDAgente = A.IDAgente
) = (
	Select COUNT(IDTipoInfraccion) From TipoInfracciones
)
Go

-- 6) Los legajos, apellidos y nombres de los agentes que hayan labrado más cantidad de multas que la cantidad de multas generadas por un radar (multas con IDAgente con valor NULL).
Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres
From Agentes A
Where (
	Select COUNT(*) From Multas M Where M.IDAgente is Not NULL And M.IDAgente = A.IDAgente
) > (
	Select COUNT(*) From Multas Where IDAgente is NULL
)
Go

-- 7) Por cada agente, listar legajo, apellidos, nombres, cantidad de multas realizadas durante el día y cantidad de multas realizadas durante la noche.
-- NOTA: El turno noche ocurre pasadas las 20:00 y antes de las 05:00.
Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres,
	(
		Select COUNT(*) From Multas 
		Where CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00' And IDAgente = A.IDAgente
	) as CantidadMultasDia,
	(
		Select COUNT(*) From Multas 
		Where Not (CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00') And IDAgente = A.IDAgente
	) as CantidadMultasNoche
From Agentes A
Go

-- 8) Por cada patente, el total acumulado de pagos realizados con medios de pago no electrónicos y el total acumulado de pagos realizados con algún medio de pago electrónicos.
Select Distinct M.Patente,
	ISNULL
	(
		(		
			Select SUM(P.Importe) From Pagos P
			Inner Join MediosPago MP ON P.IDMedioPago = MP.IDMedioPago
			Inner Join Multas M2 on P.IDMulta = M2.IDMulta
			Where MP.Nombre Like 'Efectivo' And M2.Patente = M.Patente
		), 0
	) as TotalAcumuladoPagosNoElectronicos,
	ISNULL
	(
		(		
			Select SUM(P.Importe) From Pagos P
			Inner Join MediosPago MP ON P.IDMedioPago = MP.IDMedioPago
			Inner Join Multas M2 on P.IDMulta = M2.IDMulta
			Where MP.Nombre Not Like 'Efectivo' And M2.Patente = M.Patente
		), 0
	) as TotalAcumuladoPagosElectronicos
From Multas M
Go

-- 9) La cantidad de agentes que hicieron igual cantidad de multas por la noche que durante el día.
Select 
	COUNT(*) as 'Cantidad de agentes que hicieron igual cantidad de multas en ambos turnos'
From
(Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres,
	(
		Select COUNT(*) From Multas 
		Where CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00' And IDAgente = A.IDAgente
	) as CantidadMultasDia,
	(
		Select COUNT(*) From Multas 
		Where Not (CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00') And IDAgente = A.IDAgente
	) as CantidadMultasNoche
From Agentes A) as Aux
Where Aux.CantidadMultasDia = CantidadMultasNoche
Go

-- Modificar
-- 10) Las patentes que, en total, hayan abonado más en concepto de pagos con medios no electrónicos que pagos con medios electrónicos. Pero debe haber abonado tanto con medios de pago electrónicos como con medios de pago no electrónicos.
Select Aux.Patente From 
(Select Distinct M.Patente,
	ISNULL
	(
		(		
			Select SUM(P.Importe) From Pagos P
			Inner Join MediosPago MP ON P.IDMedioPago = MP.IDMedioPago
			Inner Join Multas M2 on P.IDMulta = M2.IDMulta
			Where MP.Nombre Like 'Efectivo' And M2.Patente = M.Patente
		), 0
	) as TotalAcumuladoPagosNoElectronicos,
	ISNULL
	(
		(		
			Select SUM(P.Importe) From Pagos P
			Inner Join MediosPago MP ON P.IDMedioPago = MP.IDMedioPago
			Inner Join Multas M2 on P.IDMulta = M2.IDMulta
			Where MP.Nombre Not Like 'Efectivo' And M2.Patente = M.Patente
		), 0
	) as TotalAcumuladoPagosElectronicos
From Multas M) as Aux
Where aux.TotalAcumuladoPagosNoElectronicos > aux.TotalAcumuladoPagosElectronicos
Go

-- 11) Los legajos, apellidos y nombres de agentes que hicieron más de dos multas durante el día y ninguna multa durante la noche.
Select 
	Aux.Legajo,
	Aux.Apellidos,
	Aux.Nombres
From
(Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres,
	(
		Select COUNT(*) From Multas 
		Where CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00' And IDAgente = A.IDAgente
	) as CantidadMultasDia,
	(
		Select COUNT(*) From Multas 
		Where Not (CONVERT(nvarchar(5), FechaHora, 108) > '05:00' And CONVERT(nvarchar(5), FechaHora, 108) < '20:00') And IDAgente = A.IDAgente
	) as CantidadMultasNoche
From Agentes A) as Aux
Where Aux.CantidadMultasDia > 2 And Aux.CantidadMultasNoche = 0
Go

-- 12) La cantidad de agentes que hayan registrado más multas que la cantidad de multas generadas por un radar (multas con IDAgente con valor NULL).
Select 
	COUNT(*) as 'Cantidad de agentes con mas multas que el radar'
From 
(Select 
	A.Legajo,
	A.Apellidos,
	A.Nombres,
	(
		Select COUNT(*) From Multas M Where M.IDAgente is Not NULL And M.IDAgente = A.IDAgente
	) as CantidadMultasAgente,
	(
		Select COUNT(*) From Multas Where IDAgente is NULL
	) as CantidadMultasRadar
From Agentes A) as Aux
Where Aux.CantidadMultasAgente > aux.CantidadMultasRadar
Go


Select * From Agentes
Select  * From Multas order by Patente asc
Select * From Provincias 
Select * From Localidades
Select * From Pagos 
Select * From MediosPago
Select * From TipoInfracciones