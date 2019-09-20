if OBJECT_ID('dbo.ReadParamValue') is not null
begin
	drop procedure dbo.ReadParamValue
end
go

CREATE procedure [dbo].ReadParamValue (
	@_param_alias varchar(6)	
)
as begin
	select isnull(param_valor,0) Value from parametrizar_portal where param_alias = ltrim(rtrim(@_param_alias))			
end
