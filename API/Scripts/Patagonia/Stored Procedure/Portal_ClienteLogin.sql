if exists(select * from sysobjects where name = 'ClienteLogin')
	drop procedure dbo.ClienteLogin
go

CREATE PROCEDURE dbo.ClienteLogin
(
	@username varchar(MAX),
	@password varchar(MAX)
)
AS BEGIN

	declare @estado int = 0
	declare @mensaje varchar(max)
	declare @cambiarContrasena bit = 0
	declare @cantidadIntentos int = 0
	declare @cantidadIntentosParam int = 0
	declare @id int = 0

	-- VERIFICAR QUE EXISTA USUARIO
	if not exists(select * from dbo.ClientesLogin where Usuario = @username)
	BEGIN
		set @estado = 9
		set @mensaje = 'Usuario o Contraseña incorrecta'

		goto SALIR
	END

	-- VENCIMIENTO DE CONTRASENA
	exec CheckVencimientoPass @username, @cambiarContrasena OUTPUT
	if (@cambiarContrasena = 1)
	BEGIN
		set @id = (select Id from dbo.ClientesLogin where usuario = @username)
		set @estado = 9
		set @mensaje = 'Debe cambiar la contraseña...'
		
		goto SALIR
	END

	-- VERIFICO SI ESTA BLOQUEADO
	if ((select Bloqueado from dbo.ClientesLogin where Usuario = @username) = 1)
	BEGIN
		set @id = (select Id from dbo.ClientesLogin where usuario = @username)
		set @estado = 9
		set @mensaje = 'Acceso bloqueado por superar cantidad de intentos fallidos'
		
		goto SALIR
	END

	-- VERIFICO EL ESTADO DEL CLIENTE
	if ((select Estado from dbo.ClientesLogin where Usuario = @username) != 1)
	BEGIN
		set @id = (select Id from dbo.ClientesLogin where usuario = @username)
		set @estado = (select Estado from dbo.ClientesLogin where Usuario = @username)
		set @mensaje = 'Usuario Inactivo'
		
		goto SALIR
	END

	-- VERIFICAR CONTRASENA
	if ((select Contrasena from dbo.ClientesLogin where Usuario = @username) != @password)
	BEGIN
		set @id = (select Id from dbo.ClientesLogin where usuario = @username)
		set @estado = 9
		set @mensaje = 'Usuario o Contraseña incorrecta'

		set @cantidadIntentos = (select isnull(CantidadIntentosFallidos,0) + 1 from dbo.ClientesLogin where usuario = @username)

		update dbo.ClientesLogin set CantidadIntentosFallidos = @cantidadIntentos where Usuario = @username

		set @cantidadIntentosParam = (select isnull(param_valor,0) Value from parametrizar_portal where param_alias = ltrim(rtrim('CINT')))

		if (@cantidadIntentos >= @cantidadIntentosParam - 1)
		BEGIN
			update dbo.ClientesLogin set Bloqueado = 1, CantidadIntentosFallidos = 0 where Usuario = @username
		END

		goto SALIR
	END
	
	SALIR:
		if (@estado != 0)
		BEGIN
			select 
				@id as Id,
				'' as clie_alias,
				'' as Usuario,
				'' as NombreAfip,
				'' as Email,
				@estado as Estado,
				@mensaje as Mensaje,
				0 as RenovarClave,
				@cantidadIntentos as IntentosFallidos
		END
		ELSE
		BEGIN
			-- LOGIN OK
			SELECT 
				Id as Id,
				ltrim(rtrim(clie_alias)) as clie_alias,
				ltrim(rtrim(Usuario)) as Usuario,
				ltrim(rtrim(NombreAfip)) as NombreAfip,
				ltrim(rtrim(Email)) as Email,
				--Pregunta as Pregunta,
				--Respuesta as Respuesta,
				Estado as Estado,
				'' as Mensaje,
				RenovarClave as RenovarClave,
				CantidadIntentosFallidos as IntentosFallidos			
			FROM 
				dbo.ClientesLogin
			where 
				Usuario = @username
		END

END

GO

