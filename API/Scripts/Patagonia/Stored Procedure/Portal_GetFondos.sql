if OBJECT_ID('dbo.GetFondos') is not null
begin
	drop procedure dbo.GetFondos
end
go

CREATE PROCEDURE dbo.GetFondos 
(
	@_clie_alias varchar = null
)
AS BEGIN

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

	declare @fecha varchar(8) = getdate()

	DECLARE @_ccus_id int

	declare curCuentas cursor for   
	select
		ccv.ccus_id
	from 
		cuentas_custodia_vinculadas ccv
		inner join cuentas_custodia cc on ccv.ccus_id = cc.ccus_id
	where 
		ccv.clie_alias = @_clie_alias  
		--and tccus_alias = 'FCI'
		and ccus_estado = 'A'  
  
	open curCuentas  
	fetch next from curCuentas into @_ccus_id  
	while @@FETCH_STATUS = 0  
	begin  
		exec cuenta_custodia_movim_detalle @fecha,@fecha,@_ccus_id,1,13

		insert into
			#_tmp
		select
			te.tesp_descrip as 'Tipo',
			c.tccus_alias as 'Depositante',
			c.ccus_numero as 'Comitente',
			es.espe_codigo as 'Especie',
			es.espe_descrip as 'Descripcion',
			t.precio_val,
			convert(char(10),@fecha,103),
			(select isnull(t.saldo_disponible,0) - isnull(saldo_inmovilizado, 0)) as 'Saldo',
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
			inner join clientes cl on ccv.clie_alias = cl.clie_alias  and cl.clie_alias = @_clie_alias
		where 
			es.tesp_codigo = 'F'
      
		fetch next from curCuentas into @_ccus_id  
	end  
	close curCuentas  
	deallocate curCuentas  

	delete from #_tmp where Saldo = 0

	DECLARE @cotizacion float
	DECLARE @fechaCotizacion datetime    

	update #_tmp set     
	SaldoValorizado = (isnull(Saldo * @cotizacion,0)),     
	Cotizacion = isnull(@cotizacion,0),    
	FechaCotizacion = convert(varchar(10),@fechaCotizacion,103)
	
	declare @totalMonto float
	declare @totalCP float

	set @totalMonto = isnull((select sum(SaldoValorizado) from #_tmp),0)
	set @totalCP = isnull((select sum(Saldo) from #_tmp),0)
	
	select 
		ltrim(rtrim(espe_codigo)) as 'Codigo', 
		ltrim(rtrim(espe_descrip)) as 'Descripcion',
		ltrim(rtrim(espe_codcot)) as Moneda,
		cast(isnull((select top 1 pval_precio from preciovaluacion where pval_origen = 'VCP' and espe_codigo = espe_codigo order by pval_fechora desc),0) as decimal(18,6)) as ValorCuotaParte,
		cast(@totalMonto as decimal(18,2)) as TotalMonto,
		cast(@totalCP as decimal(18,6)) as TotalCP,
		0 as CuentaMonetaria,
		0 as CuentaFondo,
		0.00 as 'TasaObjetivo',
		0.00 as 'RendimientoActual'
		-- isnull((select	
				-- top 1 VariacionCuota
			-- from 
				-- RendimientoFondos 
			-- where 
				-- Fondo = espe_codigo),0) as 'TasaObjetivo',
		-- isnull((select	
				-- top 1 RendimientoDia
			-- from 
				-- RendimientoFondos 
			-- where 
				-- Fondo = espe_codigo),0) as 'RendimientoActual'
	from 
		especies 
	where 
		tesp_codigo = 'F'

END
