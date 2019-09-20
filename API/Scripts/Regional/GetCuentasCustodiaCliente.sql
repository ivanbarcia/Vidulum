if exists(select * from sysobjects where name = 'GetCuentasCustodiaCliente')
	drop procedure GetCuentasCustodiaCliente
go

CREATE procedure dbo.GetCuentasCustodiaCliente (
		@clieAlias varchar(5)
) 
as begin

	select 
		ccv.ccus_id as Cuenta,
		ltrim(rtrim(c.tccus_alias)) as Tipo,
		c.ccus_numero as Numero
	from 
		cuentas_custodia_vinculadas ccv
		inner join cuentas_custodia c on ccv.ccus_id = c.ccus_id
	where 
		ccv.clie_alias = @clieAlias 
		and tvcc_id = 1
		and c.ccus_estado = 'A'
		and ltrim(rtrim(c.tccus_alias)) <> 'MON'
end		

