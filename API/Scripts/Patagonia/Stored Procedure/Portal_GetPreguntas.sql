if OBJECT_ID('dbo.GetPreguntas') is not null
begin
	drop procedure dbo.GetPreguntas
end
go

create procedure dbo.GetPreguntas
as 
begin 
	select id, ltrim(rtrim(pregunta)) as 'pregunta' from preguntas
end
 
go 
