if OBJECT_ID('dbo.GetCuentasCliente') is not null
begin
	drop procedure dbo.GetCuentasCliente
end
go

CREATE procedure [dbo].[GetCuentasCliente] (
		@clieAlias varchar(5),
		@ccus_id int
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
		and c.ccus_id = @ccus_id
		and c.tccus_alias <> 'MON'

	union
	
	select 
		cd.ccud_sger_id as Cuenta,
		ltrim(rtrim(c.tccus_alias)) as Tipo,
		c.ccus_numero as Numero
	from 
		cuentas_custodia_vinculadas ccv
		inner join cuentas_custodia c on ccv.ccus_id = c.ccus_id
		inner join cuentas_custodia_datos cd on c.ccus_id = cd.ccud_sger_id
	where 
		ccv.clie_alias = @clieAlias 
		and tvcc_id = 1
		and c.ccus_estado = 'A'
		and cd.ccus_id = @ccus_id
		and c.tccus_alias = 'MON'

end		

