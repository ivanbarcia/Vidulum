if exists(select * from sysobjects where name = 'GetEspecies')
	drop procedure GetEspecies
go

CREATE PROCEDURE dbo.GetEspecies
AS BEGIN

	select 
		ltrim(rtrim(espe_codigo)) as 'Codigo',
		ltrim(rtrim(espe_descrip)) as 'Descripcion'
	from 
		especies 

END


