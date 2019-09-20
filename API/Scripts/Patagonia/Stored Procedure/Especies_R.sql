ALTER procedure dbo.Especies_R (@_filtro varchar(255), @_OperacionTipo varchar(20) = null) 
as begin 
	 
	declare @clas_codigo char(3) 
	declare @sect_codigo char(3) 
	declare @merc_codigo char(3) 
	declare @_filtro_sql varchar(255) 
	declare @OperacionTipo int 
	Print 'Comienzo' 
 
	if @_OperacionTipo = 'PPCCO' 
		select @_OperacionTipo = null

	--select 'LLEGOOO 222', @OperacionTipo
 
	/* Creo la tabla con las especies validas */ 
	create table #_tmp_ev ( 
		espe_codigo char(6) collate Modern_Spanish_CI_AS
	) 

	
	if @_OperacionTipo is null or @_OperacionTipo='##GRID_OPTION##'
		insert #_tmp_ev  
		select espe_codigo 
		from especies 
	else 
			begin 
			Print 'Entro por varias operaciones' 
			--obtengo todos los tipos de operacion 
			declare @_oper int, 
					@_pos int 
			 
			create table #_tmp_opers ( 
				tope_codigo smallint, 
				clas_codigo char(3) collate Modern_Spanish_CI_AS null , 
				sect_codigo char(3) collate Modern_Spanish_CI_AS null , 
				merc_codigo char(3) collate Modern_Spanish_CI_AS null  
			) 
			 
			select @_OperacionTipo = @_OperacionTipo + ',' 
			
			
			--while len(@_OperacionTipo) > 1 
			--	begin 
			--	select @_pos = patindex('%,%', @_OperacionTipo) 
			--	select @_oper = convert(smallint, substring(@_OperacionTipo, 1, @_pos - 1)) 
			--	insert into #_tmp_opers (tope_codigo) values (@_oper) 
			--	select @_OperacionTipo = substring(@_OperacionTipo, @_pos+1, len(@_OperacionTipo)-@_pos) 
			--	end 
			 
			--update #_tmp_opers  
			--set 
			--	clas_codigo = op.clas_codigo, 
			--	sect_codigo = op.sect_codigo, 
			--	merc_codigo = op.merc_codigo 
			--from 
			--	#_tmp_opers t, 
			--	tipoclaseespeoper op 
			--where t.tope_codigo = op.tope_codigo 
 
			----obtengo las especies permitidas para el conjunto de operaciones 
			--if (select count(distinct clas_codigo) from #_tmp_opers) = 1 and  
			--		(select max(merc_codigo) from #_tmp_opers) = 'DIN' 
			--	begin 
			--	insert #_tmp_ev  
			--	select distinct t.espe_codigo 
			--	from tipoclaseespeoper t, #_tmp_opers o 
			--	where t.tope_codigo = o.tope_codigo and t.clas_codigo = o.clas_codigo  
			--		and t.sect_codigo = o.sect_codigo 
			--	end 
			--else if (select count(distinct clas_codigo) from #_tmp_opers) = 1 and  
			--		(select max(merc_codigo) from #_tmp_opers) = 'MAE' 
			--	begin 
			--	insert #_tmp_ev  
			--	select e.espe_codigo 
			--	from especies e, tiposespecies t 
			--	where e.tesp_codigo = t.tesp_codigo and t.merc_codigo = @merc_codigo 
			--	end 
			--else if (select count(*) from #_tmp_opers where not merc_codigo in ('LIB', 'L08', 'L09', 'CON')) = 0 
			--	begin 
			--	insert #_tmp_ev  
			--	select espe_codigo 
			--	from especies 
			--	where tesp_codigo in ('D', 'B', 'M', 'C') 
			--	end 
			--else 
			--	begin 
			--	insert #_tmp_ev  
			--	select espe_codigo 
			--	from especies 
			--	end 
			end 
			 
 
 
	/* Creo la tabla temporal de resultado*/ 
	create table #_tmp_especies ( 
		Alias	char(6) collate Modern_Spanish_CI_AS
	) 
 
	/*  
	Busco si hay alguna Especie que tenga el alias segun el filtro. 
	Si lo encuentro, finaliza la busqueda 
	*/ 

	insert #_tmp_especies 
	select espe_codigo  
	from especies  
	where  espe_codigo = upper(ltrim(rtrim(isnull(@_filtro,espe_codigo))))  
		and espe_codigo in (select espe_codigo from #_tmp_ev) 
		and espe_activa = 1
 
	if @@rowcount > 0 goto SALIDA 
 
	select @_filtro_sql = '%' + LTRIM(@_filtro) + '%' 
 
	/* -- Nombre */ 
	insert #_tmp_especies  
	select espe_codigo  
	from especies  
	where (upper(espe_codigo) like upper(@_filtro_sql) or 
		upper(espe_descrip) like upper(@_filtro_sql)) 
		and espe_codigo in (select espe_codigo from #_tmp_ev) 
		 
 
SALIDA:	 
 
	/*  
		SELECT DE LOS DATOS PARA QUE LEVANTE EL COMBO 
	*/ 
 
	if @_OperacionTipo = '##GRID_OPTION##'
		select  
			RTRIM(LTRIM(espe_codigo)) as 'Código',  
			RTRIM(LTRIM(espe_descrip)) as 'Descripción' 
		from  
			especies c,  
			#_tmp_especies t 
		where	c.espe_codigo = t.Alias 
	else
		select  
			RTRIM(LTRIM(espe_codigo)) as 'Valor',  
			RTRIM(LTRIM(espe_codigo)) + ' - ' + RTRIM(LTRIM(espe_descrip)) as 'Descripcion'
		from  
			especies c,  
			#_tmp_especies t 
		where	c.espe_codigo = t.Alias --and tesp_codigo = 'B'
		and c.espe_activa = 1
		order by c.espe_codigo, c.espe_descrip
	
end
 

