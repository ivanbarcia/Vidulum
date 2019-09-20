if OBJECT_ID('dbo.SaldosPorClienteT10_Grafico') is not null
begin
	drop procedure dbo.SaldosPorClienteT10_Grafico
end
go

CREATE procedure [dbo].[SaldosPorClienteT10_Grafico]     
       (@_clie_alias varchar(6),    
        @_ccus_id int,    
        @_fecha datetime = null)    
as    
begin    
    
	if (@_fecha is null)    
		select @_fecha = CONVERT(char(8),getdate(),112)    
    
	create table #_tmp (    
	  Especie varchar(6),    
	  Descripcion varchar(40),    
	  SaldoValorizado float
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
			es.espe_codigo as 'Especie',    
			es.espe_descrip as 'Descripcion',    
			isnull(t.saldo_disponible,0) as 'SaldoValorizado'
		from   
			tmp_saldos_tenencias_float t  
			inner join cuentas_custodia c on t.ccus_id = c.ccus_id  
			inner join especies es on t.espe_codigo = es.espe_codigo    
			inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo    
			inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id    
			inner join clientes cl on ccv.clie_alias = cl.clie_alias  and cl.clie_alias = @_clie_alias 
		where 
			isnull(t.saldo_disponible,0) > 0
		and te.tesp_descrip != 'Billetes'
      
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
	   SaldoValorizado = (isnull(SaldoValorizado * @cotizacion,0))    
	  where Especie = @_especie_a_procesar    
  
	  fetch next from cur_cotizaciones into @_especie_a_procesar
    
	 end     
    
	 close cur_cotizaciones       
	 deallocate cur_cotizaciones   
    
	declare @cotizacion_dolar float = (select top 1 pval_precio from preciovaluacion where espe_codigo = '02B' and merc_codigo = 'M20' and pval_fecha <= @_fecha order by pval_fecha desc)

	update t set
		SaldoValorizado = round(SaldoValorizado,2) * @cotizacion_dolar
	from
		#_tmp t
		inner join especies e on e.espe_codigo = t.Especie
	where 
		e.espe_codcot = '02B'

	--- RESULTADO ---
	select
		Especie as 'Especie',
		Descripcion as 'Descripcion',
		sum(SaldoValorizado) as 'SaldoValorizado'   
	from 
		#_tmp
	group by
		Especie, Descripcion
	order by 
		especie
    
	drop table #_tmp    
  
end    

GO

