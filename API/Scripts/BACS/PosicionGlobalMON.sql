if exists(select * from sysobjects where name = 'PosicionGlobalMON')
	drop procedure PosicionGlobalMON
go

create procedure [dbo].PosicionGlobalMON 
		(
			@_clie_alias varchar(6),
			@_fecha datetime,
			@_ccus_id_TIT int
		)
as
begin

	if @_clie_alias is null or @_clie_alias = ''
	begin
		select @_clie_alias = clie_alias from cuentas_custodia_vinculadas where ccus_id = @_ccus_id_TIT and tvcc_id = 1
	end

	declare @_fecha_a_usar datetime
	select @_fecha_a_usar = CONVERT(char(8),@_fecha,112)

	create table #_tmp (
		Descripcion varchar(40),
		Saldo float		
	)
	insert into #_tmp	
	select 
		t.Descripcion, 
		sum(isnull(t.Saldo,0)) as 'Saldo'
	from 
		(
			select 
				es.espe_descrip as 'Descripcion', 
				isnull(
						m.ccm_monto
						* case m.ccm_tipomov when 'D' then -1 else 1 end,0) as 'Saldo',
				ltrim(rtrim(m.espe_codigo)) 'Especie',
				m.ccm_id
			from
				cuentas_custodia_movim m
				inner join cuentas_custodia c on m.ccus_id = c.ccus_id
				inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id
				inner join clientes cl on ccv.clie_alias = cl.clie_alias
				inner join especies es on m.espe_codigo = es.espe_codigo
				inner join tiposespecies te on es.tesp_codigo = te.tesp_codigo
				--inner join cuentas_custodia_datos ccd on ccd.ccus_id = @_ccus_id_TIT
				inner join conceptos_cuentas_custodia ccc on m.concc_id = ccc.concc_id
			where
				ccv.tvcc_id = 1
				and m.ccm_fvalor <= @_fecha
				and cl.clie_alias = @_clie_alias
				and m.ccm_monto <> 0	
				and c.tccus_alias = 'MON'
				--and ccd.ccud_sger_id = c.ccus_id
				and m.ccm_estado = 'A') t 
	group by t.Especie, 
		     t.Descripcion
	order by t.Descripcion

	/*
	insert into #_tmp
	select distinct
		es.espe_descrip 'Descripcion',
		isnull(ccs.ccs_saldo,0) + isnull(t.Monto,0) 'Saldo'
	from
		cuentas_custodia_saldos ccs
		inner join cuentas_custodia c on ccs.ccus_id = c.ccus_id
		inner join cuentas_custodia_datos ccd on ccd.ccud_sger_id = c.ccus_id
		inner join cuentas_custodia_vinculadas ccv on c.ccus_id = ccv.ccus_id
		inner join clientes cl on ccv.clie_alias = cl.clie_alias
		inner join especies es on ccs.espe_codigo = es.espe_codigo

		full outer join (
			select 
				espe_codigo,
				sum(oper_monto * case tope_suma when 1 then 1 else -1 end) Monto  
			from 
				operaciones_vista 
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			group by espe_codigo
			union
			select 
				espe_codcot espe_codigo,
				sum(oper_monto * case tope_suma when 1 then -1 else 1 end * oper_precio) Monto  
			from 
				operaciones_vista 
			where 
				clie_alias = @_clie_alias 
			and oper_fvence >=@_fecha_a_usar
			and esto_codigo not in ('N','C')
			and tope_codigo in (101,102,103,104,131,132,133,134)
			group by espe_codcot
			) t on ccs.espe_codigo = t.espe_codigo	
	where
		ccs_fecha = @_fecha_a_usar
	and cl.clie_alias = @_clie_alias
	and ccs.ccs_saldo <> 0	
	and ccd.ccus_id = @_ccus_id_TIT
	
	*/
	
	select * from #_tmp 
	drop table #_tmp

end