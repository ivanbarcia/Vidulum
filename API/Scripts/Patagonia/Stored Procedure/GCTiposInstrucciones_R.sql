ALTER procedure dbo.GCTiposInstrucciones_R (@filtro varchar(100)=null, @isGrid varchar(30)=null)

as begin
	if (@filtro is null)
		set @filtro = ''
	if (@isGrid = '##GRID_OPTION##')
		begin
			select 
				ID						'ID'			,
				Alias					'Alias'			,
				Descripcion				'Descripcion'	,
				FechaAlta								,
				UsuarioAlta								,
				FechaEstado								,
				UsuarioEstado
			from	
				GCTiposInstrucciones			
			where
				(alias like '%' + ltrim(rtrim(@filtro)) + '%' 
			or  descripcion like '%' + ltrim(rtrim(@filtro)) + '%' 
			) and estado = 1
		
			order by
				alias asc
		end

	else
		begin /* COMBO */	
				select 
					GCT.ID	 														,
					(ltrim(rtrim(GCT.Alias)) + ' - ' + ltrim(rtrim(GCT.Descripcion))) as Descripcion
				from	
							GCTiposInstrucciones			GCT					
				where
					(alias like '%' + ltrim(rtrim(@filtro)) + '%' 
					or  descripcion like '%' + ltrim(rtrim(@filtro)) + '%' 
					) 
				and GCT.estado = 1
				and GCT.Alias = isnull((case when @isGrid = '' 
									  then NULL 
									  when  @isGrid = 'ALL' then NULL
									  else @isGrid end), GCT.Alias)	
				and GCT.Alias not in ((isnull((case 
												when @isGrid = '' then null  
												when @isGrid = 'PFJ' then '' 
												when @isGrid = 'ALL' then NULL
												else 'PFJ' 
									end), '')))	
		end

end	
 


