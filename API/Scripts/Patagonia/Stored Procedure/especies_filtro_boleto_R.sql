ALTER procedure dbo.especies_filtro_boleto_R (
		@_filtro 	varchar(255)	,
		@_clas_codigo	char(3)		,
		@_merc_codigo	char(3)	= 'LIB'	,
		@_tope_codigo	int = null	
) as begin
	
	declare 
		@_filtro_sql varchar(255)
	/* -- Creo la tabla temporal 
	*/
	create table #_tmp_especies (
		Codigo	char(6) collate Modern_Spanish_CI_AS 
	)
 
	set @_filtro =  ISNULL(@_filtro,' ')
	
	/* -- Para el mercado 'DIN', busco directamente en las especies habilitadas
	   -- para la clase de operacion. Si vino por parametro, filtro tambien por tipo 
	   -- de operacion.
	*/
	if @_merc_codigo = 'DIN'
	begin
		/* -- Busco por espe_codigo, si encuentro finaliza la busqueda
		*/
		
		insert #_tmp_especies
		select
			espe_codigo
		from
			tipoclaseespeoper
		where
			clas_codigo = @_clas_codigo
		   and	tope_codigo = isnull(@_tope_codigo, tope_codigo)	
		   and	upper(ltrim(rtrim(espe_codigo))) = upper (ltrim(rtrim(@_filtro)))		
		
		if (@_filtro = '02b' or @_filtro = '02B') and @_clas_codigo = 'PAS' 
				insert #_tmp_especies
				select '02B'
		
		if (@_clas_codigo = 'PFL')
		begin
			select @_filtro_sql = '%' + rtrim(ltrim(upper(@_filtro))) + '%'

			insert #_tmp_especies		
			select	espe_codigo
			from 	especies
			where 	tesp_codigo = 'E'	
			and  upper(espe_codigo) like @_filtro_sql
		end

	
		if @@rowcount > 0 goto SALIDA
			
		/* -- Busco donde coincida Codigo y Descripcion
		*/
		select @_filtro_sql = '%' + rtrim(ltrim(upper(@_filtro))) + '%'
		
		/* -- Codigo */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e, 
			tipoclaseespeoper t
		where
			t.clas_codigo = @_clas_codigo
		   and	t.tope_codigo = isnull(@_tope_codigo, t.tope_codigo)	
		   and	t.espe_codigo = e.espe_codigo	
		   and  upper(e.espe_codigo) like @_filtro_sql
		   
		/* -- Descripcion */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e, 
			tipoclaseespeoper t
		where
			t.clas_codigo = @_clas_codigo
		   and	t.tope_codigo = isnull(@_tope_codigo, t.tope_codigo)
		   and	t.espe_codigo = e.espe_codigo	
		   and  upper(e.espe_descrip) like @_filtro_sql   
	end
	/* -- Para el mercado 'MAE' */
	if @_merc_codigo = 'MAE'
	begin
		/* -- Busco donde coincida Codigo y Descripcion
		*/
		select @_filtro_sql = '%' + rtrim(ltrim(upper(@_filtro))) + '%'
		/* -- Especies LEBAC y NOBAC - Codigo */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e,
			tiposespecies te
		where
			e.tesp_codigo = te.tesp_codigo
		and	te.merc_codigo = @_merc_codigo
		and	upper(e.espe_codigo) like @_filtro_sql	
		
		/* -- Especies LEBAC y NOBAC - Descripcion */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e,
			tiposespecies te
		where
			e.tesp_codigo = te.tesp_codigo
		and	te.merc_codigo = @_merc_codigo
		and	upper(e.espe_descrip) like @_filtro_sql	
	end
	/* -- Para el mercado 'LIB' 'L08' 'L09' 'CON' */
	if @_merc_codigo in ('LIB', 'L08', 'L09', 'CON')
	begin
		/* -- Para LIB, busco como primra medida que coincida el alias */
		
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e
		where
			e.tesp_codigo in ('D', 'B', 'M', 'C')
		and	upper(e.espe_codigo) = upper(@_filtro)

		if @@rowcount > 0 goto SALIDA

		/* -- Busco donde coincida Codigo y Descripcion
		*/
		select @_filtro_sql = '%' + rtrim(ltrim(upper(@_filtro))) + '%'
		/* -- Especies - Codigo */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e
		where
			e.tesp_codigo in ('D', 'B', 'M', 'C')
		and	upper(e.espe_codigo) like @_filtro_sql
		/* -- Especies - Descripcion */
		insert #_tmp_especies
		select
			e.espe_codigo
		from	
			especies e
		where
			e.tesp_codigo in ('D', 'B', 'M', 'C')
		and	upper(e.espe_descrip) like @_filtro_sql
	end
	
SALIDA:	

	/* Agregado por Hernan para PASES - DOLAR BILLETES */ 
		if @_filtro = ' ' and @_clas_codigo = 'PAS'
		begin
				insert #_tmp_especies
				select '02B'
		end
		--FIN /* Agregado por Hernan para PASES - DOLAR BILLETES */ 

	
	/* 
		SELECT DE LOS DATOS PARA QUE LEVANTE EL COMBO
	*/
	select 
		RTRIM(LTRIM(espe_codigo)) as 'Valor', 
		RTRIM(LTRIM(espe_codigo)) + ' - ' + RTRIM(LTRIM(espe_descrip)) as 'Descripcion'
	from 
		especies e, 
		#_tmp_especies t
	where	e.espe_codigo = t.Codigo
	group by
		e.espe_codigo, e.espe_descrip
end