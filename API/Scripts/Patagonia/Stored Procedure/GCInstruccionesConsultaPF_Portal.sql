if OBJECT_ID('dbo.GCInstruccionesConsultaPF_Portal') is not null
begin
	drop procedure dbo.GCInstruccionesConsultaPF_Portal
end
go

create procedure dbo.GCInstruccionesConsultaPF_Portal (  
	@FechaDesde datetime,
	@FechaHasta datetime,
	@TipoConsulta int,
	@NumeroInstruccion int,
	@TipoInstruccion int,
	@EstadoInstruccion int,
	@Cliente varchar(100),
	@TipoMonto varchar(100),
	@Monto money,
	@EstadoPlazoFijo int,
	@Moneda varchar(100),
	@NumeroCertificado varchar(100),
	@PageSize int,
	@PageNumber int,
	@TotalRegistros int OUTPUT)   
as  
begin
	DECLARE @contar nvarchar(max)
	DECLARE @sqlCommand varchar(max)
	
	SET @sqlCommand =
	'select
		I.ID,
		I.Numero,
		TPF.Alias + '' - '' + TPF.Descripcion as TipoPlazoFijo,
		E.Alias + '' - '' + e.Descripcion as Estado,
		c.clie_cuenta as ClienteBantotal,
		C.clie_nombreafip,
		LTRIM(RTRIM(STR(CC.ccus_numero))) as CuentaCustodia,
		CONVERT(char(10), I.FechaConcertacion, 103) as FechaConcertacion,
		CONVERT(char(10), I.FechaLiquidacion, 103) as FechaVencimiento,
		I.Referencia as NumeroCertificado,
		dbo.traduccionEspecie(I.espe_codigo) as espe_codigo,
		ltrim(rtrim(esp.espe_descrip)) as DescripcionEspecie,
		I.Cantidad as MontoInicial,
		Convert(Decimal(15,8),I.TNA, 8) as TNA,
		i.Intereses,
		I.MontoLiquidacion as MontoReembolso,
		B.Descripcion as BancoEmisor,
		I.Observaciones,
		i.ContraparteComitente as ContraparteComitente,
		i.ContraparteDepositante as ContraparteDepositante,
		i.Motivo as MotivoRechazo,
		i.CodigoMatching
	from  
		GCInstrucciones I
		inner join especies esp on esp.espe_codigo = i.espe_codigo
		INNER JOIN GCEstadosInstrucciones E ON I.Estado = E.ID
		INNER JOIN clientes C ON I.clie_alias = C.clie_alias
		INNER JOIN GCTiposInstrucciones TI ON I.TipoInstruccion = TI.ID
		INNER JOIN cuentas_custodia CC ON I.ccus_id = CC.ccus_id
		INNER JOIN GCTiposPlazoFijo TPF ON I.TipoPlazoFijo = TPF.ID
		INNER JOIN GCBancos B ON I.BancoEmisor = B.ID
		LEFT JOIN GCCasasCustodia EC ON EC.ID = I.CasaCustodia
	where
		TI.Alias = ''PFJ''
		and CASE ' + convert(varchar(max),@TipoConsulta) + '
				when 0 then convert(varchar(8),I.FechaRecepcion,112)
				when 1 then convert(varchar(8),I.FechaLiquidacion,112)
			END BETWEEN ''' + convert(varchar(8),@FechaDesde,112) + ''' AND ''' + convert(varchar(8),@FechaHasta,112) + '''
	'

	SET @contar =
	N'select @cantidad = count(distinct i.id)
	from  
		GCInstrucciones I
		inner join especies esp on esp.espe_codigo = i.espe_codigo
		INNER JOIN GCEstadosInstrucciones E ON I.Estado = E.ID
		INNER JOIN clientes C ON I.clie_alias = C.clie_alias
		INNER JOIN GCTiposInstrucciones TI ON I.TipoInstruccion = TI.ID
		INNER JOIN cuentas_custodia CC ON I.ccus_id = CC.ccus_id
		INNER JOIN GCTiposPlazoFijo TPF ON I.TipoPlazoFijo = TPF.ID
		INNER JOIN GCBancos B ON I.BancoEmisor = B.ID
		LEFT JOIN GCCasasCustodia EC ON EC.ID = I.CasaCustodia
	where
		TI.Alias = ''PFJ''
		and CASE ' + convert(varchar(max),@TipoConsulta) + '
				when 0 then convert(varchar(8),I.FechaRecepcion,112)
				when 1 then convert(varchar(8),I.FechaLiquidacion,112)
			END BETWEEN ''' + convert(varchar(8),@FechaDesde,112) + ''' AND ''' + convert(varchar(8),@FechaHasta,112) + '''
	'

	if (@TipoInstruccion != 0 or @TipoInstruccion != null)
	begin
		select @sqlCommand = @sqlCommand +	'and TipoPlazoFijo =' + convert(varchar(max),@TipoInstruccion)
		select @contar = @contar +	'and TipoPlazoFijo =' + convert(varchar(max),@TipoInstruccion)
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
	
	if (@Cliente != '' or @Cliente != null)
	begin
		select @sqlCommand = @sqlCommand + 'and c.clie_cuenta in (' + @Cliente + ')'
		select @contar = @contar + 'and c.clie_cuenta in (' + @Cliente + ')'
	end

	if (@Moneda != 0 or @Moneda != null)
	begin
		select @sqlCommand = @sqlCommand +	'and I.espe_codigo =' + @Moneda
		select @contar = @contar +	'and I.espe_codigo =' + @Moneda
	end

	if (@TipoMonto != '' or @TipoMonto != null and @TipoMonto in ('=', '<', '>', '>=', '<='))
	begin
		select @sqlCommand = @sqlCommand + 'and I.Cantidad ' + @TipoMonto + convert(varchar(max),isnull(@Monto,0))
		select @contar = @contar + 'and I.Cantidad ' + @TipoMonto + convert(varchar(max),isnull(@Monto,0))
	end
		
	if (@EstadoPlazoFijo = 0)
	begin
		select @sqlCommand = @sqlCommand +	'and convert(varchar(8),I.FechaLiquidacion,112) >= convert(varchar(8),getdate(),112)'
		select @contar = @contar +	'and convert(varchar(8),I.FechaLiquidacion,112) >= convert(varchar(8),getdate(),112)'
	end

	if (@EstadoPlazoFijo = 1)
	begin
		select @sqlCommand = @sqlCommand +	'and convert(varchar(8),I.FechaLiquidacion,112) < convert(varchar(8),getdate(),112)'
		select @contar = @contar +	'and convert(varchar(8),I.FechaLiquidacion,112) < convert(varchar(8),getdate(),112)'
	end

	if (@NumeroCertificado != '' or @NumeroCertificado != null)
	begin
		select @sqlCommand = @sqlCommand +	+ 'and I.Referencia like ''%' + @NumeroCertificado + '%'''
		select @contar = @contar +	+ 'and I.Referencia like ''%' + @NumeroCertificado + '%'''
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
