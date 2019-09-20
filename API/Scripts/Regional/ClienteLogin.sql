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

	-- VERIFICAR QUE EXISTA USUARIO
	if not exists(select * from dbo.ClientesLogin where Usuario = @username)
	BEGIN
		set @estado = 9
		set @mensaje = 'Usuario o Contraseña incorrecta'

		goto SALIR
	END

	-- VERIFICAR CONTRASENA
	if ((select Contraseña from dbo.ClientesLogin where Usuario = @username) != @password)
	BEGIN
		set @estado = 9
		set @mensaje = 'Usuario o Contraseña incorrecta'

		update dbo.ClientesLogin set CantidadIntentosFallidos = CantidadIntentosFallidos + 1 where Usuario = @username

		set @cantidadIntentos = (select isnull(param_valor,0) Value from parametrizar_portal where param_alias = ltrim(rtrim('CINT')))
		if ((select CantidadIntentosFallidos from dbo.ClientesLogin where Usuario = @username) > @cantidadIntentos)
		BEGIN
			update dbo.ClientesLogin set Bloqueado = 1, CantidadIntentosFallidos = 0 where Usuario = @username
		END

		goto SALIR
	END

	-- VENCIMIENTO DE CONTRASENA
	exec CheckVencimientoPass @username, @cambiarContrasena OUTPUT
	if (@cambiarContrasena = 1)
	BEGIN
		set @estado = 9
		set @mensaje = 'Debe cambiar la contraseña...'
		
		goto SALIR
	END

	-- VERIFICO SI ESTA BLOQUEADO
	if ((select Bloqueado from dbo.ClientesLogin where Usuario = @username) = 1)
	BEGIN
		set @estado = 9
		set @mensaje = 'Acceso bloqueado por superar cantidad de intentos fallidos, comuníquese con BASA para desbloquear'
		
		goto SALIR
	END

	-- VERIFICO EL ESTADO DEL CLIENTE
	if ((select Estado from dbo.ClientesLogin where Usuario = @username) != 1)
	BEGIN
		set @estado = (select Estado from dbo.ClientesLogin where Usuario = @username)
		set @mensaje = 'Usuario Inactivo'
		
		goto SALIR
	END

	SALIR:
		if (@estado != 0)
		BEGIN
			select 
				0 as Id,
				'' as clie_alias,
				'' as Usuario,
				'' as NombreAfip,
				'' as Email,
				@estado as Estado,
				@mensaje as Mensaje,
				convert(bit,0) as CambiarContraseña
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
				convert(bit,RenovarClave) as CambiarContraseña			
			FROM 
				dbo.ClientesLogin
			where 
				Usuario = @username
		END

END

GO

