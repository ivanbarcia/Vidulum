if OBJECT_ID('dbo.InsertHistoricoPass') is not null
begin
	drop procedure dbo.InsertHistoricoPass
end
go
 
CREATE procedure [dbo].InsertHistoricoPass (
	@_clie_cuit	varchar(200)	,
	@_pass varchar(256)
)
as begin
	
	declare @_clie_alias varchar(6)
	select @_clie_alias = clie_alias from ClientesLogin where Usuario = @_clie_cuit

	insert into historico_portal_pass (Usuario,Contrasena,clie_alias,FechaAlta)
	values (@_clie_cuit,@_pass,@_clie_alias,getdate())

end
 
 go 

