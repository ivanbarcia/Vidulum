if exists(select * from sysobjects where name = 'SaldosPorClienteT10')
	drop procedure SaldosPorClienteT10
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
    
  create table #_ccus (  
  ccus_id int)  
  
  insert into #_ccus  
  select ccus_id from cuentas_custodia_vinculadas  
  where clie_alias = @_clie_alias  
    
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
 select ccus_id from #_ccus  
  
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
   (select isnull(t.ccm_monto,0) - isnull(saldo_inmovilizado, 0)) as 'Saldo',    
   isnull(t.monto_val,0) as 'SaldoValorizado',     
   cl.clie_nombreafip as 'Cliente'    
  from   
  tmp_saldos_tenencias_float t  
   inner join cuentas_custodia c on t.ccus_id = c.ccus_id  
  inner join especies es on t.espe_codigo = es.espe_codigo    
   inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo    
  inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id    
  inner join clientes cl on ccv.clie_alias = cl.clie_alias  and cl.clie_alias = @_clie_alias  
      
 fetch next from curCuentas into @_ccus_id  
 end  
 close curCuentas  
 deallocate curCuentas  
    
 --insert into #_tmp    
 --select     
 -- t.Tipo as 'Tipo',    
 -- t.Depositante as 'Depositante',    
 -- t.Comitente as 'Comitente',    
 -- t.Especie as 'Especie',    
 -- t.Descripcion as 'Descripcion',    
 -- null,    
 -- null,    
 -- sum(isnull(t.Saldo,0)) as 'Saldo',    
 -- null as 'SaldoValorizado',     
 -- t.Cliente as 'Cliente'    
 --from    
 -- (    
 --  select      
 --   te.tesp_descrip as 'Tipo',    
 --   c.tccus_alias as 'Depositante',    
 --   c.ccus_numero as 'Comitente',    
 --   m.espe_codigo as 'Especie',    
 --   es.espe_descrip as 'Descripcion',    
 --   m.ccm_monto * case m.ccm_tipomov when 'D' then -1 else 1 end as 'Saldo',    
 --   cl.clie_nombreafip as 'Cliente',    
 --   m.ccm_id ID    
 --  from    
 --   cuentas_custodia_movim m    
 --   inner join cuentas_custodia c on m.ccus_id = c.ccus_id    
 --   inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id    
 --   inner join clientes cl on ccv.clie_alias = cl.clie_alias    
 --   inner join especies es on m.espe_codigo = es.espe_codigo    
 --   inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo    
 --   inner join conceptos_cuentas_custodia ccc on m.concc_id = ccc.concc_id    
 --  where    
 --    m.ccm_fvalor <= @_fecha    
 --   and cl.clie_alias = @_clie_alias    
 --   and m.ccm_monto <> 0     
 --   and c.tccus_alias != 'MON'    
 --   and m.ccm_estado = 'A'    
 --   and c.ccus_id in (select ccus_id from #_ccus)  
 --      and ccc.concc_id not in (select concc_id from conceptos_cuentas_custodia where     
 --               concc_id < 100 and concc_esbloqueo = 1)    
 --   and ccc.concc_alias not in ('CTIT','VTIT','RLOPT')    
        
 --  union    
    
 --  select     
 --   te.tesp_descrip as 'Tipo',    
 --   c.tccus_alias as 'Depositante',    
 --   c.ccus_numero as 'Comitente',    
 --   o.espe_codigo as 'Especie',    
 --   es.espe_descrip as 'Descripcion',    
 --   o.oper_monto * case o.tope_suma when 1 then 1 else -1 end as 'Saldo',    
 --   cl.clie_nombreafip as 'Cliente',    
 --   o.oper_numero as ID    
 --  from     
 --   operaciones_vista o    
 --   inner join especies es on o.espe_codigo = es.espe_codigo    
 --   inner join tiposespecies te on te.tesp_codigo = es.tesp_codigo    
 --   inner join operaciones_datos od on o.oper_numero = od.oper_numero    
 --   inner join cuentas_custodia c on od.ccta_liqgali = c.ccus_id    
 --   inner join clientes cl on o.clie_alias = cl.clie_alias    
 --  where     
 --   o.clie_alias = @_clie_alias     
 --  and oper_forigen <=@_fecha    
 --  and esto_codigo not in ('N','C')    
 --  and tope_codigo in (101,102,103,104,131,132,133,134,401,402)    
 --  and od.ccta_liqgali in (select ccus_id from #_ccus)  
 --  and ISNULL(od.orden_numero,0) > 0     
    
 --  union    
    
 --  select     
 --   te.tesp_descrip as 'Tipo',    
 --   c.tccus_alias as 'Depositante',    
 --   c.ccus_numero as 'Comitente',    
 --   o.espe_codigo as 'Especie',    
 --   es.espe_descrip as 'Descripcion',    
 --   o.oper_monto * case o.tope_suma when 1 then -1 else 1 end as 'Saldo',    
 --   cl.clie_nombreafip as 'Cliente',    
 --   o.oper_numero as ID    
 --  from     
 --   operaciones_vista o    
 --   inner join especies es on o.espe_codigo = es.espe_codigo    
 --   inner join tiposespecies te on te.tesp_codigo = es.tesp_codigo    
 --   inner join operaciones_datos od on o.oper_numero = od.oper_numero    
 --   inner join cuentas_custodia c on od.ccta_liqgali = c.ccus_id    
 --   inner join clientes cl on o.clie_alias = cl.clie_alias    
 --  where     
 --   o.clie_alias = @_clie_alias     
 --  and oper_forigen <=@_fecha    
 --  and esto_codigo not in ('N','C')    
 --  and tope_codigo in (101,102,103,104,131,132,133,134,401,402,411,412,413,414,419,431,432,433,434,439)    
 --  and od.ccta_liqgali in (select ccus_id from #_ccus)   
 --  and ISNULL(od.orden_numero,0) = 0     
       
 --  ) t     
    
 --group by    
 -- t.Tipo ,    
 -- t.Depositante ,    
 -- t.Comitente ,    
 -- t.Especie ,    
 -- t.Descripcion ,    
 -- t.Cliente    
 --order by t.Tipo    
  
    
 delete from #_tmp where Saldo = 0    
    
 -- CUENTAS    
 --insert into #_tmp    
 --select     
 -- ' Cuentas' as 'Tipo',    
 -- c.tccus_alias as 'Depositante',    
 -- c.ccus_numero as 'Comitente',    
 -- ltrim(rtrim(m.espe_codigo)) as 'Especie',    
 -- es.espe_descrip as 'Descripcion',    
 -- null as 'Cotizacion',    
 -- null as 'FechaCotizacion',    
 -- sum(isnull(m.ccm_monto * case m.ccm_tipomov when 'D' then -1 else 1 end,0)) as 'Saldo',    
 -- null as 'SaldoValorizado',    
 -- cl.clie_nombreafip as 'Cliente'    
 --from    
 -- cuentas_custodia_movim m    
 -- inner join cuentas_custodia c on m.ccus_id = c.ccus_id    
 -- inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id    
 -- inner join clientes cl on ccv.clie_alias = cl.clie_alias    
 -- inner join especies es on m.espe_codigo = es.espe_codigo    
 -- inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo    
 -- --inner join cuentas_custodia_datos ccd on ccd.ccus_id = @_ccus_id_custodia    
 -- inner join conceptos_cuentas_custodia ccc on m.concc_id = ccc.concc_id    
 --where    
 -- m.ccm_fvalor <= @_fecha    
 -- --and m.ccus_id = 6    
 -- and cl.clie_alias = @_clie_alias    
 -- and m.ccm_monto <> 0     
 -- and ccv.tvcc_id = 1    
 -- and c.tccus_alias = 'MON'    
 -- --and ccd.ccud_sger_id = c.ccus_id    
 -- and m.ccm_estado = 'A'    
 --group by    
 -- c.tccus_alias,    
 -- c.ccus_numero,    
 -- m.espe_codigo,    
 -- es.espe_descrip,    
 -- cl.clie_nombreafip    
 
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
  declare @cotizacion float, @fechaCotizacion datetime     
      
  --select @cotizacion = cotiz, @fechaCotizacion = fecha from dbo.UltimaCotizacionConocidaFecha(@_especie_a_procesar,@_fecha,0,3,'',@_moneda,'BOL',1)      
  select @fechaCotizacion = pval_fecha,  
  @cotizacion = pval_precio  
 from preciovaluacion  
 where espe_codigo = @_especie_a_procesar
 and pval_origen = 'VCP'  
 and merc_codigo = 'LIB'
 and pval_fecha in (select max(pval_fecha) from preciovaluacion p2 where p2.espe_codigo = @_especie_a_procesar and p2.pval_fecha <= @_fecha and pval_origen = 'VCP' and merc_codigo = 'LIB')  
  
      
  --if ISNULL(@fechaCotizacion,'') <> ''    
  --begin    
  -- if (DATEADD(MONTH,-1,@_fecha) > @fechaCotizacion)    
  -- begin    
  --  select @cotizacion = 0, @fechaCotizacion = null    
  -- end    
  --end    
      
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
	ltrim(rtrim(Cliente)) as 'Cliente'
 from #_tmp

 union

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
	ltrim(rtrim(Cliente)) as 'Cliente'
 from #_tmp_detalle)
 order by Tipo asc    
    
 drop table #_tmp    
 drop table #_tmp_detalle    
 drop table #_ccus  
  
end    