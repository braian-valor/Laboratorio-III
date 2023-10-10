-- 1) Apellido, nombres y fecha de ingreso de todos los agentes.
Select Apellidos, Nombres, FechaIngreso as 'Fecha de ingreso' From Agentes
Go 

-- 2) Apellido, nombres y antigüedad de todos los agentes.
Select Apellidos, Nombres, DATEDIFF(YEAR, FechaIngreso, GETDATE()) as 'Antiguedad' From Agentes
Go

-- 3) Apellido y nombres de aquellos colaboradores que no estén activos.
Select Apellidos, Nombres From Agentes Where Activo = 0
Go

-- 4) Apellido y nombres y antigüedad de aquellos colaboradores cuyo sueldo sea entre 50000 y 100000.
Select Apellidos, Nombres, DATEDIFF(YEAR, FechaIngreso, GETDATE()) as 'Antiguedad' From Agentes 
Where Sueldo >= 50000 And Sueldo <= 100000
Go

Select Apellidos, Nombres, DATEDIFF(YEAR, FechaIngreso, GETDATE()) as 'Antiguedad' From Agentes 
Where Sueldo Between 50000 And 100000
Go

-- 5) Apellidos y nombres y edad de los colaboradores con legajos A001, A005 y A015.
Select Apellidos, Nombres, DATEDIFF(YEAR, 0, GETDATE() - CAST(FechaNacimiento as datetime)) as 'Edad' From Agentes
Where Legajo IN ('A001', 'A005', 'A015')
Go

-- 6) Todos los datos de todas las multas ordenadas por monto de forma descendente.
Select * From Multas Order by Monto desc
Go

-- 7) Todos los datos de las multas realizadas en el mes 02 de 2023.
Select * From Multas Where MONTH(FechaHora) = 2 And YEAR(FechaHora) = 2023
Go

-- 8) Todos los datos de todas las multas que hayan superado el monto de $20000.
Select * From Multas Where Monto > 20000
Go

-- 9) Apellido y nombres de los agentes que no hayan registrado teléfono.
Select Apellidos, Nombres From Agentes Where Telefono Is Null
Go

-- 10) Apellido y nombres de los agentes que hayan registrado mail pero no teléfono.
Select Apellidos, Nombres From Agentes Where Email Is Not Null And Telefono Is Null
Go

-- 11) Apellidos, nombres y datos de contacto de todos los agentes.

-- Nota: En datos de contacto debe figurar el número de celular, si no tiene celular el número de teléfono fijo y si no tiene este último el mail. En caso de no tener ninguno de los tres debe figurar 'Incontactable'.

Select Apellidos, Nombres, ISNULL(Email, ISNULL(Telefono, ISNULL(Celular, 'Incontactable'))) as 'Datos de contacto' From Agentes
Go

Select Apellidos, Nombres, COAlESCE(Email, Telefono, Celular, 'Incontactable') as 'Datos de contacto' From Agentes
Go

-- 12) Apellidos, nombres y medio de contacto de todos los agentes. Si tiene celular debe figurar 'Celular'. Si no tiene celular pero tiene teléfono fijo debe figurar 'Teléfono fijo' de lo contrario y si tiene Mail debe figurar 'Email'. Si no posee ninguno de los tres debe figurar NULL.
Select
	Apellidos,
	Nombres,
	Case
		When Email Is Not Null Then 'Email'
		When Telefono Is Not Null Then 'Telefono fijo'
		When Celular Is Not Null Then 'Celular'
		Else NULL
	End as 'Medio de contacto'
From Agentes
Go

-- 13) Todos los datos de los agentes que hayan nacido luego del año 2000.
Select * From Agentes Where YEAR(FechaNacimiento) > 2000
Go

-- 14) Todos los datos de los agentes que hayan nacido entre los meses de Enero y Julio(inclusive).
Select * From Agentes Where MONTH(FechaNacimiento) >= 1 And MONTH(FechaNacimiento) <= 7
Go

-- 15) Todos los datos de los agentes cuyo apellido finalice con vocal.
Select * From Agentes Where Apellidos Like '%[AEIOU]'
Go

-- 16) Todos los datos de los agentes cuyo nombre comience con 'A' y contenga al menos otra 'A'. Por ejemplo, Ana, Anatasia, Aaron, etc.
Select * From Agentes Where Nombres Like 'A%A%'
Go

-- 17) Todos los agentes que tengan más de 10 años de antigüedad.
Select * From Agentes Where DATEDIFF(YEAR, FechaIngreso, GETDATE()) > 10
Go

-- 18) Las patentes, sin repetir, que hayan registrado multas.
Select distinct Patente From Multas
Go

-- 19) Todos los datos de todas las multas labradas en el mes de marzo de 2023 con un recargo del 25% en una columna llamada NuevoImporte.
Select *, Monto * 1.25 as 'Nuevo Importe' From Multas Where MONTH(FechaHora) = 3
Go

-- 20) Todos los datos de todos los colaboradores ordenados por apellido ascendentemente en primera instancia y por nombre descendentemente en segunda instancia.
Select * From Agentes Order by Apellidos asc, Nombres desc
Go