if exists(select * from sysobjects where name = 'ObtenerDatosCliente')
	drop procedure ObtenerDatosCliente
go

CREATE PROCEDURE dbo.ObtenerDatosCliente
(
	@CUIT varchar(MAX)
)
AS BEGIN

--declare @cambiarContraseña bit = 0
--exec CheckVencimientoPass @CUIT, @cambiarContraseña OUTPUT

	SELECT 
		ltrim(rtrim(clie_alias)) as 'clie_alias',
		ltrim(rtrim(Usuario)) as 'Usuario',
		ltrim(rtrim(Contraseña)) as 'Contraseña',
		0 as 'Cuenta',
		ltrim(rtrim(NombreAfip)) as 'NombreAfip',
		Pregunta as 'Pregunta',
		ltrim(rtrim(Respuesta)) as 'Respuesta',
		Bloqueado as 'Bloqueado',
		CantidadIntentosFallidos as 'CantidadIntentosFallidos',
		Id as 'Id',
		Estado as 'Estado',
		FechaAlta as 'FechaAlta',
		ltrim(rtrim(UsuarioAlta)) as 'UsuarioAlta',
		FechaModificacion as 'FechaModificacion',
		ltrim(rtrim(UsuarioModificacion)) as 'UsuarioModificacion',
		CONVERT(bit,RenovarClave) as 'CambiarContraseña',
		ltrim(rtrim(Email)) as 'Email'
	FROM 
		dbo.ClientesLogin
	where 
		Usuario = @CUIT

END

GO
