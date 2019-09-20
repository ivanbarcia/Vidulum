if OBJECT_ID('dbo.GCInstruccionesConsulta_Portal') is not null
begin
	drop procedure dbo.GCInstruccionesConsulta_Portal
end
go

create procedure dbo.GCInstruccionesConsulta_Portal (  
	@FechaDesde datetime,
	@FechaHasta datetime,
	@TipoConsulta int,
	@NumeroInstruccion int,
	@TipoInstruccion int,
	@EstadoInstruccion int,
	@Cliente varchar(100),
	@TipoMonto varchar(100),
	@Monto money,
	@Especie varchar(500),
	@CodMatching int,
	@PageSize int,
	@PageNumber int,
	@TotalRegistros int OUTPUT)  
as  
begin
	DECLARE @contar nvarchar(max)
	DECLARE @sqlCommand varchar(max)
	
	SET @sqlCommand =
	'select distinct
		I.ID,
		I.Numero,
		E.Alias + '' - '' + E.Descripcion as Estado,
		c.clie_cuenta as ClienteBantotal,
		C.clie_nombreafip,
		TI.Alias as TipoInstruccion,
		Convert(varchar(10),I.FechaConcertacion,103) as FechaConcertacion,
		Convert(varchar(10),I.FechaLiquidacion,103) as FechaLiquidacion,
		I.Referencia,
		dbo.traduccionEspecie(I.espe_codigo) as espe_codigo,
		ltrim(rtrim(esp.espe_descrip)) as DescripcionEspecie,
		I.Cantidad,
		LTRIM(RTRIM(STR(CC.ccus_numero))) as CuentaCustodia,
		(select top 1 isnull(Alias,'''') from GCCasasCustodia where ID = I.CasaCustodia) as CasaCustodia,
		I.MontoLiquidacion,
		i.ContraparteComitente as ContraparteComitente,
		i.ContraparteDepositante as ContraparteDepositante,
		dbo.traduccionEspecie(i.espe_codcot) as espe_codcot,
		i.Observaciones,
		isnull(i.CodigoMatching,0) as CodigoMatching
	from
		GCInstrucciones I
		inner join GCEstadosInstrucciones E ON I.Estado = E.ID  
		inner join clientes C ON I.clie_alias = C.clie_alias  
		inner join GCTiposInstrucciones TI ON I.TipoInstruccion = TI.ID  
		inner join cuentas_custodia CC ON I.ccus_id = CC.ccus_id  
		left join movim_liquid ML ON I.Numero = ML.oper_numero  
		left join Especies ESP ON I.espe_codigo = ESP.espe_codigo  
		left join (select * from dts_espe_convert where espe_canal = ''SDB'') DTS ON I.espe_codigo = DTS.espe_codsgm  
		left join (select * from dts_espe_convert where espe_canal = ''ISIN'') ISIN ON I.espe_codigo = ISIN.espe_codsgm  
		left join (select * from dts_espe_convert where espe_canal = ''CAJVAL'') CV  ON I.espe_codigo = CV.espe_codsgm  
	where
		TI.Alias not in (''PFJ'')
		and (CASE '+ convert(varchar(max),@TipoConsulta) +' 
		when 0 then convert(varchar(8),I.FechaConcertacion,112) 
		when 1 then CASE when e.alias = ''F'' and TI.Alias not in (''RM'', ''DM'', ''PFJ'', ''OTR'', ''PGR'', ''CPDI'', ''CPDF'') and ml.mliq_estado = ''A''  
			then convert(varchar(8),ml.mliq_fvalor,112)
			else convert(varchar(8),I.FechaLiquidacion,112)
			END   
		END) >= ''' + convert(varchar(8),@FechaDesde,112) + '''
		and (CASE '+ convert(varchar(max),@TipoConsulta) +' 
		when 0 then convert(varchar(8),I.FechaConcertacion,112) 
		when 1 then CASE when e.alias = ''F'' and TI.Alias not in (''RM'', ''DM'', ''PFJ'', ''OTR'', ''PGR'', ''CPDI'', ''CPDF'') and ml.mliq_estado = ''A''  
			then convert(varchar(8),ml.mliq_fvalor,112)
			else convert(varchar(8),I.FechaLiquidacion,112)
			END   
		END) <= ''' + convert(varchar(8),@FechaHasta,112) + '''
	'

	SET @contar =
	N'select @cantidad = count(distinct i.id)
	from
		GCInstrucciones I
		inner join GCEstadosInstrucciones E ON I.Estado = E.ID  
		inner join clientes C ON I.clie_alias = C.clie_alias  
		inner join GCTiposInstrucciones TI ON I.TipoInstruccion = TI.ID  
		inner join cuentas_custodia CC ON I.ccus_id = CC.ccus_id  
		left join movim_liquid ML ON I.Numero = ML.oper_numero  
		left join Especies ESP ON I.espe_codigo = ESP.espe_codigo  
		left join (select * from dts_espe_convert where espe_canal = ''SDB'') DTS ON I.espe_codigo = DTS.espe_codsgm  
		left join (select * from dts_espe_convert where espe_canal = ''ISIN'') ISIN ON I.espe_codigo = ISIN.espe_codsgm  
		left join (select * from dts_espe_convert where espe_canal = ''CAJVAL'') CV  ON I.espe_codigo = CV.espe_codsgm  
	where
		TI.Alias not in (''PFJ'')
		and (CASE '+ convert(varchar(max),@TipoConsulta) +' 
		when 0 then convert(varchar(8),I.FechaConcertacion,112) 
		when 1 then CASE when e.alias = ''F'' and TI.Alias not in (''RM'', ''DM'', ''PFJ'', ''OTR'', ''PGR'', ''CPDI'', ''CPDF'') and ml.mliq_estado = ''A''  
			then convert(varchar(8),ml.mliq_fvalor,112)
			else convert(varchar(8),I.FechaLiquidacion,112)
			END   
		END) >= ''' + convert(varchar(8),@FechaDesde,112) + '''
		and (CASE '+ convert(varchar(max),@TipoConsulta) +' 
		when 0 then convert(varchar(8),I.FechaConcertacion,112) 
		when 1 then CASE when e.alias = ''F'' and TI.Alias not in (''RM'', ''DM'', ''PFJ'', ''OTR'', ''PGR'', ''CPDI'', ''CPDF'') and ml.mliq_estado = ''A''  
			then convert(varchar(8),ml.mliq_fvalor,112)
			else convert(varchar(8),I.FechaLiquidacion,112)
			END   
		END) <= ''' + convert(varchar(8),@FechaHasta,112) + '''
	'

	if (@TipoInstruccion != 0 or @TipoInstruccion != null)
	begin
		select @sqlCommand = @sqlCommand +	'and TipoInstruccion =' + convert(varchar(max),@TipoInstruccion)
		select @contar = @contar +	'and TipoInstruccion =' + convert(varchar(max),@TipoInstruccion)
	end

	if (@NumeroInstruccion != 0 or @NumeroInstruccion != null)
	begin
		select @sqlCommand = @sqlCommand +	'and convert(varchar(max),I.NumeroInstruccion) like ''%' + @NumeroInstruccion + '%'''
		select @contar = @contar +	'and convert(varchar(max),I.NumeroInstruccion) like ''%' + @NumeroInstruccion + '%'''
	end

	if (@EstadoInstruccion != 0 or @EstadoInstruccion != null)
	begin
		select @sqlCommand = @sqlCommand +	'and I.Estado =' + convert(varchar(max),@EstadoInstruccion)
		select @contar = @contar +	'and I.Estado =' + convert(varchar(max),@EstadoInstruccion)
	end

	if (@CodMatching != 0 or @CodMatching != null)
	begin
		select @sqlCommand = @sqlCommand + 'AND isnull(I.CodigoMatching, '''') = ' + convert(varchar(max),@CodMatching)
		select @contar = @contar + 'AND isnull(I.CodigoMatching, '''') = ' + convert(varchar(max),@CodMatching)
	end

	if (@Cliente != '' or @Cliente != null)
	begin
		select @sqlCommand = @sqlCommand + 'and c.clie_cuenta in (' + @Cliente + ')'
		select @contar = @contar + 'and c.clie_cuenta in (' + @Cliente + ')'
	end

	if (@Especie != '' or @Especie != null)
	begin
		select @sqlCommand = @sqlCommand +	
			'and (  
			ESP.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR  
			ESP.espe_descrip like ''%'' + ''' + @Especie + ''' + ''%'' OR  
			DTS.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR    
			ISIN.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR    
			CV.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' 
			)'
		select @contar = @contar +	
			'and (  
			ESP.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR  
			ESP.espe_descrip like ''%'' + ''' + @Especie + ''' + ''%'' OR  
			DTS.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR    
			ISIN.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' OR    
			CV.espe_codigo like ''%'' + ''' + @Especie + ''' + ''%'' 
			)'
	end

	if (@TipoMonto != '' or @TipoMonto != null and @TipoMonto in ('=', '<', '>', '>=', '<='))
	begin
		select @sqlCommand = @sqlCommand + 'and I.Cantidad ' + @TipoMonto + convert(varchar(max),isnull(@Monto,0))
		select @contar = @contar + 'and I.Cantidad ' + @TipoMonto + convert(varchar(max),isnull(@Monto,0))
	end
	
	--PAGINADO
	select @sqlCommand = @sqlCommand + 
		'ORDER BY i.id
		OFFSET ' + convert(varchar(max),@PageSize) + ' * (' + convert(varchar(max),@PageNumber) + ' - 1) ROWS
		FETCH NEXT ' + convert(varchar(max),@PageSize) + ' ROWS ONLY'

	EXEC (@sqlCommand)
	
	execute sp_executesql @contar, N'@cantidad int OUTPUT', @cantidad = @TotalRegistros OUTPUT
	select @TotalRegistros

end
