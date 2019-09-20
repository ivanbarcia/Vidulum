if OBJECT_ID('dbo.GetPregunta') is not null
begin
	drop procedure dbo.GetPregunta
end
go
 
create procedure dbo.GetPregunta
	(@_clie_cuit_encriptado varchar(200))
as 
begin 
	declare @_clie_cuit varchar(200)

	select @_clie_cuit = Usuario from portal_pass 
	where LTRIM(rtrim(UsuarioEncriptado)) = ltrim(rtrim(@_clie_cuit_encriptado))
	 
	select 
		p.id id,
		ltrim(rtrim(p.pregunta)) pregunta 
	from 
		preguntas p 
		join ClientesLogin cl on p.id = cl.Pregunta 
	where 
		Usuario = @_clie_cuit 
		 
end
 
go 
