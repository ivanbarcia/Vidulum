if exists(select * from sysobjects where type = 'p' and name = 'PortalLog_Insert') 
 begin 
     drop procedure PortalLog_Insert 
 end 
 go 
 create procedure [dbo].[PortalLog_Insert](
       @_clie_cuit varchar(30),
       @_accion_id int,
       @_IP varchar(255)
)
as 
begin 
	-- inserto en la tabla de log un registro de alta usuario
	insert into portal_log
	select @_accion_id,GETDATE(),clie_alias, @_clie_cuit, clie_nombreafip, @_IP
	from clientes
	where ltrim(rtrim(clie_cuit)) = ltrim(rtrim(@_clie_cuit))

end
 
