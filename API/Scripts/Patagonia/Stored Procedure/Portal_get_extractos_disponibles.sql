if OBJECT_ID('dbo.get_extractos_disponibles') is not null
begin
	drop procedure dbo.get_extractos_disponibles
end
go
 
CREATE procedure dbo.get_extractos_disponibles (@clie_alias varchar(max))
as begin 

	select 
		fecha, 
		ltrim(rtrim(ra.espe_codigo)) as espe_codigo,
		ltrim(rtrim(e.espe_descrip)) as espe_descrip 
	from 
		reportes_almacenados ra
		inner join especies e on e.espe_codigo = ra.espe_codigo
	where 
		clie_alias = @clie_alias
		and tipo_reporte = 'Extracto'
	order by fecha

end 	
go
