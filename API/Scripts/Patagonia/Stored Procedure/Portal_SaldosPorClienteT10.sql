if OBJECT_ID('dbo.SaldosPorClienteT10') is not null
begin
	drop procedure dbo.SaldosPorClienteT10
end
go

CREATE procedure [dbo].[SaldosPorClienteT10]     
       (@_clie_alias varchar(6),    
        @_ccus_id int,    
        @_fecha datetime = null,
		@_montoDolares int = null)    
as    
begin    
    
 if (@_fecha is null)    
  select @_fecha = CONVERT(char(8),getdate(),112)    
    
  create table #_tmp_detalle (    
  Tipo varchar(40),    
  Depositante varchar(10),    
  Comitente int,    
  Especie varchar(6),    
  Descripcion varchar(40),    
  Cotizacion float null,    
  FechaCotizacion varchar(20) null,    
  Saldo float,    
  SaldoValorizado float,    
  Cliente varchar(200)     
 )    
      
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
  Cliente varchar(200)     
 )    
   
 declare curCuentas cursor for   
 select ccus_id 
 from cuentas_custodia_vinculadas 
 where clie_alias = @_clie_alias    
  
 open curCuentas  
 fetch next from curCuentas into @_ccus_id  
 while @@FETCH_STATUS = 0  
 begin  
  
  exec cuenta_custodia_movim_detalle @_fecha,@_fecha,@_ccus_id,1,13

  insert into #_tmp  
  select     
   te.tesp_descrip as 'Tipo',    
   c.tccus_alias as 'Depositante',    
   c.ccus_numero as 'Comitente',    
   es.espe_codigo as 'Especie',    
   es.espe_descrip as 'Descripcion',    
   t.precio_val,    
   convert(char(10),@_fecha,103),    
   isnull(t.saldo_disponible,0) as 'Saldo',    
   isnull(t.monto_val,0) as 'SaldoValorizado',     
   cl.clie_nombreafip as 'Cliente'    
  from   
  tmp_saldos_tenencias_float t  
   inner join cuentas_custodia c on t.ccus_id = c.ccus_id  
  inner join especies es on t.espe_codigo = es.espe_codigo    
   inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo    
  inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id    
  inner join clientes cl on ccv.clie_alias = cl.clie_alias  and cl.clie_alias = @_clie_alias 
  where 
	isnull(t.saldo_disponible,0) != 0
	and ltrim(rtrim(te.tesp_descrip)) != 'Billetes'
      
 fetch next from curCuentas into @_ccus_id  
 end  
 close curCuentas  
 deallocate curCuentas  
 
 /* se actualiza la tabla con la cotización de cada especie fondo */  
 declare @_especie_a_procesar varchar(6),     
  @_saldo_a_procesar float    
    
 declare cur_cotizaciones cursor for    
 select distinct Especie from #_tmp    
  where Especie in (select espe_codigo from especies where tesp_codigo ='F')  
  
 open cur_cotizaciones       
 fetch next from cur_cotizaciones into @_especie_a_procesar
    
 while @@fetch_status = 0       
 begin       
  declare @cotizacion float = 0, @fechaCotizacion datetime = null
      
  select @fechaCotizacion = pval_fecha, @cotizacion = pval_precio  
	from preciovaluacion  
	where espe_codigo = @_especie_a_procesar
 and pval_origen = 'VCP'  
 and merc_codigo = 'LIB'
 and pval_fecha in (select max(pval_fecha) from preciovaluacion p2 where p2.espe_codigo = @_especie_a_procesar and p2.pval_fecha <= @_fecha and pval_origen = 'VCP' and merc_codigo = 'LIB')  
  
  update #_tmp set     
   SaldoValorizado = (isnull(Saldo * @cotizacion,0)),     
   Cotizacion = isnull(@cotizacion,0),    
   FechaCotizacion = convert(varchar(10),@fechaCotizacion,103)    
  where Especie = @_especie_a_procesar    
  
  insert into #_tmp_detalle
  select  
	'' as 'Tipo',    
	'' as 'Depositante',    
	'',    
	Especie as 'Especie',    
	'' as 'Descripcion',    
	'',    
	'' as 'FechaCotizacion',    
	sum(Saldo),
	sum(SaldoValorizado),
	'' as 'Cliente'
  from #_tmp
  where Especie = @_especie_a_procesar
  group by Especie
    
	update t set
		t.Tipo = e.Tipo,
		t.Depositante = e.Depositante,
		t.Comitente = e.Comitente,
		t.Descripcion = e.Descripcion,
		t.Cotizacion = e.Cotizacion,
		t.FechaCotizacion = e.FechaCotizacion,
		t.Cliente = e.Cliente
	from
		#_tmp_detalle t
		inner join #_tmp e on e.Especie = t.Especie

	delete #_tmp where Especie = @_especie_a_procesar

  fetch next from cur_cotizaciones into @_especie_a_procesar
    
 end     
    
 close cur_cotizaciones       
 deallocate cur_cotizaciones 
 
