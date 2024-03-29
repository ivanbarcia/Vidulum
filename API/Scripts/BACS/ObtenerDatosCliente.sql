if exists(select * from sysobjects where name = 'ObtenerDatosCliente')
	drop procedure ObtenerDatosCliente
go

CREATE PROCEDURE dbo.ObtenerDatosCliente
(
	@CUIT varchar(MAX)
)
AS BEGIN

declare @cambiarContraseņa bit = 0
exec CheckVencimientoPass @CUIT, @cambiarContraseņa OUTPUT

	SELECT 
		clie_alias as 'clie_alias',
		Usuario as 'Usuario',
		Contraseņa as 'Contraseņa',
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
		@cambiarContraseņa as 'CambiarContraseņa'
	FROM 
		dbo.ClientesLogin 
	where 
		Usuario = @CUIT

END

