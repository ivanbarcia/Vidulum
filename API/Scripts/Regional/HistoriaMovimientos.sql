if exists(select * from sysobjects where name = 'HistoriaMovimientos')
	drop procedure HistoriaMovimientos
go

CREATE procedure [dbo].[HistoriaMovimientos] (
	@fechaDesde datetime,
	@fechaHasta datetime,
	@clieAlias varchar(6),
	@ccus_id int)
as
begin

	--select @_mliq_monto = case o.tope_suma  
	--when 1 then fci.oper_monto * fci.oper_precio - ISNULL(fci.ofci_ivacomision,0) - ISNULL(fci.ofci_comision,0)
	--when 0 then fci.oper_monto * fci.oper_precio + ISNULL(fci.ofci_ivacomision,0) + ISNULL(fci.ofci_comision,0)
						

	select
		o.oper_numero as 'Id',
		o.oper_forigen as 'FechaOrigen', 
		o.oper_fvence as 'FechaVence', 
		ltrim(rtrim(o.espe_codigo)) as 'Especie',
		ltrim(rtrim(e.tesp_codigo)) as 'TipoEspecie',
		ltrim(rtrim(e.espe_descrip)) as 'Descripcion',
		ltrim(rtrim(t.tope_descrip)) as 'TipoOperacion',
		convert(decimal(12,2),round(isnull(sf.sfon_cuotapartes,o.oper_monto),8)) as 'CantidadVN', 
		cast(isnull(sf.sfon_valor_cuota, o.oper_precio) as double precision) as 'Precio', 
		cast(isnull(sfon_monto,
		case o.tope_suma   
			when 1 then (o.oper_monto * o.oper_precio) + ISNULL(od.oper_comis_banco,0) + ISNULL(od.oper_comis_banco_iva,0) + ISNULL(od.oper_comis_merc,0) + ISNULL(od.oper_comis_merc_iva,0)
			when 0 then (o.oper_monto * o.oper_precio) - ISNULL(od.oper_comis_banco,0) - ISNULL(od.oper_comis_banco_iva,0) - ISNULL(od.oper_comis_merc,0) - ISNULL(od.oper_comis_merc_iva,0)
		end)
		as double precision) as 'Monto'
	from 
		operaciones_vista o
		inner join especies e on o.espe_codigo = e.espe_codigo
		inner join tiposoper t on o.tope_codigo = t.tope_codigo 
		left join operaciones_datos od on od.oper_numero = o.oper_numero and od.ccta_liqgali = @ccus_id
		left join solicitudes_fondos sf on sf.oper_numero = o.oper_numero
	where
		o.clie_alias = @clieAlias
		and oper_forigen between @fechaDesde and @fechaHasta
		and o.esto_codigo = 'F'
	order by
		o.oper_forigen, o.espe_codigo
end