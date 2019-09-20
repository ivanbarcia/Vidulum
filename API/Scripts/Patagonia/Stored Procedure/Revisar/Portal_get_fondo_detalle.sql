if OBJECT_ID('dbo.get_fondo_detalle') is not null
begin
	drop procedure dbo.get_fondo_detalle
end
go
 
CREATE procedure dbo.get_fondo_detalle (@oper_numero int)
as begin 

	select 
		sf.oper_numero,
		sf.sfon_fvalor as 'Fecha',
		(select	
			CASE sf.topf_alias
				WHEN 'S' THEN 'Suscripción'
				WHEN 'R' THEN 'Rescate'
			END
		) as 'Tipo',
		(select ltrim(rtrim(esto_codigo)) + ' - ' + ltrim(rtrim(esto_descrip)) from estadosoper where esto_codigo = sf.estf_codigo) as 'Estado',
		ltrim(rtrim(c.clie_nombreafip)) as 'Nombre',
		ltrim(rtrim(cc.tccus_alias)) + '-' + convert(varchar(max),cc.ccus_numero) as 'Cuenta',
		(select ltrim(rtrim(espe_descrip)) from Especies where espe_codigo = o.espe_codigo) as 'Especie',
		isnull((select ltrim(rtrim(upper(espe_simbolo))) from Especies where espe_codigo = sf.espe_codneg),sf.espe_codneg) as 'Moneda',
		convert(decimal(18,6),sf.sfon_cuotapartes) as 'CantidadCuotasPartes',
		convert(decimal(18,6),sf.sfon_monto) as 'Monto',
		convert(decimal(18,6),sf.sfon_valor_cuota) as 'ValorCuota',
		sf.sfon_falta as 'FechaAlta'
	from 
		operaciones o
		inner join solicitudes_fondos sf on o.oper_numero = sf.oper_numero
		inner join cuentas_custodia cc on cc.ccus_id = sf.ccus_id
		inner join clientes c on c.clie_alias = sf.clie_alias
	where 
		o.oper_numero = @oper_numero

end 	
go
