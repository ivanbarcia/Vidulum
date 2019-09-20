if exists(select * from sysobjects where name = 'spGetCotizacionDolar')
	drop procedure spGetCotizacionDolar
go           
    
CREATE procedure [dbo].[spGetCotizacionDolar]  (@_fecha datetime)    
as    
begin    
    
	select top 1 
		pval_precio as 'Cotizacion'
	from 
		preciovaluacion 
	where 
		espe_codigo = '02B' 
		and merc_codigo = 'M20' 
		and pval_fecha <= @_fecha 
	order by pval_fecha desc

end