if OBJECT_ID('dbo.UpdatePassword') is not null
begin
	drop procedure dbo.UpdatePassword
end
go

create procedure dbo.UpdatePassword  
(  
	@cliente varchar(max),
	@password varchar(max)
)  
as begin  
  
	update 
		ClientesLogin 
	set 
		Contrasena= @password,
		Bloqueado = 0,
		CantidadIntentosFallidos = 0,
		RenovarClave = 0
	where 
		Usuario = @cliente
	 
	select 1 
end  


go

