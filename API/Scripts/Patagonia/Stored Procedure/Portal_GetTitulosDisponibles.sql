if OBJECT_ID('dbo.GetTitulosDisponibles') is not null
begin
	drop procedure dbo.GetTitulosDisponibles
end
go
 
CREATE procedure dbo.GetTitulosDisponibles 
as begin 
	

	create table #_temp (    
		Especie varchar(max),
		Emisor varchar(max),
		Calificacion varchar(max),
		Instrumento varchar(max),
		Precio float null,
		TasaRendimiento float null,
		Vencimiento datetime null
	)

	insert into #_temp
	select 
		e.espe_codigo,
		null,
		null,
		ltrim(rtrim(te.tesp_descrip)),
		isnull((select dbo.UltimaCotizacionConocida (e.espe_codigo, getdate(), 0, 0, 'NOSIS', dbo.MonedaLocal(), 'BOL',1)), 0),
		isnull((select top 1 Rendimiento30Dias * 100 from RendimientoFondos where Fondo = e.espe_codigo order by Fecha desc), 0),
		(select MAX(cupo_fvence) from espe_cupones where espe_codigo = e.espe_codigo)
	from
		especies e
		inner join tiposespecies te on te.tesp_codigo = e.tesp_codigo
	where
		e.espe_activa = 1
		and e.tesp_codigo not in ('D', 'B')


	select * from #_temp

	drop table #_temp
end
