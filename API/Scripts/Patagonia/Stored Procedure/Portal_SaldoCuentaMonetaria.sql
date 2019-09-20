if OBJECT_ID('dbo.SaldoCuentaMonetaria') is not null
begin
	drop procedure dbo.SaldoCuentaMonetaria
end
go

CREATE procedure dbo.SaldoCuentaMonetaria
( 
	@_clie_alias varchar(6), 
	@_ccus_id int,
	@_fecha datetime = null)
as
begin

	if (@_fecha is null)
		select @_fecha = CONVERT(char(8),getdate(),112)	

	create table #_tmp (
		Descripcion varchar(200),
		Saldo float,
		Cotizacion float null,
		SaldoValorizado float,		
		FechaCotizacion varchar(20) null,
		Especie varchar(6)	
	)

	insert into #_tmp
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


	delete from #_tmp where Saldo = 0

	
	/* se actualiza la tabla con la cotización de cada especie */

	declare @_especie_a_procesar varchar(6),	
			@_saldo_a_procesar money
	

	declare cur_cotizaciones cursor for
	select Especie,Saldo from #_tmp

	open cur_cotizaciones   

	fetch next from cur_cotizaciones into @_especie_a_procesar,@_saldo_a_procesar



	while @@fetch_status = 0   
	begin   
		declare @cotizacion float, @fechaCotizacion datetime	
		
		select @fechaCotizacion = fecha from dbo.UltimaCotizacionConocidaFecha(@_especie_a_procesar,@_fecha,0,3,'BOLSA',dbo.MonedaLocal(),'BOL',0)		
		select @cotizacion = (select dbo.ultimacotizacionconocida(@_especie_a_procesar,@_fecha,0,3,'BOLSA',dbo.MonedaLocal(),'BOL',0))
		
		update #_tmp set 

			SaldoValorizado = (isnull(@_saldo_a_procesar * @cotizacion,0)), 

			Cotizacion = isnull(@cotizacion,0),

			FechaCotizacion = convert(varchar(10),@fechaCotizacion,103)

		where Especie = @_especie_a_procesar

		
		fetch next from cur_cotizaciones into @_especie_a_procesar, @_saldo_a_procesar		  

	end 


	close cur_cotizaciones   

	deallocate cur_cotizaciones

	
	select 
		ltrim(rtrim(Descripcion)) as 'Descripcion',
		Saldo,
		Cotizacion,
		SaldoValorizado,		
		FechaCotizacion,
		ltrim(rtrim(Especie)) as 'Especie'
	from #_tmp 

	drop table #_tmp

end

GO
