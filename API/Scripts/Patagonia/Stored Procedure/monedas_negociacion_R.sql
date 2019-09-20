ALTER Procedure dbo.monedas_negociacion_R (@_filter varchar(20)=null , @_isGrid varchar(30)=null)
as
Begin

	if(@_filter is null)
		set @_filter =''

	select 
		espe_codigo as 'Valor',
		ltrim(rtrim(espe_codigo)) + '-' + ltrim(rtrim(espe_descrip)) as 'Descripcion'
	from
		monedas_negociacion
	where 
		espe_descrip like rtrim(ltrim(@_filter)) + '%'
	or espe_codigo like rtrim(ltrim(@_filter)) + '%'
					

End