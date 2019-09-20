if OBJECT_ID('dbo.GetClaseOperacion') is not null
begin
	drop procedure dbo.GetClaseOperacion
end
go

create procedure dbo.GetClaseOperacion
as  
begin
	
	create table #_temp (
		Valor varchar(max),
		Descripcion varchar(max)
	)

	insert into #_temp select 'CAM', 'Cambios'
	insert into #_temp select 'OCT', 'OCT Agentes'
	insert into #_temp select 'OCC', 'Forward'
	insert into #_temp select 'SWP', 'SWAPS MAE'
	insert into #_temp select 'SWC', 'SWAPS Cliente'
	insert into #_temp select 'RFX', 'ROFEX'
	insert into #_temp select 'CAO', 'Calls Otorgados'
	insert into #_temp select 'CAT', 'Calls Tomados'
	insert into #_temp select 'PAA', 'Pases Activos'
	insert into #_temp select 'PAP', 'Pases Pasivos'
	insert into #_temp select 'CBC', 'Caución Bursátil Colocadora'
	insert into #_temp select 'CBT', 'Caución Bursátil Tomadora'
	insert into #_temp select 'PRE', 'Prestamos'
	insert into #_temp select 'PFJ', 'Plazos Fijos'
	insert into #_temp select 'CEC', 'Ctas.E.Clientes'
	insert into #_temp select 'FCI', 'Fondos Común De Inversión'
	insert into #_temp select 'SCE', 'COMEX'

	select * from #_temp

	drop table #_temp
end
