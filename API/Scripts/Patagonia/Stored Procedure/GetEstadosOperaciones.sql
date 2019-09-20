if OBJECT_ID('dbo.GetEstadosOperaciones') is not null
begin
	drop procedure dbo.GetEstadosOperaciones
end
go

create procedure dbo.GetEstadosOperaciones
as  
begin
	
	create table #_temp (
		Valor varchar(max),
		Descripcion varchar(max)
	)
	
	insert into #_temp select 'G', 'G - Global'
	insert into #_temp select 'C', 'C - Cerrada'
	insert into #_temp select 'F', 'F - Confirmada'
	insert into #_temp select 'K', 'K - Cancelada'
	insert into #_temp select 'N', 'N - Anulada'
	insert into #_temp select 'R', 'R - Rechazada'

	select * from #_temp

	drop table #_temp
end