if (@_montoDolares = 1)
begin
	declare @cotizacion_dolar float = (select top 1 pval_precio from preciovaluacion where espe_codigo = '02B' and merc_codigo = 'M20' and pval_fecha <= @_fecha order by pval_fecha desc)

	update t set
		SaldoValorizado = SaldoValorizado * @cotizacion_dolar
	from
		#_tmp t
		inner join especies e on e.espe_codigo = t.Especie
	where 
		e.espe_codcot = '02B'
end

-- ACCIONES Y BONOS
 (select 
	ltrim(rtrim(Tipo)) as 'Tipo',    
	ltrim(rtrim(Depositante)) as 'Depositante',    
	Comitente,    
	ltrim(rtrim(Especie)) as 'Especie',    
	ltrim(rtrim(Descripcion)) as 'Descripcion',    
	Cotizacion,    
	ltrim(rtrim(FechaCotizacion)) as 'FechaCotizacion',    
	Saldo,
	SaldoValorizado,    
	ltrim(rtrim(Cliente)) as 'Cliente',
	0.00 as 'TasaObjetivo',
	0.00 as 'RendimientoActual'
	-- isnull((select	
			-- top 1 VariacionCuota
		-- from 
			-- RendimientoFondos 
		-- where 
			-- Fondo = Especie),0) as 'TasaObjetivo',
	-- isnull((select	
			-- top 1 RendimientoDia
		-- from 
			-- RendimientoFondos 
		-- where 
			-- Fondo = Especie),0.00) as 'RendimientoActual'
 from #_tmp

 union

 -- FONDOS
 select 
	ltrim(rtrim(Tipo)) as 'Tipo',    
	ltrim(rtrim(Depositante)) as 'Depositante',    
	Comitente,    
	ltrim(rtrim(Especie)) as 'Especie',    
	ltrim(rtrim(Descripcion)) as 'Descripcion',    
	Cotizacion,    
	ltrim(rtrim(FechaCotizacion)) as 'FechaCotizacion',    
	Saldo,
	SaldoValorizado,    
	ltrim(rtrim(Cliente)) as 'Cliente',
	0.00 as 'TasaObjetivo',
	0.00 as 'RendimientoActual'
	-- isnull((select	
			-- top 1 VariacionCuota
		-- from 
			-- RendimientoFondos 
		-- where 
			-- Fondo = Especie),0) as 'TasaObjetivo',
	-- isnull((select	
			-- top 1 RendimientoDia
		-- from 
			-- RendimientoFondos 
		-- where 
			-- Fondo = Especie),0.00) as 'RendimientoActual'
 from #_tmp_detalle)

 order by Tipo asc    
    
 drop table #_tmp    
 drop table #_tmp_detalle    
  
end    

GO
