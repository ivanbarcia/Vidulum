if OBJECT_ID('dbo.ReadPortalPass') is not null
begin
	drop procedure dbo.ReadPortalPass
end
go
 
CREATE procedure [dbo].ReadPortalPass (
		@_clie_cuit_encriptado varchar(200),
		@_token		 varchar(200)			
) as begin
	
	declare @_fecha datetime,
			@_id int,
			@_clie_cuit varchar(200)
	select @_fecha = GETDATE()

	select @_id = Id, @_clie_cuit = Usuario from portal_pass 
	where LTRIM(rtrim(UsuarioEncriptado)) = ltrim(rtrim(@_clie_cuit_encriptado))
		  and ltrim(rtrim(TokenHash)) = ltrim(rtrim(@_token))
		  and DATEDIFF(minute, FechaExpira, @_fecha) <= (select param_valor from parametrizar_portal where param_alias = 'TLINK') -- me aseguro que no este vencido		  
		  and Usado = 0

	if (@_id is not null) -- si es null significa que el link estaba vencido o ya fue usado
	begin
		update portal_pass set Usado = 1 -- marco el link como usado
		where Id = @_id 
		
		select 1 as 'Value'				
	end
	else
		select 0 as 'Value' -- el link estaba vencido o usado
end
 
 go 
