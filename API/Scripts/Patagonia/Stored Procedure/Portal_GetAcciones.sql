if OBJECT_ID('dbo.GetAcciones') is not null
begin
	drop procedure dbo.GetAcciones
end
go 

CREATE PROCEDURE dbo.GetAcciones 
AS BEGIN
	
	select 
		ltrim(rtrim(espe_codigo)) as 'Codigo', 
		ltrim(rtrim(espe_descrip)) as 'Descripcion'
	from 
		especies 
	where 
		tesp_codigo = 'A'

END

