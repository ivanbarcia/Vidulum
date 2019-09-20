if OBJECT_ID('dbo.ObtenerDatosCliente') is not null
begin
	drop procedure dbo.ObtenerDatosCliente
end
go

CREATE PROCEDURE dbo.ObtenerDatosCliente
(
	@CUIT varchar(MAX)
)
AS BEGIN

--declare @cambiarContraseÃ±a bit = 0
--exec CheckVencimientoPass @CUIT, @cambiarContraseÃ±a OUTPUT

	SELECT 
		ltrim(rtrim(clie_alias)) as 'clie_alias',
		ltrim(rtrim(Usuario)) as 'Usuario',
		ltrim(rtrim(Contrasena)) as 'Contrasena',
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
		RenovarClave as 'RenovarClave',
		ltrim(rtrim(Email)) as 'Email',
		ltrim(rtrim(Celular)) as 'Celular',
		FechaNacimiento as 'FechaNacimiento'
	FROM 
		dbo.ClientesLogin
	where 
		Usuario = @CUIT

END

GO
