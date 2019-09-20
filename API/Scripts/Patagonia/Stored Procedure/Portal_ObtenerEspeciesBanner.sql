if OBJECT_ID('dbo.ObtenerEspeciesBanner') is not null
begin
	drop procedure dbo.ObtenerEspeciesBanner
end
go
 
CREATE procedure dbo.ObtenerEspeciesBanner (@_fecha varchar(max) = null)
as begin 

	create table #_tmp 
	(    
		Orden int,
		Codigo varchar(max),
		Descripcion varchar(max),
		Valor decimal
	)
	
	if (@_fecha is null)
		set @_fecha = (select GETDATE())

	insert into #_tmp
	select
		1,
		'02B',
		'USD / PYG',
		(select dbo.UltimaCotizacionConocida ('02B', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'M20',1))

	insert into #_tmp
	select
		2,
		'12B',
		'BRL / PYG',
		(select dbo.UltimaCotizacionConocida ('12B', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'M20',1))

	insert into #_tmp
	select
		3,
		'80B',
		'PESO ARG / PYG',
		(select dbo.UltimaCotizacionConocida ('80B', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'M20',1))
	
	insert into #_tmp
	select
		4,
		'MHDA09',
		'Bono PYG USD NY',
		(select dbo.UltimaCotizacionConocida ('MHDA09', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'BOL',1))
	
	insert into #_tmp
	select
		5,
		'SP500',
		'S&P 500',
		(select dbo.UltimaCotizacionConocida ('S&P500', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'BOL',1))

	insert into #_tmp
	select
		6,
		'IBOV',
		'BOVESPA',
		(select dbo.UltimaCotizacionConocida ('IBOV', @_fecha, 0, 0, 'NOSIS', dbo.MonedaLocal(), 'BOL',1))
	
	
	select * from #_tmp 
    
	drop table #_tmp

end    
