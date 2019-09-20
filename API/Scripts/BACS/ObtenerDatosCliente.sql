if exists(select * from sysobjects where name = 'ObtenerDatosCliente')
	drop procedure ObtenerDatosCliente
go

CREATE PROCEDURE dbo.ObtenerDatosCliente
(
	@CUIT varchar(MAX)
)
AS BEGIN

declare @cambiarContraseña bit = 0
exec CheckVencimientoPass @CUIT, @cambiarContraseña OUTPUT

	SELECT 
		clie_alias as 'clie_alias',
		Usuario as 'Usuario',
		Contraseña as 'Contraseña',
		0 as 'Cuenta',
		NombreAfip as 'NombreAfip',
		Pregunta as 'Pregunta',
		Respuesta as 'Respuesta',
		Bloqueado as 'Bloqueado',
		CantidadIntentosFallidos as 'CantidadIntentosFallidos',
		Id as 'Id',
		Estado as 'Estado',
		FechaAlta as 'FechaAlta',
		UsuarioAlta as 'UsuarioAlta',
		FechaModificacion as 'FechaModificacion',
		UsuarioModificacion as 'UsuarioModificacion',
		@cambiarContraseña as 'CambiarContraseña'
	FROM 
		dbo.ClientesLogin 
	where 
		Usuario = @CUIT

END

