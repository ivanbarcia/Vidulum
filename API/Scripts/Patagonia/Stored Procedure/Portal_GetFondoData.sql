if OBJECT_ID('dbo.GetFondoData') is not null
begin
	drop procedure dbo.GetFondoData
end
go

CREATE PROCEDURE dbo.GetFondoData
(
	@espe_codigo varchar(max),
	@clie_alias varchar(max)
)
AS BEGIN

	DECLARE @_fecha varchar(8)
	
	select @_fecha = CONVERT(char(8),getdate(),112)
	
	create table #_tmp (
		Tipo varchar(40),
		Depositante varchar(10),
		Comitente int,
		Especie varchar(6),
		Descripcion varchar(40),
		Cotizacion float null,
		FechaCotizacion varchar(20) null,
		Saldo float,
		SaldoValorizado float,
		Cliente varchar(200),
		TasaObjetivo float,
		RendimientoActual float
	)

	DECLARE @_ccus_id int

	declare curCuentas cursor for   
	select
		ccv.ccus_id
	from 
		cuentas_custodia_vinculadas ccv
		inner join cuentas_custodia cc on ccv.ccus_id = cc.ccus_id
	where 
		ccv.clie_alias = @clie_alias  
		and tccus_alias = 'FCI'
		and ccus_estado = 'A'
  
	open curCuentas  
	fetch next from curCuentas into @_ccus_id  
	while @@FETCH_STATUS = 0  
	begin  
		exec cuenta_custodia_movim_detalle @_fecha,@_fecha,@_ccus_id,1,13

		insert into
			#_tmp
		select
			te.tesp_descrip as 'Tipo',
			c.tccus_alias as 'Depositante',
			c.ccus_numero as 'Comitente',
			es.espe_codigo as 'Especie',
			es.espe_descrip as 'Descripcion',
			t.precio_val as 'Cotizacion',
			convert(char(10),@_fecha,103),
			isnull(t.Saldo_total,0) as 'Saldo',
			isnull(t.monto_val,0) as 'SaldoValorizado',
			cl.clie_nombreafip as 'Cliente',
			0 as 'TasaObjetivo',
			0 as 'RendimientoActual'
		from
			tmp_saldos_tenencias_float t
			inner join cuentas_custodia c on t.ccus_id = c.ccus_id
			inner join especies es on t.espe_codigo = es.espe_codigo
			inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo
			inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id
			inner join clientes cl on ccv.clie_alias = cl.clie_alias  and cl.clie_alias = @clie_alias
		where 
			es.espe_codigo = @espe_codigo
      
		fetch next from curCuentas into @_ccus_id  
	end  
	close curCuentas  
	deallocate curCuentas  

	delete from #_tmp where Saldo = 0

	DECLARE @cotizacion float
	DECLARE @fechaCotizacion datetime    

	select 
		@fechaCotizacion = pval_fecha,
		@cotizacion = pval_precio
	from 
		preciovaluacion
	where 
		espe_codigo = @espe_codigo
		and pval_origen = 'VCP'  
		and merc_codigo = 'LIB'
		and pval_fecha in (select max(pval_fecha) from preciovaluacion p2 where p2.espe_codigo = @espe_codigo and p2.pval_fecha <= @_fecha and pval_origen = 'VCP' and merc_codigo = 'LIB')  
  
	update #_tmp set     
	SaldoValorizado = (isnull(Saldo * @cotizacion,0)),     
	Cotizacion = isnull(@cotizacion,0),    
	FechaCotizacion = convert(varchar(10),@fechaCotizacion,103)
	
	declare @valorCP float
	declare @totalMonto float
	declare @totalCP float

	set @valorCP = isnull((select top 1 pval_precio from preciovaluacion where pval_origen = 'VCP' and espe_codigo = @espe_codigo order by pval_fechora desc),0)
	set @totalCP = isnull((select sum(Saldo) from #_tmp),0)
	set @totalMonto = isnull(@totalCP * @valorCP,0)

	select 
		ltrim(rtrim(espe_codigo)) as Codigo,
		ltrim(rtrim(espe_descrip)) as Descripcion, 
		ltrim(rtrim(espe_codcot)) as Moneda,
		cast(@valorCP as decimal(18,6)) as ValorCuotaParte,
		cast(@totalMonto as decimal(18,2)) as TotalMonto,
		cast(@totalCP as decimal(18,6)) as TotalCP,
		isnull((select	
				top 1 c.ccus_id
			from 
				cuentas_custodia c 
				inner join cuentas_custodia_vinculadas ccv on ccv.ccus_id = c.ccus_id 
			where 
				ccv.clie_alias = @clie_alias
			and c.espe_codigo = e.espe_codcot),0) as CuentaMonetaria,
		(select	
				top 1 c.ccus_id
			from 
				cuentas_custodia c 
				inner join cuentas_custodia_vinculadas ccv on ccv.ccus_id = c.ccus_id 
			where 
				ccv.clie_alias = @clie_alias
			and c.tccus_alias = 'FCI'
			and c.ccus_estado = 'A') as CuentaFondo,
		0.00 as 'TasaObjetivo',
		0.00 as 'RendimientoActual'
		 -- isnull((select	
				 -- top 1 VariacionCuota
			 -- from 
				 -- RendimientoFondos 
			 -- where 
				 -- Fondo = @espe_codigo),0) as 'TasaObjetivo',
		 -- isnull((select	
				 -- top 1 RendimientoDia
			 -- from 
				 -- RendimientoFondos 
			 -- where 
				 -- Fondo = @espe_codigo),0) as 'RendimientoActual'
	from 
		especies e
	where 
		ltrim(rtrim(espe_codigo)) = @espe_codigo


	drop table #_tmp
END
