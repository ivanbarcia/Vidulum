if OBJECT_ID('dbo.ObtenerUltimoPrecio') is not null
begin
	drop procedure dbo.ObtenerUltimoPrecio
end
go
 
CREATE procedure dbo.ObtenerUltimoPrecio (@espe_codigo varchar(max))
as begin 
	
	if (@espe_codigo = 'SP500')
		set @espe_codigo = 'S&P500'

	DECLARE @mercado varchar(max) = 'M20'
	if @espe_codigo in ('02B', '12B', '80B')
		select @mercado = 'M20'

	if @espe_codigo in ('MHDA09', 'S&P500', 'IBOV')
		select @mercado = 'BOL'

	DECLARE @precio decimal(18,2) = (select dbo.UltimaCotizacionConocida (@espe_codigo, getdate(), 0, 0, 'NOSIS', dbo.MonedaLocal(), @mercado,1))

	select isnull(@precio, 1) as 'Cotizacion'

end    
