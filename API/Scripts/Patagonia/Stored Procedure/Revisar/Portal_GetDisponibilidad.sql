if OBJECT_ID('dbo.GetDisponibilidad') is not null
begin
	drop procedure dbo.GetDisponibilidad
end
go

CREATE procedure dbo.GetDisponibilidad
		(
			@_clie_alias varchar(6), 
			@_ccus_id int ,
			@_fecha datetime = null
		)
as begin 

	if (@_fecha is null)
		select @_fecha = CONVERT(char(8),getdate(),112)

	-- INICIO OPERACIONES A LIQUIDAR

	create table #tempOperaciones(
			TipoOperacion char(40),
			Especie char(6),
			Descripcion char(40),
			FechaConcertacion varchar(10),
			FechaLiquidacion varchar(10),
			Cantidad money,
			Precio float,
			Moneda varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Monto float,
			Cotizacion float,
			SaldoValorizado float,
			Operacion int,
			Liquidada int,
			tope_codigo int,
			espe_codcot varchar(6),
			orden_numero int,
			oper_falta datetime,
			origen varchar(1),
			espe_codcot2 varchar(6),
			tope_codigo_ficticio int)

	insert into #tempOperaciones
	select distinct
		t.tope_descrip 'TipoOperacion',
		e.espe_codigo 'Especie',
		e.espe_descrip 'Descripcion',
		convert(varchar(10),o.oper_forigen,103) 'FechaConcertacion',
		convert(varchar(10),o.oper_fvence,103) 'FechaLiquidacion',
		o.oper_monto 'Cantidad',
		o.oper_precio 'Precio',
		null 'Moneda',
		case when o.tope_codigo in (101,102,103,104) 
			then (-1) *(o.oper_monto * o.oper_precio)
		when o.tope_codigo in (131,132,133,134)
			then (o.oper_monto * o.oper_precio)
		end as 'Monto',
		null 'Cotizacion',
		null 'SaldoValorizado',
		o.oper_numero 'Operacion',
		1,
		o.tope_codigo,
		o.espe_codcot,
		isnull(od.orden_numero,0),
		CONVERT(char(8),o.oper_falta,112),
		'E',
		e.espe_codcot,
		o.tope_codigo
	from 
		operaciones_vista o
		inner join especies e on o.espe_codigo = e.espe_codigo
		inner join tiposoper t on o.tope_codigo = t.tope_codigo
		inner join operaciones_datos od on o.oper_numero = od.oper_numero
		--inner join movim_liquid m on o.oper_numero = m.oper_numero 	
	where 
		o.clie_alias = @_clie_alias 
	--and oper_fvence >=@_fecha
	and o.esto_codigo not in ('N','C')
	and o.tope_codigo in (101,102,103,104,131,132,133,134)
	and od.ccta_liqgali = @_ccus_id
	and isnull(od.orden_numero,0) > 0
	
	insert into #tempOperaciones
	select distinct
		t.tope_descrip 'TipoOperacion',
		e.espe_codigo 'Especie',
		e.espe_descrip 'Descripcion',
		convert(varchar(10),o.oper_forigen,103) 'FechaConcertacion',
		convert(varchar(10),o.oper_fvence,103) 'FechaLiquidacion',
		o.oper_monto 'Cantidad',
		o.oper_precio 'Precio',
		null 'Moneda',
		case when o.tope_codigo in (101,102,103,104) 
			then (-1) *(o.oper_monto * o.oper_precio)
		when o.tope_codigo in (131,132,133,134)
			then (o.oper_monto * o.oper_precio)
		end as 'Monto',
		null 'Cotizacion',
		null 'SaldoValorizado',
		o.oper_numero 'Operacion',
		1,
		o.tope_codigo,
		o.espe_codcot,
		isnull(od.orden_numero,0),
		CONVERT(char(8),o.oper_falta,112),
		'O',
		e.espe_codcot,
		o.tope_codigo
	from 
		operaciones_vista o
		inner join especies e on o.espe_codigo = e.espe_codigo
		inner join tiposoper t on o.tope_codigo = t.tope_codigo
		inner join operaciones_datos od on o.oper_numero = od.oper_numero
		--inner join movim_liquid m on o.oper_numero = m.oper_numero 	
	where 
		o.clie_alias = @_clie_alias 
	--and oper_fvence >=@_fecha
	and o.esto_codigo not in ('N','C')
	and o.tope_codigo in (101,102,103,104,131,132,133,134)
	and od.ccta_liqgali = @_ccus_id
	and isnull(od.orden_numero,0) = 0
	

	update #tempOperaciones 
	set tope_codigo_ficticio = case tope_codigo when 101 then 131 when 102 then 132  when 103 then 133 when 104 then 134 
												when 131 then 101 when 132 then 102 when 133 then 103 when 134 then 104 
												end
	where origen = 'O'
	
	update #tempOperaciones 
	set TipoOperacion = tope_descrip 
	from tiposoper t 
	where t.tope_codigo = #tempOperaciones.tope_codigo_ficticio 
	and #tempOperaciones.origen ='O'
	
	update #tempOperaciones 
		set Monto = Monto * (-1) 
	where origen = 'O'
	
	
	declare @_oper int, 
			@_cliq_alias varchar(6), 
			@_tope_codigo int, 
			@_espe_codcot varchar(6), 
			@_orden_numero int,
			@_oper_falta datetime, 
			@_origen varchar(1), 
			@_moneda_emision varchar(6)
		
	declare c_op_liquidadas cursor for
	select Operacion, tope_codigo, espe_codcot, orden_numero, oper_Falta, origen, espe_codcot2 
	from #tempOperaciones
	
	open c_op_liquidadas
	fetch next from c_op_liquidadas into @_oper, @_tope_codigo, @_espe_codcot, @_orden_numero, @_oper_falta, @_origen, @_moneda_emision
	while @@FETCH_STATUS = 0
	begin
	
		declare conceptos cursor for
		select co.cliq_alias from clasesoper_concep_back  co , esqbackcble e
		where tope_codigo = @_tope_codigo
		and isnull(masi_codigo,isnull(@_espe_codcot,'')) = isnull(@_espe_codcot,'') 
		and origen = @_origen
		and clasesoper_eliminado = 0
		and co.cliq_alias = e.cliq_alias
		and e.fpc_alias is not null
		
		open conceptos
		fetch next from conceptos into @_cliq_alias
		while @@FETCH_STATUS = 0
		begin
			
			declare @_mliq_estado varchar(1), 
					@_mliq_fsupervision datetime, 
					@_oper_forigen datetime
					
			select @_mliq_estado = null,
				   @_mliq_fsupervision = null,
				   @_oper_forigen = null
			
			if @_orden_numero = 0
			begin
				select 
					@_mliq_estado = mliq_estado, 
					@_mliq_fsupervision = mliq_fsupervision, 
					@_oper_forigen = oper_forigen 
				from 
					movim_liquid m, 
					operaciones o 
				where 
					m.oper_numero = @_oper 
				and cliq_alias = @_cliq_alias 
				and m.oper_numero = o.oper_numero
					
			end
			else
			begin
				select 
					@_mliq_estado = mliq_estado, 
					@_mliq_fsupervision = mliq_fsupervision, 
					@_oper_forigen = oper_forigen 
				from 
					movim_liquid m
					left join movim_liquid_datos md on md.mliq_id = m.mliq_id
					left join ordenes o on o.orden_numero = md.orden_numero
					left join operaciones_datos od on o.orden_numero = od.orden_numero
					left join operaciones op on od.oper_numero = op.oper_numero
				where 
					md.orden_numero = @_orden_numero
				and cliq_alias = @_cliq_alias 
				and op.oper_numero = @_oper
					
			end

						
			if (@_mliq_estado = 'P' and @_oper_forigen <= @_fecha) or @_mliq_estado is null
			begin
				update #tempOperaciones set Liquidada = 0 where operacion = @_oper
			end 
			
			if @_mliq_estado = 'A' and convert(char(8),@_mliq_fsupervision,112) > @_fecha and @_oper_forigen <= @_fecha
			begin
				update #tempOperaciones set Liquidada = 0 where operacion = @_oper
			end 
			
			
			--if not exists (select * from movim_liquid where oper_numero = @_oper and cliq_alias = @_cliq_alias and mliq_estado = 'A' and mliq_fsupervision > @_fecha)
			--begin
			--	update #tempOperaciones set Liquidada = 0 where operacion = @_oper
			--end
		
			fetch next from conceptos into @_cliq_alias
		end
		close conceptos
		deallocate conceptos		
	
		fetch next from c_op_liquidadas into @_oper, @_tope_codigo, @_espe_codcot, @_orden_numero, @_oper_falta, @_origen, @_moneda_emision
	end
	close c_op_liquidadas
	deallocate c_op_liquidadas
	
	
	delete from #tempOperaciones 
	where Liquidada = 1
	
	declare @_monto float, 
			@_oper_numero int	
	
	declare c_operaciones cursor for
	select Monto,Operacion 
	from #tempOperaciones
	
	open c_operaciones
	fetch next from c_operaciones 
	into @_monto,@_oper_numero
	
	while @@FETCH_STATUS = 0
	begin
		declare @_cotizacion float, @_especie_a_procesar varchar(6)
		
		select @_especie_a_procesar = espe_codcot from operaciones_vista where oper_numero = @_oper_numero
		select @_cotizacion = cotiz from dbo.UltimaCotizacionConocidaFecha(@_especie_a_procesar,@_fecha,0,3,'',dbo.MonedaLocal(),'BOL',1)		
		
		update #tempOperaciones
			set Moneda =  @_especie_a_procesar,
				Cotizacion = @_cotizacion,
				SaldoValorizado = @_monto * @_cotizacion		
		where Operacion = @_oper_numero
		
		fetch next from c_operaciones 
		into @_monto,@_oper_numero
	end
	
	close c_operaciones
	deallocate c_operaciones
	
	-- FIN OPERACIONES A LIQUIDAR

	-- INICIO CUENTAS
	create table #tempCuentas (
		Descripcion varchar(200),
		Saldo float,
		Cotizacion float null,
		SaldoValorizado float,		
		FechaCotizacion varchar(20) null,
		Especie varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	)

	declare curCuentas cursor for
	select cc.ccus_id from cuentas_custodia_vinculadas ccv inner join cuentas_custodia cc on ccv.ccus_id = cc.ccus_id
	where clie_alias = @_clie_alias 
	and tvcc_id = 1
	and cc.tccus_alias in ('MON')

	open curCuentas
	fetch next from curCuentas into @_ccus_id

	while @@FETCH_STATUS = 0
	begin

		insert into #tempCuentas
		select 
			t.Descripcion, 
			sum(isnull(t.Saldo,0)) as 'Saldo',
			null 'Cotizacion',
			null as 'SaldoValorizado', 
			null 'FechaCotizacion',
			ltrim(rtrim(t.Especie)) 'Especie'	
		from 
			(
				select 
					0 caso,
					'Cuenta '+es.espe_descrip as 'Descripcion', 
					isnull(
							m.ccm_monto
							* case m.ccm_tipomov when 'D' then -1 else 1 end,0) as 'Saldo',
					ltrim(rtrim(m.espe_codigo)) 'Especie',
					m.ccm_id
				from
					cuentas_custodia_movim m
					inner join cuentas_custodia c on m.ccus_id = c.ccus_id
					--inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id
					--inner join clientes cl on ccv.clie_alias = cl.clie_alias
					inner join especies es on m.espe_codigo = es.espe_codigo
					inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo
					--inner join cuentas_custodia_datos ccd on ccd.ccus_id = @_ccus_id_custodia
					inner join conceptos_cuentas_custodia ccc on m.concc_id = ccc.concc_id
				where
					m.ccm_fvalor <= @_fecha
					and m.ccus_id = @_ccus_id
					--and cl.clie_alias = @_clie_alias
					and m.ccm_monto <> 0	
					and c.tccus_alias = 'MON'
					--and ccd.ccud_sger_id = c.ccus_id
					and m.ccm_estado = 'A') t 
				group by t.Especie, 
						 t.Descripcion
				order by t.Descripcion

	fetch next from curCuentas into @_ccus_id
	end	

	close curCuentas
	deallocate curCuentas

	delete from #tempCuentas where Saldo = 0

	/* se actualiza la tabla con la cotización de cada especie */

	declare @_saldo_a_procesar money

	declare cur_cotizaciones cursor for
	select Especie,Saldo from #tempCuentas

	open cur_cotizaciones   

	fetch next from cur_cotizaciones into @_especie_a_procesar,@_saldo_a_procesar

	while @@fetch_status = 0   
	begin   
		declare @cotizacion float, @fechaCotizacion datetime	
		declare @_moneda varchar(6)

		select @_moneda = espe_codloc from basecontrol
		select @fechaCotizacion = fecha from dbo.UltimaCotizacionConocidaFecha(@_especie_a_procesar,@_fecha,0,3,'BOLSA',@_moneda,'BOL',0)		
		select @cotizacion = (select dbo.ultimacotizacionconocida(@_especie_a_procesar,@_fecha,0,3,'BOLSA',@_moneda,'BOL',0))

		update #tempCuentas set 
			SaldoValorizado = (isnull(@_saldo_a_procesar * @cotizacion,0)), 
			Cotizacion = isnull(@cotizacion,0),
			FechaCotizacion = convert(varchar(10),@fechaCotizacion,103)
		where Especie = @_especie_a_procesar
		
		fetch next from cur_cotizaciones into @_especie_a_procesar, @_saldo_a_procesar		  

	end 

	close cur_cotizaciones   
	deallocate cur_cotizaciones

	create table #_tmp (
		Descripcion varchar(40),
		Moneda varchar(10),
		Saldo float,
		SaldoValorizado float
	)
	
	insert into #_tmp
	select 
		'' as 'Descripcion',
		t.Moneda as 'Moneda',
		sum(isnull(t.Saldo,0)) as 'Saldo',
		0.00 as 'SaldoValorizado'
	from
		(
			-- OPERACIONES A LIQUIDAR
			select 
				ltrim(rtrim(Especie)) as 'Moneda',
				Saldo as 'Saldo',
				SaldoValorizado as 'SaldoValorizado',
				0 as ID
			from
				#tempCuentas	
		
			union

			-- OPERACIONES A LIQUIDAR
			select 
				ltrim(rtrim(Moneda)) as 'Moneda',
				Monto as 'Saldo',
				SaldoValorizado as 'SaldoValorizado',
				0 as ID
			from
				#tempOperaciones
		) t 

	group by t.Moneda
	order by t.Moneda

	select 
		ltrim(rtrim(Descripcion)) as 'Descripcion',
		ltrim(rtrim(Moneda)) as 'Moneda',
		Saldo,
		SaldoValorizado
	from #_tmp 

	drop table #tempOperaciones
	drop table #tempCuentas
	drop table #_tmp

END

GO

exec GetDisponibilidad '4', 7, '20190221'
