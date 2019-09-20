if OBJECT_ID('dbo.MercadosT_R_Portal') is not null
begin
	drop procedure dbo.MercadosT_R_Portal
end
go

create procedure dbo.MercadosT_R_Portal
as  
begin
	
	create table #_temp (
		Valor varchar(max),
		Descripcion varchar(max)
	)

	insert into #_temp select 'LIB', 'MEC'
	insert into #_temp select 'MAE', 'MAE'
	insert into #_temp select 'RFX', 'ROFEX'
	insert into #_temp select 'DIN', 'DIN'
	insert into #_temp select 'TIT', 'TIT'
	insert into #_temp select 'MVL', 'MVL'

	select * from #_temp

	drop table #_temp
end
