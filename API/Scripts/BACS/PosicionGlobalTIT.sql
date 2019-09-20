if exists(select * from sysobjects where name = 'PosicionGlobalTIT')
	drop procedure PosicionGlobalTIT
go
 
Create procedure [dbo].PosicionGlobalTIT 
		(@_clie_alias varchar(6),
		 @_fecha datetime,
		 @_ccus_id_TIT int)
as
begin
	
	if @_clie_alias is null or @_clie_alias = ''
	begin
		select @_clie_alias = clie_alias from cuentas_custodia_vinculadas where ccus_id = @_ccus_id_TIT and tvcc_id = 1
	end

	declare @_fecha_a_usar datetime
	select @_fecha_a_usar = CONVERT(char(8),@_fecha,112)

	create table #_tmp (
		Especie varchar(6),
		Descripcion varchar(40),
		Cantidad float,
		Precio float,
		Saldo float
	)
	
	insert into #_tmp
	select 
		ccs.espe_codigo 'Especie',
		ltrim(rtrim(es.espe_descrip)) 'Descripcion',
		isnull(ccs.ccs_saldo,0) 'Cantidad',
		null 'Precio', 
		null 'Saldo'
	from
		cuentas_custodia_saldos ccs
		inner join cuentas_custodia c on ccs.ccus_id = c.ccus_id
		inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id
		inner join clientes cl on ccv.clie_alias = cl.clie_alias
		inner join especies es on ccs.espe_codigo = es.espe_codigo

		full outer join (
			select 
				espe_codigo,
				sum(oper_monto * case tope_suma when 1 then -1 else 1 end) Monto  
			from 
				operaciones_vista o
				inner join operaciones_datos od on o.oper_numero = od.oper_numero
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			and isnull(od.orden_numero,0) = 0
			group by espe_codigo
			union
			select 
				espe_codcot espe_codigo,
				sum(oper_monto * case tope_suma when 1 then 1 else -1 end * oper_precio) Monto  
			from 
				operaciones_vista o
				inner join operaciones_datos od on o.oper_numero = od.oper_numero
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			and isnull(od.orden_numero,0) = 0
			group by espe_codcot
			union
			select 
				espe_codigo,
				sum(oper_monto * case tope_suma when 1 then 1 else -1 end) Monto  
			from 
				operaciones_vista o
				inner join operaciones_datos od on o.oper_numero = od.oper_numero
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			and isnull(od.orden_numero,0) > 0
			group by espe_codigo
			union
			select 
				espe_codcot espe_codigo,
				sum(oper_monto * case tope_suma when 1 then -1 else 1 end * oper_precio) Monto  
			from 
				operaciones_vista o
				inner join operaciones_datos od on o.oper_numero = od.oper_numero
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			and isnull(od.orden_numero,0) > 0
			group by espe_codcot
			) t on ccs.espe_codigo = t.espe_codigo	
	where
		ccs_fecha = @_fecha_a_usar
	and cl.clie_alias = @_clie_alias
	and ccs.ccs_saldo <> 0	
	and c.ccus_id = @_ccus_id_TIT

	/* se actualiza la tabla con la cotización de cada especie */
	declare @_especie_a_procesar varchar(6),	
			@_saldo_a_procesar money
	
	declare cur_cotizaciones cursor for
	select Especie,Cantidad from #_tmp
	
	open cur_cotizaciones   
	fetch next from cur_cotizaciones into @_especie_a_procesar,@_saldo_a_procesar

	while @@fetch_status = 0   
	begin   
		declare @_cotizacion float	
				
		select @_cotizacion = cotiz from dbo.UltimaCotizacionConocidaFecha(@_especie_a_procesar,@_fecha_a_usar,0,3,'',dbo.MonedaLocal(),'BOL',1)		
				
		update #_tmp 
			set Saldo = isnull(@_saldo_a_procesar * @_cotizacion,0),
				Precio = ISNULL(@_cotizacion,0) 
		where Especie = @_especie_a_procesar
		
		fetch next from cur_cotizaciones into @_especie_a_procesar, @_saldo_a_procesar		  
	end 
	
	close cur_cotizaciones   
	deallocate cur_cotizaciones
	
	select * from #_tmp 
	select ltrim(rtrim(cl.clie_cuit)) + ' - ' + cl.clie_nombreafip 'Cliente', cc.ccus_numero 'Cuenta',@_fecha 'Fecha'
	from clientes cl, cuentas_custodia cc where clie_alias = ltrim(rtrim(@_clie_alias)) and ccus_id = @_ccus_id_TIT
	

	drop table #_tmp


end