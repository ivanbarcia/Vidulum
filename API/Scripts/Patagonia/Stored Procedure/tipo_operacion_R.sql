if OBJECT_ID('dbo.tipo_operacion_R') is not null
begin
	drop procedure dbo.tipo_operacion_R
end
go

create procedure dbo.tipo_operacion_R (@_filtro varchar(255), @_OperacionTipo varchar(20) = null) 
as begin
	select 
		ltrim(rtrim(tope_codigo)) as 'Valor', 
		ltrim(rtrim(tope_codigo)) + ' - ' + ltrim(rtrim(tope_descrip)) as 'Descripcion'
	from 
		tiposoper 
	where 
		tope_codigo like ltrim(rtrim(isnull(@_filtro,''))) + '%'
end