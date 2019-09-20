if OBJECT_ID('dbo.CheckHistoricoPass') is not null
begin
	drop procedure dbo.CheckHistoricoPass
end
go

CREATE procedure [dbo].CheckHistoricoPass (
	@_clie_cuit	varchar(200)	,
	@_pass varchar(256)
)
as begin
	
	declare @_cantidad_historico_pass int
	select @_cantidad_historico_pass = param_valor from parametrizar_portal where param_alias = 'CHIS'

	if exists (select * from historico_portal_pass
			   where ltrim(rtrim(Usuario)) = ltrim(rtrim(@_clie_cuit)) 
			   and @_pass in (select top(@_cantidad_historico_pass) Contrasena 
				    	 	  from historico_portal_pass
							  where ltrim(rtrim(Usuario)) = ltrim(rtrim(@_clie_cuit))
							  order by FechaAlta desc))
		select 0 as 'Value' -- existe contraseña en el historico
	else
		select 1 as 'Value' -- NO existe contraseña en el historico

end
go 

