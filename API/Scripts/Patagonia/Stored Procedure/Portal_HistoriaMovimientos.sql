if OBJECT_ID('dbo.HistoriaMovimientos') is not null
begin
	drop procedure dbo.HistoriaMovimientos
end
go

CREATE procedure [dbo].[HistoriaMovimientos] (
	@fechaDesde datetime,
	@fechaHasta datetime,
	@clieAlias varchar(6),
	@ccus_id int)
as
begin

	select
		o.oper_numero as 'Id',
		o.esto_codigo as 'Estado',
		o.oper_forigen as 'FechaOrigen', 
		o.oper_fvence as 'FechaVence', 
		ltrim(rtrim(o.espe_codigo)) as 'Especie',
		ltrim(rtrim(e.tesp_codigo)) as 'TipoEspecie',
		ltrim(rtrim(e.espe_descrip)) as 'Descripcion',
		ltrim(rtrim(t.tope_descrip)) as 'TipoOperacion',
		convert(decimal(38,4),round(isnull(o.oper_monto,0),8)) as 'CantidadVN', 
		cast(isnull(o.oper_precio,0) as double precision) as 'Precio', 
		cast(isnull(
		case o.tope_suma   
			when 1 then (o.oper_monto * o.oper_precio) + ISNULL(od.oper_comis_banco,0) + ISNULL(od.oper_comis_banco_iva,0) + ISNULL(od.oper_comis_merc,0) + ISNULL(od.oper_comis_merc_iva,0)
			when 0 then (o.oper_monto * o.oper_precio) - ISNULL(od.oper_comis_banco,0) - ISNULL(od.oper_comis_banco_iva,0) - ISNULL(od.oper_comis_merc,0) - ISNULL(od.oper_comis_merc_iva,0)
		end, 0)
		as double precision) as 'Monto'
	from 
		operaciones_vista o
		inner join especies e on o.espe_codigo = e.espe_codigo
		inner join tiposoper t on o.tope_codigo = t.tope_codigo 
		left join operaciones_datos od on od.oper_numero = o.oper_numero and od.ccta_liqgali = @ccus_id
	where
		o.clie_alias = @clieAlias
		and convert(varchar(8),o.oper_forigen,112) between @fechaDesde and @fechaHasta
		and o.esto_codigo = 'F'
		and e.tesp_codigo != 'F'

	union

	select
		isnull(sf.oper_numero, sf.sfon_id) as 'Id',
		sf.estf_codigo as 'Estado',
		sf.sfon_falta as 'FechaOrigen', 
		sf.sfon_falta as 'FechaVence', 
		ltrim(rtrim(sf.espe_codigo)) as 'Especie',
		ltrim(rtrim(e.tesp_codigo)) as 'TipoEspecie',
		ltrim(rtrim(e.espe_descrip)) as 'Descripcion',
		ltrim(rtrim((select tope_descrip from tiposoper where tope_codigo = iif(sf.topf_alias = 'S', 401, 402)))) as 'TipoOperacion',
		convert(decimal(38,4),round(isnull(sf.sfon_cuotapartes,0),8)) as 'CantidadVN', 
		cast(isnull(sf.sfon_valor_cuota, 0) as double precision) as 'Precio', 
		cast(isnull(sfon_monto, 0) as double precision) as 'Monto'
	from 
		solicitudes_fondos sf
		inner join especies e on sf.espe_codigo = e.espe_codigo
	where
		sf.clie_alias = @clieAlias
		and convert(varchar(8),sf.sfon_falta,112) between  @fechaDesde and @fechaHasta
		
	order by
		'FechaOrigen', 'Especie'

end

GO
