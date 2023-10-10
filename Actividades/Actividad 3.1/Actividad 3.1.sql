-- 1) Crear una vista llamada VW_Multas que permita visualizar la información de las multas con los datos del agente incluyendo apellidos y nombres, nombre de la localidad, patente del vehículo, fecha y monto de la multa.
Create View VW_Multas
as
Select M.IDMulta, L.Localidad, M.IDTipoInfraccion, A.Apellidos, A.Nombres, M.Patente, M.Monto, M.FechaHora, M.Pagada
From Multas M
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Go

Select * From VW_Multas
Go

-- 2) Modificar la vista VW_Multas para incluir el legajo del agente, la antigüedad en años, el nombre de la provincia junto al de la localidad y la descripción del tipo de multa.
Alter View VW_Multas
as
Select M.IDMulta, L.Localidad, P.Provincia, TI.Descripcion as 'Tipo de Multa', A.Legajo, A.Apellidos, A.Nombres, 
	DATEDIFF(YEAR, A.FechaIngreso, GETDATE()) as 'Antiguedad',
	M.Patente, 
	M.Monto, 
	M.FechaHora, 
	M.Pagada
From Multas M
Inner Join Agentes A ON M.IDAgente = A.IDAgente
Inner Join Localidades L ON M.IDLocalidad = L.IDLocalidad
Inner Join Provincias P ON L.IDProvincia = P.IDProvincia
Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
Go

Select * From VW_Multas
Go

-- 3) Crear un procedimiento almacenado llamado SP_MultasVehiculo que reciba un parámetro que representa la patente de un vehículo. Listar las multas que registra. Indicando fecha y hora de la multa, descripción del tipo de multa e importe a abonar. También una leyenda que indique si la multa fue abonada o no.
Create Procedure SP_MultasVehiculo(
	@Patente varchar(10)
)
as
Begin
	Begin Try
		Select M.IDMulta, M.FechaHora, TI.Descripcion as 'Tipo de Infracion', M.Monto as 'Importe a abonar',
		Case
			When SUM(P.Importe) >= M.Monto Then 'Abonada'
			Else 'No Abonada'
		End as 'Leyenda'
		From Multas M
		Inner Join TipoInfracciones TI ON M.IDTipoInfraccion = TI.IDTipoInfraccion
		Left Join Pagos P ON M.IDMulta = P.IDMulta
		Where M.Patente = @Patente
		Group by M.IDMulta, M.FechaHora, TI.Descripcion, M.Monto
	End Try

	Begin Catch
		Raiserror('No se pudo encontrar la multa', 16, 0)
	End Catch
End
Go

Exec SP_MultasVehiculo 'DEF456'
Go

-- 4) Crear una función que reciba un parámetro que representa la patente de un vehículo y devuelva el total adeudado por ese vehículo en concepto de multas.
Create Function FN_1(
	@Patente varchar(10)
)
Returns Money
as
Begin
	Declare @TotalAdeudado money
	Set @TotalAdeudado = (Select SUM(M.Monto) From Multas M Where M.Patente = @Patente)
	Return @TotalAdeudado
End
Go

Select Distinct Patente, dbo.FN_1(Patente) From Multas
Go
Select dbo.FN_1('CDE567') 
Go

-- 5) Crear una función que reciba un parámetro que representa la patente de un vehículo y devuelva el total abonado por ese vehículo en concepto de multas.
Create Function FN_2(
	@Patente varchar(10)
)
Returns money
as
Begin
	Declare @TotalAbonado money
	Set @TotalAbonado = (Select SUM(P.Importe) From Multas M Inner Join Pagos P ON M.IDMulta = P.IDMulta Where M.Patente = @Patente)
	Return @TotalAbonado
End
Go

Select Distinct M.Patente, ISNULL(dbo.FN_2(M.Patente), 0) as 'Total Abonado' From Multas M 
Go

-- 6) Crear un procedimiento almacenado llamado SP_AgregarMulta que reciba IDTipoInfraccion, IDLocalidad, IDAgente, Patente, Fecha y hora, Monto a abonar y registre la multa.
Create Procedure SP_AgregarMulta(
	@ID_TipoInfraccion int,
	@ID_Localidad int,
	@ID_Agente int,
	@Patente varchar(10),
	@FechaHora datetime,
	@Monto money
)
as
Begin
	Begin Try	
		Insert Into Multas(IDLocalidad, IDTipoInfraccion, IDAgente, Patente, Monto, FechaHora, Pagada) 
		Values(@ID_Localidad, @ID_TipoInfraccion, @ID_Agente, @Patente, @Monto, @FechaHora, 0)
	End Try

	Begin Catch
		Raiserror('No se pudo registrar la multa', 16, 0)
	End Catch
End
Go

Declare @FechaHoraActual datetime
Set @FechaHoraActual = GETDATE()
Exec SP_AgregarMulta 1, 1, 1, 'BAV1677', @FechaHoraActual, 10000
Go

Select * From Multas
Go

-- 7) Crear un procedimiento almacenado llamado SP_ProcesarPagos que determine el estado Pagada de todas las multas a partir de los pagos que se encuentran registrados (La suma de todos los pagos de una multa debe ser igual o mayor al monto de la multa para considerarlo Pagado).
Create Procedure SP_ProcesarPagos
as
Begin
	Begin Try	

		Update Multas Set Pagada = 1 Where IDMulta In (
			Select Aux.IDMulta
			From
			(
			Select P.IDMulta, 
				SUM(P.Importe) as TotalAbonadoPorMulta,
				SUM(Distinct M.Monto) as TotalAdeudadoPorMulta
			From Multas M Left Join Pagos P ON M.IDMulta = P.IDMulta 
			Group by P.IDMulta
			) 
			as Aux 
			Where Aux.TotalAbonadoPorMulta >= Aux.TotalAdeudadoPorMulta
		)
		
	End Try

	Begin Catch
		Raiserror('No se pudo procesar los pagos', 16, 0)
	End Catch
End
Go

Exec SP_ProcesarPagos

Select * From Pagos
Select * From Multas
Go

Select Aux.IDMulta
From
(
Select P.IDMulta, 
	SUM(P.Importe) as TotalAbonadoPorMulta,
	SUM(Distinct M.Monto) as TotalAdeudadoPorMulta
From Multas M Left Join Pagos P ON M.IDMulta = P.IDMulta 
Group by P.IDMulta
) 
as Aux 
Where Aux.TotalAbonadoPorMulta >= Aux.TotalAdeudadoPorMulta
Go

-- total adeudado por cada MULTA
Select M.IDMulta, SUM(M.Monto) From Multas M Group by M.IDMulta
Go

--total abonado POR CADA MULTA
Select P.IDMulta, SUM(P.Importe) From Multas M Inner Join Pagos P ON M.IDMulta = P.IDMulta Group by P.IDMulta
Go
