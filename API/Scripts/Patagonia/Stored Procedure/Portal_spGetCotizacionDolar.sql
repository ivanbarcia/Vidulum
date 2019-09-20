if OBJECT_ID('dbo.spGetCotizacionDolar') is not null
begin
	drop procedure dbo.spGetCotizacionDolar
end
go

CREATE procedure [dbo].[spGetCotizacionDolar]  (@_fecha datetime)    
as    
begin    
    
	select top 1 
		convert(decimal(18,2),pval_precio) as 'Cotizacion'
	from 
		preciovaluacion 
	where 
		espe_codigo = '02B' 
		and merc_codigo = 'M20' 
		and pval_fecha <= @_fecha 
	order by pval_fecha desc

end
