if OBJECT_ID('dbo.spGetExtracto') is not null
begin
	drop procedure dbo.spGetExtracto
end
go 

create procedure dbo.spGetExtracto (@clieAlias varchar(max), @espe_codigo varchar(max), @periodo varchar(max))
as
begin
	
	DECLARE @mes int = (select convert(int, substring(@periodo,1,2)))
	DECLARE @anio int = (select convert(int, substring(@periodo,3,4)))
	
	select 
		top 1 * 
	from 
		reportes_almacenados 
	where 
		clie_alias = convert(int,@clieAlias) 
		and espe_codigo = @espe_codigo
		and datepart(month,fecha) = @mes
		and datepart(year,fecha) = @anio
		and tipo_reporte = 'Extracto'
end
