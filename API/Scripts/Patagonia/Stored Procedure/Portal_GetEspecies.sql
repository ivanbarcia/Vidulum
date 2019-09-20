if OBJECT_ID('dbo.GetEspecies') is not null
begin
	drop procedure dbo.GetEspecies
end
go

CREATE PROCEDURE dbo.GetEspecies
AS BEGIN

	select 
		ltrim(rtrim(espe_codigo)) as 'Codigo',
		ltrim(rtrim(espe_descrip)) as 'Descripcion'
	from 
		especies 

END


