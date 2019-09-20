
if exists(select * from sysobjects where type = 'p' and name = 'EstadoDeCuenta') 
 begin 
     drop procedure EstadoDeCuenta 
 end 
 go 
 
CREATE procedure [dbo].[EstadoDeCuenta] (
		@_fdesde datetime,
		@_fhasta datetime,
		@_ccus_id int,
		@_incluir_bloqueos int = 1,	
		@_caso int = 0,
		@_espe_tenencia varchar(6) = null,
		@_saldo_disponible money = null output	
) as begin

create table #_tmp_saldos_especie (
			espe_codigo		varchar(6)	 collate database_default	,	
			ccm_monto	money null	,
			precio_val decimal(38,25) null,
			monto_val	money null,
			ccus_numero	varchar(500) collate database_default null	,						
			fecha_precios datetime null,
			PPCpa decimal(38,25) null,
			PPVta decimal(38,25) null,
			Rendimiento decimal(38,25) null,
			saldo_disponible money null,
			saldo_bloqueado money null,
			Saldo_total		money null,
			descripcion_bloqueos varchar(400) collate database_default null,
			saldo_inmovilizado money null,
			saldo_bloqueado_interno money null,
			saldo_bloqueado_externo money null
	)
	

	
	create table #_tmp_detalle_mov (
			ccm_id			int				,
			ccm_fvalor		datetime		,
			espe_codigo		varchar(6)	 collate database_default	,
			concc_id		int				,
			concc_descrip	varchar(300) collate database_default	,
			ccm_tipomov		char(1)	 collate database_default		,
			ccm_monto		money           ,
			ccm_falta		datetime null	,
			saldo_parcial	money   null	,
			precio_val		decimal(38,25)   null	,
			ccus_id			int	    null	,
			ccus_numero		int		null	,
			fecha_precios	datetime null	,
			oper_numero		int		null	,
			titular			varchar(300)  collate database_default null,
			ccus_numero_tit	varchar(500)  collate database_default null,
			concc_esbloqueo	int		null,
			espe_descrip	varchar(1000) collate database_default null,
			codigo_cv		varchar(50) collate database_default null,
			codigo_ISIN  varchar(50) collate database_default null,
			codigo_bolsa varchar(50) collate database_default null,
			PPCpa			decimal(38,25) null,
			PPVta			decimal(38,25) null,
			Rendimiento		decimal(38,25) null,
			oper_monto		money null,
			saldo_disponible money,
			saldo_bloqueado money,
			Saldo_total		money,
			descripcion_bloqueos varchar(400) collate database_default,
			saldo_inmovilizado money,
			saldo_bloqueado_interno money null,
			saldo_bloqueado_externo money null
	)
	
	create table #_tmp_especies_sin_saldoini (
			espe_codigo		varchar(6) collate database_default	
	)
	
	declare
			@_espe_codigo			varchar(6) ,
			@_ccm_monto				money		,
			@_espe_codigo_actual	varchar(6) ,
			@_saldo_parcial			money		,
			@_ccm_id				int


	insert into #_tmp_detalle_mov (
			ccm_id			,
			ccm_fvalor		,
			espe_codigo		,
			concc_id		,
			concc_descrip	,
			ccm_tipomov		,
			ccm_monto		,
			ccus_id			,
			saldo_parcial	,
			saldo_disponible,
			saldo_bloqueado ,
			Saldo_total		,	
			saldo_inmovilizado,
			saldo_bloqueado_interno,
			saldo_bloqueado_externo,
			espe_descrip
	)
	select 
			0							,		
			DATEADD(day, -1, @_fdesde)	,
			ltrim(rtrim(c.espe_codigo)),
			0							,		
			'Saldo Inicial'				,
			'C'							,
			saldo = case @_incluir_bloqueos
				when 1 then isnull( c.ccs_saldo_disponible ,0)
				when 0 then isnull( c.ccs_saldo ,0)
			end							,
			c.ccus_id						,
			saldo_parcial = case @_incluir_bloqueos
				when 1 then	isnull( c.ccs_saldo_disponible ,0)
				when 0 then isnull( c.ccs_saldo ,0)
			end,
			c.ccs_saldo_disponible,
			c.ccs_saldo_bloqueado,
			c.ccs_saldo,
			c.ccs_saldo_inmovilizado,
			c.ccs_saldo_bloqueado_interno,
			c.ccs_saldo_bloqueado_externo,
			e.espe_descrip
	from 
			cuentas_custodia_saldos c left join especies e on c.espe_codigo = e.espe_codigo
	where
			c.ccs_fecha = (select max(ccs_fecha) from cuentas_custodia_saldos where ccs_fecha <= @_fdesde) 
	  and	c.ccus_id = isnull(@_ccus_id, c.ccus_id)


	insert into #_tmp_detalle_mov (
			ccm_id			,
			ccm_fvalor		,
			espe_codigo		,
			concc_id		,
			concc_descrip	,
			ccm_tipomov		,
			ccm_monto		,
			ccm_falta		,
			oper_numero		,
			ccus_id			,
			concc_esbloqueo ,
			saldo_bloqueado	,
			saldo_disponible,
			saldo_inmovilizado,
			Saldo_total,
			saldo_bloqueado_interno,
			saldo_bloqueado_externo,
			espe_descrip
	)
	select 
			m.ccm_id			,
			m.ccm_fvalor		,
			ltrim(rtrim(m.espe_codigo)),
			m.concc_id			,		
			c.concc_descrip		,
			ccm_tipomov			,
			ccm_monto           ,
			ccm_falta			,
			oper_numero			,
			ccus_id				,
			c.concc_esbloqueo	,
			case c.concc_esbloqueo 
				when 1 then	
					case when c.concc_id >= 100 then 
						m.ccm_monto 
						else 0 end
					else 0 end,
			ccm_monto,
			case c.concc_esbloqueo 
				when 1 then	
					case when c.concc_id < 100 then 
						m.ccm_monto 
						else 0 end
					else 0 end,
			case c.concc_esbloqueo 
				when 1 then	
					case when c.concc_id < 100 then 
						0
						else ccm_monto end
					else ccm_monto end,
			case c.concc_esbloqueo 
							when 1 then	
								case when c.concc_id >= 100 then 
									case when c.concc_tipobloqueo = 'I' then
										m.ccm_monto 
										else 0 end
									else 0 end
								else 0 end		,			
			case c.concc_esbloqueo 
							when 1 then	
								case when c.concc_id >= 100 then 
									case when c.concc_tipobloqueo = 'E' then
										m.ccm_monto 
										else 0 end
									else 0 end
								else 0 end,
			e.espe_descrip									
	from 
			cuentas_custodia_movim m left join especies e on e.espe_codigo = m.espe_codigo,
			conceptos_cuentas_custodia c   
			
	where
			ccm_estado = 'A'
	  and	c.concc_id = m.concc_id
	  and	ccm_fvalor >= @_fdesde
	  and	ccm_fvalor <= @_fhasta
	  and	ccus_id = isnull(@_ccus_id, ccus_id)
	  and	m.concc_id not in (8,9) -- no se inserta las Inmov. y Anul. Inmov. de Tenencia por Op TIT
	order by ccm_fvalor
	
	if @_caso = 5 or @_caso = 6 or @_caso = 7 or @_caso = 8 or @_caso = 9 or @_caso = 10 or @_caso = 11 or @_caso = 12
	begin
		goto TENENCIA_TIT
	end
	
	if @_caso = 1 or @_caso = 3
	begin
			
			delete from #_tmp_detalle_mov where concc_esbloqueo = 1
			goto TENENCIA
	end


	insert into #_tmp_especies_sin_saldoini ( espe_codigo )
	select 
			distinct ltrim(rtrim(espe_codigo))
	from 
			#_tmp_detalle_mov 
	where 
			concc_id > 0		
	  and	espe_codigo not in		
				(select distinct espe_codigo from #_tmp_detalle_mov where concc_id = 0)
	
	insert into #_tmp_detalle_mov (
			ccm_id			,
			ccm_fvalor		,
			espe_codigo		,
			concc_id		,
			concc_descrip	,
			ccm_tipomov		,
			ccm_monto		,
			saldo_parcial   ,
			espe_descrip    ,
			ccus_id
	)
	select 
			0							,				
			DATEADD(day, -1, @_fdesde)	,
			ltrim(rtrim(t.espe_codigo)),
			0							,		
			'Saldo Inicial'				,
			'C'							,
			0.00            			,
			0.0                         ,
			e.espe_descrip              ,
			@_ccus_id
	from 
			#_tmp_especies_sin_saldoini t left join especies e on e.espe_codigo = t.espe_codigo



	if (@_incluir_bloqueos = 0) and (@_caso <> 5)

		delete from #_tmp_detalle_mov where concc_esbloqueo = 1  

	declare c_movim cursor for
	select
			ccm_id			,
			espe_codigo		,
			ccm_monto =	( charindex( 'C', ccm_tipomov) * ccm_monto 
						- charindex( 'D', ccm_tipomov) * ccm_monto 	)
	from
			#_tmp_detalle_mov
	order by
			espe_codigo		,
			ccm_fvalor		,
			ccm_tipomov,  --- ccm_tipomov para que se muestre los movimiento de credito primero
			ccm_falta
	
	open c_movim
	
	fetch c_movim into @_ccm_id, @_espe_codigo, @_ccm_monto
	
	select 
			@_espe_codigo_actual	= @_espe_codigo	,
			@_saldo_parcial			= 0
	
	while (@@FETCH_STATUS = 0)
	begin
			
			
			select @_saldo_parcial = @_saldo_parcial + @_ccm_monto
			
			update #_tmp_detalle_mov set
					saldo_parcial = @_saldo_parcial
			where
					ccm_id			= @_ccm_id
			  and	espe_codigo		= @_espe_codigo	
		
			
			fetch c_movim into @_ccm_id, @_espe_codigo, @_ccm_monto		
			
			
			
			if ( @_espe_codigo_actual != @_espe_codigo ) or (@@FETCH_STATUS != 0)
			begin	
					insert into #_tmp_detalle_mov (
							ccm_id			,
							ccm_fvalor		,
							espe_codigo		,
							concc_id		,
							concc_descrip	,
							ccm_tipomov		,
							ccm_monto		,
							saldo_parcial	,
							ccm_falta		
					)
					select 
							99999999					,	
							@_fhasta ,
							@_espe_codigo_actual		,
							99							,	
							'Saldo Disponible'			,
							'C'							,	
							saldo = @_saldo_parcial     ,
							@_saldo_parcial				,
							dateadd(day,1,@_fhasta)
					
					select 
							@_espe_codigo_actual	= @_espe_codigo	,
							@_saldo_parcial			= 0
			end
					
			
				
	end			
	
	close c_movim
	deallocate c_movim
			

	if (@_caso = 0 or @_caso = 4)
	begin

		if @_ccus_id is null
			delete from #_tmp_detalle_mov
	

		update #_tmp_detalle_mov set
				concc_descrip = LTRIM(rtrim(concc_descrip)) + ' (Nro.: ' + STR(s.sfon_id) + ')'
		from
				#_tmp_detalle_mov t		,
				solicitudes_fondos s
		where
				t.oper_numero = s.oper_numero
		 and	t.concc_id in (1,2,5)

		update #_tmp_detalle_mov set
				concc_descrip = LTRIM(rtrim(concc_descrip)) + ' (Nro.: ' + STR(s.sfon_id) + ')'
		from
				#_tmp_detalle_mov t		,
				solicitudes_fondos s
		where
				t.oper_numero = s.sfon_id
		 and	t.concc_id in (4)
		 

		update #_tmp_detalle_mov set
				concc_descrip = LTRIM(rtrim(concc_descrip)) + ' (Nro.: ' + ltrim(rtrim(STR(t.oper_numero))) + ')'
		from
				#_tmp_detalle_mov t
		where
				t.concc_id in (8,9,39,40,41,42)
				
		update #_tmp_detalle_mov set 
				concc_descrip = ltrim(rtrim(t.tope_descrip)) + ' ' + LTRIM(rtrim(o.espe_codigo)) + ' (Nro.: ' +  ltrim(rtrim(STR(o.oper_numero))) + ')'
			from
				operaciones o inner join tiposoper t on o.tope_codigo = t.tope_codigo
			where #_tmp_detalle_mov.oper_numero = o.oper_numero
			and ISNULL(#_tmp_detalle_mov.oper_numero,0) > 0		
			and #_tmp_detalle_mov.concc_id in (11,19,20,13,14,15,16,17,18,25,37,38)
			
		print 'paso a compra'
		Update #_tmp_detalle_mov
		set concc_descrip= REPLACE (concc_descrip, 'Venta','Compra')
		where ccm_id=@_ccm_id
		and concc_id in (19,20,25)
		and ccm_tipomov='C'
		
		print 'paso a Venta'
		Update #_tmp_detalle_mov
		set concc_descrip= REPLACE (concc_descrip, 'Compra','Venta')
		where ccm_id=@_ccm_id
		and concc_id in (19,20,25)
		and ccm_tipomov='D'
			  
		update #_tmp_detalle_mov set 
				concc_descrip =  LTRIM(rtrim(c.concc_descrip)) + ' ' + LTRIM(rtrim(#_tmp_detalle_mov.espe_codigo))
			from
				conceptos_cuentas_custodia c
			where #_tmp_detalle_mov.concc_id = c.concc_id
			and ISNULL(#_tmp_detalle_mov.oper_numero,0) = 0		

		update #_tmp_detalle_mov set
				concc_descrip = LTRIM(rtrim(concc_descrip)) + ' Certificado: ' + isnull(STR(pfij_nrocert), '')
		from
				#_tmp_detalle_mov t		,
				plazofijo p
		where
				t.oper_numero = p.oper_numero
		  and	t.concc_id in (10)
		 
		update #_tmp_detalle_mov set
				concc_descrip = LTRIM(rtrim(t.concc_descrip)) + ' Certificado: ' + isnull(STR(pfij_nrocert), '')
		from
				#_tmp_detalle_mov t		,
				plazofijo p				,
				conceptos_cuentas_custodia c
		where
				t.oper_numero = p.oper_numero
		  and	t.concc_id = c.concc_id
		  and	c.concc_alias = 'VPFT'
		
		if not exists( select * from ExtractoClienteFoto 
				   where ccus_id = @_ccus_id 
							and CONVERT(varchar(8),FDesde,112) = @_fdesde 
							and CONVERT(varchar(8),FHasta,112) = @_fhasta)
							
		begin
			print '1ra vez-> inserto'
			insert into ExtractoClienteFoto
			select
				ccm_id			,
				ccm_fvalor		,
				espe_codigo		,
				concc_id		,
				concc_descrip	,
				ccm_tipomov		,
				ccm_monto       ,
				ccm_falta		,
				saldo_parcial   ,
				precio_val		,
				ccus_id			,
				ccus_numero		,
				fecha_precios	,
				oper_numero		,
				titular			,
				ccus_numero_tit	,
				concc_esbloqueo	,
				espe_descrip	,
				codigo_cv		,
				codigo_ISIN  ,
				codigo_bolsa ,
				PPCpa			,
				PPVta			,
				Rendimiento		,
				oper_monto		,
				@_fdesde        ,
				@_fhasta
			from  #_tmp_detalle_mov
			where concc_id <> 99 
			order by espe_codigo, ccm_fvalor		
		end
		
		if @_caso = 0
		begin
				print 'no es 1ra vez-> leo de tabla'
			select 
				ccm_id			,
				ccm_fvalor		,
				espe_codigo		,
				concc_id		,
				concc_descrip	,
				ccm_tipomov		,
				case ccm_tipomov when 'D' then (-1) * ccm_monto else ccm_monto end as ccm_monto		,
				ccm_falta		,
				saldo_parcial,
				precio_val		,
				ccus_id			,
				ccus_numero		,
				fecha_precios	,
				oper_numero		,
				titular			,
				ccus_numero_tit	,
				concc_esbloqueo	,
				espe_descrip	,
				codigo_cv		,
				codigo_ISIN  ,
				codigo_bolsa ,
				PPCpa			,
				PPVta			,
				Rendimiento		,
				oper_monto		 
			from ExtractoClienteFoto 
			where ccus_id = @_ccus_id 
			and CONVERT(varchar(8),FDesde,112) = @_fdesde 
			and CONVERT(varchar(8),FHasta,112) = @_fhasta 
			order by espe_codigo, ccm_fvalor, ccm_tipomov	--- ccm_tipomov para que se muestre los movimiento de credito primero
			
			declare @_titulo varchar(100)
			if exists (select * from cuentas_custodia where ccus_id = @_ccus_id
						and tccus_alias = 'FCI')
				select @_titulo = 'Detalle de Movimientos de Cuenta Cuotapartista'
			else
				if exists (select * from cuentas_custodia c , tiposcuentas_custodia t
							where c.ccus_id = @_ccus_id
							and t.tccus_alias = c.tccus_alias
							and ISNULL(t.cartera_propia,0) = 0)
					select @_titulo = 'Detalle de Movimientos de Cuenta Custodia'		
				else
					select @_titulo = 'Detalle de Movimientos de Cartera Propia'		
					
		
			 select
						CONVERT(varchar(10),@_fdesde,103)	FDesde		,
						CONVERT(varchar(10),@_fhasta,103)	FHasta		,
						CuentaNro = (select ccus_numero from cuentas_custodia where ccus_id = @_ccus_id),
						Titular = rtrim(ltrim(ISNULL(clie_apellido,''))) + ' ' + rtrim(ltrim(ISNULL(clie_nombre,''))),
						titulo = @_titulo
				from	
						cuentas_custodia_vinculadas cv	,
						clientes c
				where
						cv.ccus_id	= @_ccus_id
				  and	cv.tvcc_id = 1				
				  and	c.clie_alias = cv.clie_alias
		end
		else
		begin
			if @_caso = 4
			begin
				delete from tmp_detalle_mov
				
				insert into tmp_detalle_mov
				select * from #_tmp_detalle_mov
				where
						concc_id <> 99
				order by
						espe_codigo		,
						ccm_fvalor		,
						ccm_tipomov,	--- ccm_tipomov para que se muestre los movimiento de credito primero
						ccm_falta		
			end
		end				
	end

TENENCIA:	

	if @_caso = 1
	begin
			delete from #_tmp_detalle_mov
			where ccus_id not in (select ccus_id from cuentas_custodia 
								where tccus_alias = 'FCI')
			
			update #_tmp_detalle_mov set
				precio_val = p.pval_precio	,
				fecha_precios = pval_fecha
			from
					#_tmp_detalle_mov t	,
					preciovaluacion p
			where
					t.espe_codigo = p.espe_codigo
			and		p.pval_fecha = (
							select MAX(pval_fecha) from preciovaluacion 
										where espe_codigo = t.espe_codigo
												and pval_fecha <= @_fdesde	)
			
			update #_tmp_detalle_mov set
				oper_monto = o.oper_monto
			from
				operaciones o , #_tmp_detalle_mov t
			where
				o.oper_numero = t.oper_numero
				
		
			update #_tmp_detalle_mov set PPCpa = 0, PPVta = 0, Rendimiento = 0
			
			update #_tmp_detalle_mov set
			PPCpa = r.PP 
			from #_tmp_detalle_mov t,	
				(select
					PP = SUM(ccm_monto) / SUM(oper_monto),
					t.espe_codigo
				from
					#_tmp_detalle_mov t
				where
					oper_numero > 0
				and t.ccm_tipomov = 'C'	
				group by t.espe_codigo) r
			where
				t.espe_codigo = r.espe_codigo

			
			update #_tmp_detalle_mov set
			PPVta = r.PP 
			from #_tmp_detalle_mov t,	
				(select
					PP = SUM(ccm_monto) / SUM(oper_monto),
					t.espe_codigo
				from
					#_tmp_detalle_mov t
				where
					oper_numero > 0
				and t.ccm_tipomov = 'D'	
				group by t.espe_codigo) r
			where
				t.espe_codigo = r.espe_codigo

			update #_tmp_detalle_mov set
				ccus_numero = cc.ccus_numero
			from
					#_tmp_detalle_mov	t	,
					cuentas_custodia	cc
			where
					t.ccus_id = cc.ccus_id
					
			update #_tmp_detalle_mov set titular = rtrim(ltrim(ISNULL(clie_apellido,''))) + ' ' + rtrim(ltrim(ISNULL(clie_nombre,'')))
			from	
					#_tmp_detalle_mov t			,
					cuentas_custodia_vinculadas cv	,
					clientes c
			where
					t.ccus_id = cv.ccus_id	
			  and	cv.tvcc_id = 1				
			  and	c.clie_alias = cv.clie_alias
			  
			
			update #_tmp_detalle_mov set ccus_numero_tit = ltrim(rtrim(str(ccus_numero))) + ' - ' + isnull(RTRIM(ltrim(titular)),'') 
			
	
			 
			 select
					espe_codigo							,
					ccm_monto	= isnull(
										sum( charindex( 'C', ccm_tipomov) * ccm_monto )
										- sum( charindex( 'D', ccm_tipomov) * ccm_monto ) 
										,0),
					precio_val = isnull(precio_val,0) 			,
					monto_val	= isnull(
										sum( charindex( 'C', ccm_tipomov) * ccm_monto * ISNULL(precio_val,0) )
										- sum( charindex( 'D', ccm_tipomov) * ccm_monto * ISNULL(precio_val,0) ) 
										,0),
					ccus_numero	= ccus_numero_tit	,						
					fecha_precios, 
					PPCpa,
					PPVta,
					Rendimiento,
					0 saldo_disponible ,
					0 saldo_bloqueado ,
					0 Saldo_total		,
					'' descripcion_bloqueos ,
					0 saldo_inmovilizado ,
					0 saldo_bloqueado_interno,
					0 saldo_bloqueado_externo
			from
					#_tmp_detalle_mov
			 
			group by
					ccus_numero_tit	,
					espe_codigo	,
					fecha_precios,
					precio_val,
					PPCpa,
					PPVta,
					Rendimiento
			order by 
					ccus_numero	,
					espe_codigo	
	end
	
	if @_caso = 3
	begin
			 delete from tmp_posicion_cuentas_custodia
			 
			 insert tmp_posicion_cuentas_custodia (
					ccus_id				,
					espe_codigo			,
					ccm_monto
			)			 
			select
					ccus_id								,
					espe_codigo							,
					ccm_monto	= isnull(
										sum( charindex( 'C', ccm_tipomov) * ccm_monto )
										- sum( charindex( 'D', ccm_tipomov) * ccm_monto ) 
										,0)	
			from
					#_tmp_detalle_mov
			 
			group by
					ccus_id	,
					espe_codigo	
			order by 
					ccus_id	,
					espe_codigo
	end
	
	
	if @_caso = 2
	begin
			select
					@_saldo_disponible = isnull(ccm_monto,0)
			from
					#_tmp_detalle_mov
			where
					concc_id = 99		
			and		espe_codigo = @_espe_tenencia
			

	end
	
TENENCIA_TIT:
	if @_caso = 5 or @_caso = 6 or @_caso = 7 or @_caso = 8 or @_caso = 9 or @_caso = 10 or @_caso = 11 or @_caso = 12
	begin
			
			declare @_saldo_dis money,
					@_saldo_bloq money,
					@_descrip_bloqueos varchar(400)
				

			create table #_descrip_bloqueos
			(espe_codigo varchar(6) collate database_default, 
			concc_descrip varchar(400) collate database_default,
			ccm_monto money)
			
			create table #_descrip_bloqueos_agr
			(espe_codigo varchar(6) collate database_default, 
			concc_descrip varchar(400) collate database_default)
			
			insert into #_descrip_bloqueos
			select t.espe_codigo, ltrim(rtrim(c.concc_descrip)), t.ccm_monto
			from #_tmp_detalle_mov t, conceptos_cuentas_custodia c
			where c.concc_esbloqueo = 1
			and c.concc_id = t.concc_id
			and t.ccus_id = @_ccus_id
			
			declare descrip_bloqueos cursor for
			select * from #_descrip_bloqueos
			
			declare 
				@_espe_blq varchar(6),
				@_monto_blq money,
				@_descrip_blq varchar(400)
			
			open descrip_bloqueos
			fetch next from descrip_bloqueos into @_espe_blq, @_descrip_blq,@_monto_blq
			
			while @@FETCH_STATUS = 0
			begin
				if not exists (select * from #_descrip_bloqueos_agr where espe_codigo = @_espe_blq)
					insert into #_descrip_bloqueos_agr select @_espe_blq,CONVERT(varchar(50),@_monto_blq,1) + ' ' + @_descrip_blq
				else
					update #_descrip_bloqueos_agr
					set 
						concc_descrip = LEFT(ISNULL(concc_descrip,'') + ' ' + CONVERT(varchar(50),@_monto_blq,1) + ' ' + @_descrip_blq,400)
					where
						espe_codigo = @_espe_blq
				
				fetch next from descrip_bloqueos into @_espe_blq, @_descrip_blq, @_monto_blq
			end
			
			close descrip_bloqueos
			deallocate descrip_bloqueos
			
			declare @_espe_codigo_cotiz varchar(6),
					@_cupo_numero_cotiz int,
					@_caso_cotiz int
			
			if @_caso in (8,11) 
				select @_caso_cotiz = 2 
			else
				select @_caso_cotiz = 1 
				
		
			
			update #_tmp_detalle_mov set
				precio_val =  p.pval_precio 
			from
					#_tmp_detalle_mov t ,
					preciovaluacion p
			where
					p.espe_codigo = t.espe_codigo
			  and	p.pval_plazo = 3
			  and	p.pval_origen = 'NOSIS'
			  and	p.espe_cotiza = dbo.MonedaLocal()
			  and	p.merc_codigo = 'BOL'
			  and	p.pval_fecha in 
					  (select max(pval_fecha) from preciovaluacion
								where espe_codigo = t.espe_codigo
								and merc_codigo = 'BOL'
								and pval_fecha <= @_fdesde
								and pval_plazo = 3
								and pval_origen = 'NOSIS'
								and espe_cotiza = dbo.MonedaLocal())
												
			update #_tmp_detalle_mov set
				precio_val = 1
			where
				precio_val is null
				
			
			update #_tmp_detalle_mov set
				fecha_precios = '20010101'
			where
				fecha_precios is null
				
			
			update #_tmp_detalle_mov set
				oper_monto = o.oper_monto
			from
				operaciones o , #_tmp_detalle_mov t
			where
				o.oper_numero = t.oper_numero
				
			update #_tmp_detalle_mov set PPCpa = 0, PPVta = 0, Rendimiento = 0
			
			update #_tmp_detalle_mov set
			PPCpa = r.PP 
			from #_tmp_detalle_mov t,	
				(select
					PP = SUM(ccm_monto) / SUM(oper_monto),
					t.espe_codigo
				from
					#_tmp_detalle_mov t
				where
					oper_numero > 0
				and t.ccm_tipomov = 'C'	
				group by t.espe_codigo) r
			where
				t.espe_codigo = r.espe_codigo

			
			update #_tmp_detalle_mov set
			PPVta = r.PP 
			from #_tmp_detalle_mov t,	
				(select
					PP = SUM(ccm_monto) / SUM(oper_monto),
					t.espe_codigo
				from
					#_tmp_detalle_mov t
				where
					oper_numero > 0
				and t.ccm_tipomov = 'D'	
				group by t.espe_codigo) r
			where
				t.espe_codigo = r.espe_codigo

			update #_tmp_detalle_mov set
				ccus_numero = cc.ccus_numero
			from
					#_tmp_detalle_mov	t	,
					cuentas_custodia	cc
			where
					t.ccus_id = cc.ccus_id
					
			update #_tmp_detalle_mov set titular = rtrim(ltrim(ISNULL(clie_apellido,''))) + ' ' + rtrim(ltrim(ISNULL(clie_nombre,'')))
			from	
					#_tmp_detalle_mov t			,
					cuentas_custodia_vinculadas cv	,
					clientes c
			where
					t.ccus_id = cv.ccus_id	
			  and	cv.tvcc_id = 1			
			  and	c.clie_alias = cv.clie_alias
			  
			
			update #_tmp_detalle_mov set ccus_numero_tit = ltrim(rtrim(str(ccus_numero))) + ' - ' + isnull(RTRIM(ltrim(titular)),'') 
			
			insert into #_tmp_saldos_especie
			(espe_codigo,ccus_numero)
			select distinct espe_codigo, ccus_numero_tit from #_tmp_detalle_mov
			
	

			 update #_tmp_saldos_especie			 
			 set
					ccm_monto	= ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * ccm_monto )
										- sum( charindex( 'D', ccm_tipomov) * ccm_monto ) 
										,0) from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										),
					precio_val = isnull(t.precio_val,0) 			,
					monto_val	= (select isnull(
										sum( charindex( 'C', ccm_tipomov) * ccm_monto * ISNULL(precio_val,0) )
										- sum( charindex( 'D', ccm_tipomov) * ccm_monto * ISNULL(precio_val,0) ) 
										,0)  from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										)	,
					ccus_numero	= ccus_numero_tit	,						
					fecha_precios = t.fecha_precios, 
					PPCpa = t.PPCpa,
					PPVta = t.PPVta,
					Rendimiento = t.Rendimiento,
					saldo_bloqueado = ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * saldo_bloqueado )
										- sum( charindex( 'D', ccm_tipomov) * saldo_bloqueado ) 
										,0)	from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										),
					saldo_disponible = ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * saldo_disponible )
										- sum( charindex( 'D', ccm_tipomov) * saldo_disponible ) 
										,0) from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										),
					saldo_inmovilizado = ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * saldo_inmovilizado )
										- sum( charindex( 'D', ccm_tipomov) * saldo_inmovilizado ) 
										,0)	from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										),
					Saldo_total		= ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * Saldo_total )
										- sum( charindex( 'D', ccm_tipomov) * Saldo_total ) 
										,0) from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero										
										),
					descripcion_bloqueos = '',
					saldo_bloqueado_interno = ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * saldo_bloqueado_interno )
										- sum( charindex( 'D', ccm_tipomov) * saldo_bloqueado_interno ) 
										,0)	from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										),
					saldo_bloqueado_externo = ( select isnull(
										sum( charindex( 'C', ccm_tipomov) * saldo_bloqueado_externo )
										- sum( charindex( 'D', ccm_tipomov) * saldo_bloqueado_externo ) 
										,0)	from #_tmp_detalle_mov t1 
										where t.espe_codigo = t1.espe_codigo
										and t.ccus_numero = t1.ccus_numero
										)										
			from
					#_tmp_detalle_mov t, #_tmp_saldos_especie s
			 where
				s.espe_codigo = t.espe_codigo
			and s.ccus_numero = t.ccus_numero_tit

					
	
			update #_tmp_detalle_mov
			set descripcion_bloqueos = isnull(b.concc_descrip,'')
			from #_descrip_bloqueos b, #_tmp_detalle_mov t
			where
				t.espe_codigo = b.espe_codigo
			
			update #_tmp_detalle_mov set PPCpa = 0 where PPCpa is null							
			update #_tmp_detalle_mov set PPVta = 0 where PPVta is null
			update #_tmp_saldos_especie set PPCpa = 0 where PPCpa is null							
			update #_tmp_saldos_especie set PPVta = 0 where PPVta is null
			

			if @_caso = 6
			begin
				select 		
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					isnull(PPCpa,0) PPCpa ,
					isnull(PPVta,0) PPVta,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
				order by 
						ccus_numero	,
						espe_codigo
			end
			
			if @_caso = 5
			begin
				delete from tmp_saldos_tenencias
				
				insert into tmp_saldos_tenencias
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end
			
			if @_caso = 7
			begin
				delete from tmp_saldos_copiador_mae
				
				insert into tmp_saldos_copiador_mae
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end

			
			if @_caso = 8
			begin
				delete from tmp_saldos_pic
				where ccus_id = @_ccus_id
				
				insert into tmp_saldos_pic
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end
						
			
			if @_caso = 9
			begin
				delete from tmp_saldos_int_cross_selling
				
				insert into tmp_saldos_int_cross_selling
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end
						
			
			if @_caso = 10
			begin
				delete from tmp_saldos_int_dw_vc
				
				insert into tmp_saldos_int_dw_vc
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end
			
			
			if @_caso = 11
			begin
				delete from tmp_saldos_int_sobre_unico
				
				insert into tmp_saldos_int_sobre_unico
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo
				from
					#_tmp_saldos_especie
			end
			
			if @_caso = 12
			begin
				delete from tmp_saldos_conciliacion_saldos
				
				insert into tmp_saldos_conciliacion_saldos
				select 		
					@_ccus_id,
					espe_codigo,
					ccm_monto	,
					precio_val ,
					monto_val,
					ccus_numero,
					fecha_precios ,
					PPCpa ,
					PPVta ,
					Rendimiento ,
					saldo_disponible ,
					saldo_bloqueado ,
					Saldo_total		,
					descripcion_bloqueos ,
					saldo_inmovilizado ,
					saldo_bloqueado_interno,
					saldo_bloqueado_externo,
					0,0,0,0,0,0,0
				from
					#_tmp_saldos_especie
			
				declare @_vr decimal(38,25),
						@_espe_codigo_saldos varchar(6),
						@_cupo_numero_saldos int
				
				declare cur_saldos_cv cursor for
				select espe_codigo from tmp_saldos_conciliacion_saldos
				
				open cur_saldos_cv
				fetch next from cur_saldos_cv into @_espe_codigo_saldos
				
				while @@FETCH_STATUS = 0
				begin
					exec calc_especie_cupon_vigente @_espe_codigo_saldos,@_fdesde,0,@_cupo_numero_saldos output					
					exec calc_especie_vresidual @_espe_codigo_saldos, @_cupo_numero_saldos,0,@_vr output
					
					update tmp_saldos_conciliacion_saldos set 					
						cupo_numero = @_cupo_numero_saldos,
						saldo_disponible_vr = saldo_disponible * @_vr,
						saldo_bloqueado_vr = saldo_bloqueado * @_vr,
						Saldo_total_vr	= saldo_total* @_vr	,
						saldo_inmovilizado_vr = saldo_inmovilizado * @_vr,
						saldo_bloqueado_interno_vr = saldo_bloqueado_interno * @_vr,
						saldo_bloqueado_externo_vr = saldo_bloqueado_externo * @_vr
					where
						espe_codigo = @_espe_codigo_saldos
							
					fetch next from cur_saldos_cv into @_espe_codigo_saldos
				end
				close cur_saldos_cv
				deallocate cur_saldos_cv
			end
						
			drop table #_descrip_bloqueos
			drop table #_descrip_bloqueos_agr
	end
	drop table #_tmp_detalle_mov
	drop table #_tmp_especies_sin_saldoini
	drop table #_tmp_saldos_especie
SALIR:	
end 
go 