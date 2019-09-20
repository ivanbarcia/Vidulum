if OBJECT_ID('dbo.UpdateClienteLoginData') is not null
begin
	drop procedure dbo.UpdateClienteLoginData
end
go

create procedure dbo.UpdateClienteLoginData  
(  
	@clie_alias varchar(max),
	@email varchar(max)
)  
as begin  
  
	if exists(select * from ClientesLogin where clie_alias = @clie_alias)
	BEGIN

		update 
			ClientesLogin 
		set 
			Email = @email
		where 
			clie_alias = @clie_alias

		update
			Clientes
		set
			clie_email = @email
		where
			clie_alias = @clie_alias

		select 200 as StatusCode, 'OK' as Message

	END
	ELSE
	BEGIN
		select 401 as StatusCode, 'Cliente incorrecto' as Message
	END

end  


go

