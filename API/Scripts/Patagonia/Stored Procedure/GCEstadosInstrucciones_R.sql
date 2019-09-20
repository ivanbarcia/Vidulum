ALTER Procedure dbo.GCEstadosInstrucciones_R (@_filter varchar(20)=null , @_isGrid varchar(30)=null)
as
Begin
	
	if(@_filter is null)
		set @_filter =''
	if(@_isGrid = '##GRID_OPTION##')
		Begin
			select 
				merc_codigo 'Código', 
				rtrim(merc_descrip) 'Descripción',
				tesp_grupo 'Grupo Especie',
				merc_tipo 'Tipo' 
			from
				mercados
		End
	else
		Begin
			select 
				e.ID,
				ltrim(rtrim(e.Alias)) + '-' + ltrim(rtrim(Descripcion)) as'Descripcion'
			from
				GCEstadosInstrucciones e 
				
			where 
				(e.Alias like @_filter + '%'
			or	Descripcion like  rtrim(ltrim(@_filter)) + '%'
			)
			and e.Estado = 1
		End

End