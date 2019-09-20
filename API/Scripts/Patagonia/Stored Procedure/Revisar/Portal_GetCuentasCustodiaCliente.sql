if OBJECT_ID('dbo.GetCuentasCustodiaCliente') is not null
begin
	drop procedure dbo.GetCuentasCustodiaCliente
end
go

CREATE procedure dbo.GetCuentasCustodiaCliente (
		@clieAlias varchar(5)
) 
as begin

	DECLARE @DescripcionUSD varchar(max) = 'Cuenta Inversion USD'
	DECLARE @DescripcionPYG varchar(max) = 'Cuenta Inversion PYG'

	select 
		ccv.ccus_id as Cuenta,
		ltrim(rtrim(c.tccus_alias)) as Tipo,
		c.ccus_numero as Numero,
		c.espe_codigo as Especie,
		(CASE
			WHEN c.espe_codigo in ('02','02B') THEN (select @DescripcionUSD + ' - ' + convert(varchar,c.ccus_numero))
			WHEN c.espe_codigo in ('69','69B') THEN (select @DescripcionPYG + ' - ' + convert(varchar,c.ccus_numero))
		END) as Descripcion
	from 
		cuentas_custodia_vinculadas ccv
		inner join cuentas_custodia c on ccv.ccus_id = c.ccus_id
	where 
		ccv.clie_alias = @clieAlias 
		and tvcc_id = 1
		and c.ccus_estado = 'A'
end		

