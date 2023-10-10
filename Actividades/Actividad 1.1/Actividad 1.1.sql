Use master
Go
Use AgenciaDeTransito
Go

drop database AgenciaDeTransito

Create Table TiposDeInfracciones(
	IDTipoInfraccion int not null primary key identity(1, 1),
	Descripcion varchar(100) null,
	ImporteReferencia money not null 
)
Go

Create Table Provincias(
	IDProvincia smallint not null primary key identity(1, 1),
	Provincia varchar(50) not null
)
Go

Create Table Localidades(
	IDLocalidad int not null primary key identity(1, 1),
	Localidad varchar(150) not null,
	IDProvincia smallint not null foreign key references Provincias(IDProvincia)
)
Go

Create Table AgentesDeTransito(
	IDAgente int not null primary key identity(1, 1),
	Legajo varchar(10) not null unique,
	Apellidos varchar(50) not null,
	Nombres varchar(50) not null,
	FechaNacimiento date not null,
	FechaIngreso date not null,
	Email varchar(100) null unique,
	Telefono varchar(20) null unique,
	Sueldo money not null check(Sueldo > 0),
	Estado bit not null default(1)
)
Go

Create Table Multas(
	IDMulta int not null primary key identity(1, 1),
	IDTipoInfraccion int not null foreign key references TiposDeInfracciones(IDTipoInfraccion),
	IDLocalidad int not null foreign key references Localidades(IDLocalidad),
	IDAgente int null foreign key references AgentesDeTransito(IDAgente),
	Patente varchar(10) not null,
	FechaHora datetime not null,
	Importe money not null check(Importe > 0),
	Pagada bit not null default(0)
)
Go