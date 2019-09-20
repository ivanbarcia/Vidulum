if exists(select * from sysobjects where xtype='P' and name = 'spObtenerHistoricoPrecios')
begin
	drop procedure dbo.spObtenerHistoricoPrecios
end
go
 

create procedure spObtenerHistoricoPrecios (@especie varchar(max))
as
begin
	
	DECLARE @fechaHasta date = (select getdate())
	DECLARE @fechaDesde date = (select DATEADD(day,-30,@fechaHasta))
			
	select 
		pv.pval_fecha as 'Fecha',
		convert(decimal(32,2), pv.pval_precio) as 'Precio'
	from 
		preciovaluacion pv
		left join RendimientoFondos rf on rf.Fondo = pv.espe_codigo and convert(varchar(8),pv.pval_fecha,112) = convert(varchar(8),rf.Fecha,112)
	where 
		pv.espe_codigo = @especie
		and convert(varchar(8),pv.pval_fecha,112) between @fechaDesde and @fechaHasta

end