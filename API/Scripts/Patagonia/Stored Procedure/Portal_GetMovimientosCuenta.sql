﻿if OBJECT_ID('dbo.GetMovimientosCuenta') is not null
begin
	drop procedure dbo.GetMovimientosCuenta
end
go

CREATE procedure [dbo].[GetMovimientosCuenta] (
	@fechaDesde datetime,
	@fechaHasta datetime,
	@clieAlias varchar(6),
	@ccus_id int)
as
begin

	select
		0 as 'Pendiente',
		o.oper_forigen as 'Fecha', 
		ltrim(rtrim(e.espe_descrip)) as 'Concepto',
		1 as 'Debito',
		ltrim(rtrim(e.espe_codcot)) as 'Moneda', 
		o.oper_precio as 'ValorCuota', 
		o.oper_monto as 'CuotasPartes', 
		case o.tope_suma   
			when 1 then (o.oper_monto * o.oper_precio) + ISNULL(od.oper_comis_banco,0) + ISNULL(od.oper_comis_banco_iva,0) + ISNULL(od.oper_comis_merc,0) + ISNULL(od.oper_comis_merc_iva,0)
			when 0 then (o.oper_monto * o.oper_precio) - ISNULL(od.oper_comis_banco,0) - ISNULL(od.oper_comis_banco_iva,0) - ISNULL(od.oper_comis_merc,0) - ISNULL(od.oper_comis_merc_iva,0)
		end as 'Importe'
	from 
		operaciones_vista o
		inner join especies e on o.espe_codigo = e.espe_codigo
		inner join tiposoper t on o.tope_codigo = t.tope_codigo 
		inner join operaciones_datos od on od.oper_numero = o.oper_numero		
	where
		o.clie_alias = @clieAlias
		and oper_forigen between @fechaDesde and @fechaHasta
		and o.esto_codigo = 'F'
		and od.ccta_liqgali = @ccus_id
	order by
		o.oper_forigen, o.espe_codigo
end


