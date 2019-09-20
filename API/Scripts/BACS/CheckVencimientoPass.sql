if exists(select * from sysobjects where name = 'CheckVencimientoPass')
	drop procedure CheckVencimientoPass
go

CREATE procedure [dbo].CheckVencimientoPass (
	@_clie_cuit	varchar(200),
	@_cambiar_pass bit OUTPUT
)
as begin
	
	declare @_fechaAlta datetime,
			@_tiempoPassActiva int,
			@_diferenciaDias int

	select top(1) @_fechaAlta = FechaAlta from historico_portal_pass where ltrim(rtrim(Usuario)) = ltrim(rtrim(@_clie_cuit)) order by FechaAlta desc
	select @_diferenciaDias = DATEDIFF(DAY, @_fechaAlta, GETDATE()) 
	select @_tiempoPassActiva = param_valor from parametrizar_portal where param_alias = 'TPASS'

	--if @_diferenciaDias <= @_tiempoPassActiva
		select @_cambiar_pass = 0
	--else
		--select 0

end


