-- 1) Hacer un trigger que al eliminar un Agente su estado Activo pase de True a False.
Create Trigger TR_BajaLogicaAgente ON Agentes
Instead of Delete
as
Begin
	Begin Try
		Begin Transaction

			Declare @IDAgente int
			Select @IDAgente = IDAgente From deleted

			Update Agentes Set Activo = 0 Where IDAgente = @IDAgente

		Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction
		Raiserror('No se pudo realizar la baja', 16, 0)
	End Catch
End
Go

-- 2) Modificar el trigger anterior para que al eliminar un Agente y si su estado Activo ya se encuentra previamente en False entonces realice las siguientes acciones:
--		- Cambiar todas las multas efectuadas por ese agente y establecer el valor NULL al campo IDAgente.
--		- Eliminar físicamente al agente en cuestión.
--	Utilizar una transacción.
Create Trigger TR_EliminarAgente ON Agentes
Instead of Delete
as
Begin
	Begin Try
		Begin Transaction		
			-- 1. Verificar si su estado ya se encuentra en false.
			Declare @IDAgente int
			Select @IDAgente = IDAgente From deleted

			Select Activo From Agentes Where IDAgente = @IDAgente

			if (Select Activo From Agentes Where IDAgente = @IDAgente) = 0  Begin	
				Update Multas Set IDAgente = NULL Where IDAgente = @IDAgente

				Delete From Agentes Where IDAgente = @IDAgente
			End

		Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction
		Raiserror('No se pudo realizar la eliminacion', 16, 0)
	End Catch
End
Go

-- 3) Hacer un trigger que al insertar una multa realice las siguientes acciones:
--	- No permitir su ingreso si el Agente asociado a la multa no se encuentra Activo. Indicarlo con un mensaje claro que sea		considerado una excepción.
--	- Establecer el Monto de la multa a partir del tipo de infracción.
--	- Aplicar un recargo del 20% al monto de la multa si no es la primera multa del vehículo en el año.
--	- Aplicar un recargo del 25% al monto de la multa si no es la primera multa del mismo tipo de infracción del vehículo en el		año.
--	- Establecer el estado Pagada como False.
Create Trigger TR_InsertarMulta ON Multas
Instead of Insert
as
Begin
	Begin Try
		Begin Transaction		
		
			Declare @IDAgente int
			Select @IDAgente = IDAgente From inserted

			if (Select Activo From Agentes Where IDAgente = @IDAgente) = 0 Begin
				Rollback Transaction
				Raiserror('No se puede asociar el agente indicado a la multa, dado que el mismo no se encuentra activo.', 16, 0)
			End

			else Begin

				Declare @IDTipoInfraccion int
				Select @IDTipoInfraccion = IDTipoInfraccion From inserted

				Declare @Monto money
				Select @Monto = (Select ImporteReferencia From TipoInfracciones Where IDTipoInfraccion = @IDTipoInfraccion)

				Declare @Patente varchar(10)
				Select @Patente = Patente From inserted
				
				if @Patente IN (Select Patente From Multas Where YEAR(FechaHora) = YEAR(GETDATE())) Begin
					if @IDTipoInfraccion IN (Select IDTipoInfraccion From Multas Where Patente = @Patente) Begin
						Select @Monto = @Monto * 1.25
					End

					else Begin
						Select @Monto = @Monto * 1.20
					End
				End
			End

			Declare @IDLocalidad int
			Select @IDLocalidad = IDLocalidad From inserted

			Insert Into Multas(IDLocalidad, IDTipoInfraccion, IDAgente, Patente, Monto, FechaHora, Pagada)
			Values(@IDLocalidad, @IDTipoInfraccion, @IDAgente, @Patente, @Monto, GETDATE(), 0)

			Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction
		Raiserror('No se pudo realizar la operacion.', 16, 0)
	End Catch
End
Go

-- 4) Hacer un trigger que al insertar un pago realice las siguientes verificaciones:
--	- Verificar que la multa que se intenta pagar se encuentra no		pagada.
--	- Verificar que el Importe del pago sumado a los importes			anteriores de la misma multa no superen el Monto a abonar.

--	  En ambos casos impedir el ingreso y mostrar un mensaje acorde.

--	- Si el pago cubre el Monto de la multa ya sea con un pago único o	siendo la suma de pagos anteriores sobre la misma multa. Además		de registrar el pago se debe modificar el estado Pagada de la		multa relacionada.
Create Trigger TR_InsertarPago ON Pagos
Instead of Insert
as
Begin
	Begin Try
		Begin Transaction

			Declare @IDMulta int, @Pagada bit, @ImporteDePago money, @MontoTotalAbonar money, @Importe money, @IDMedioDePago tinyint
			Select @IDMulta = IDMulta, @ImporteDePago = Importe, @Importe = Importe, @IDMedioDePago = IDMedioPago From inserted

			Select @Pagada = (Select Pagada From Multas Where IDMulta = @IDMulta)

			if @Pagada = 1 Begin
				Rollback Transaction
				Raiserror('La multa ya se encuentra pagada.', 16, 0)
			End

			Select @ImporteDePago = @ImporteDePago + (Select SUM(Importe) From Pagos Where IDMulta = @IDMulta)

			Select @MontoTotalAbonar = (Select Monto From Multas Where IDMulta = @IDMulta)

			if @ImporteDePago > @MontoTotalAbonar Begin
				Rollback Transaction
				Raiserror('El importe de pago supera el monto a abonar.', 16, 0)
			End

			if @ImporteDePago = @MontoTotalAbonar Begin
				Insert Into Pagos(IDMulta, Importe, Fecha, IDMedioPago)
				Values(@IDMulta, @Importe, GETDATE(), @IDMedioDePago)

				Update Multas Set Pagada = 1 Where IDMulta = @IDMulta
			End

			else Begin
				Insert Into Pagos(IDMulta, Importe, Fecha, IDMedioPago)
				Values(@IDMulta, @Importe, GETDATE(), @IDMedioDePago)
			End

		Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction
		Raiserror('No se pudo efectuar la operacion.', 16, 0)
	End Catch
End
Go

Insert Into Pagos(IDMulta, Importe, Fecha, IDMedioPago)
Values(10, 4000, GETDATE(), 5)

Select * From Pagos
Select * From Multas order by Patente asc
Select * From Localidades
Select * From Agentes
Select * From MediosPago
Go

