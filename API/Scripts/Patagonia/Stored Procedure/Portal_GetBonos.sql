if OBJECT_ID('dbo.GetBonos') is not null
begin
	drop procedure dbo.GetBonos
end
go 

CREATE PROCEDURE dbo.GetBonos 
AS BEGIN
	
	select 
		ltrim(rtrim(espe_codigo)) as 'Codigo', 
		ltrim(rtrim(espe_descrip)) as 'Descripcion'
	from 
		especies 
	where 
		tesp_codigo in ('N', 'O', 'V', 'W')

END

