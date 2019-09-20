if OBJECT_ID('dbo.CheckCliente') is not null
begin
	drop procedure dbo.CheckCliente
end
go

CREATE procedure [dbo].CheckCliente (
	@_clie_cuit	varchar(30)	
)
as begin

	if exists (select * from clientes where rtrim(ltrim(clie_nrodoc)) = rtrim(ltrim(@_clie_cuit)))
		select 1 as 'Value'
	else
		select 0 as 'Value'

end
 
go 

