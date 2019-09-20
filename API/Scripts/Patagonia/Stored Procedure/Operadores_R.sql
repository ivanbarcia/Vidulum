if OBJECT_ID('dbo.Operadores_R') is not null
begin
	drop procedure dbo.Operadores_R
end
go

create procedure dbo.Operadores_R(@_filter varchar(20)=null , @_isGrid varchar(30)='')
as
Begin
	
	if(@_filter is null)
		set @_filter =''
	if(@_isGrid = '##GRID_OPTION##')
		Begin
			select	
				oper_id,
				oper_alias		'Alias',
				oper_nombre		'Nombre',
				oper_legajo		'Legajo',
				case oper_opera	
					when 0 then 'NO'
					else 'SI'
				end	'Opera'
			from
				operadores				
			where 
				(oper_alias like + '%' + @_filter + '%')
			or	(oper_nombre like + '%' + @_filter + '%')
			order by 
				oper_id asc
		End
	else
		Begin /*Combo*/
			select	
				oper_id as 'id',
				ltrim(rtrim(oper_legajo)) as 'Descripcion'
			from
				operadores
			where 
				((oper_alias like + '%' + @_filter + '%')
			or	(oper_nombre like + '%' + @_filter + '%'))
			and	oper_opera = 1
			order by 
				oper_id asc
			
		End	

End