if OBJECT_ID('dbo.ObtenerClieCuit') is not null
begin
	drop procedure dbo.ObtenerClieCuit
end
go 
 
CREATE procedure [dbo].ObtenerClieCuit (
		@_clie_cuit_encriptado varchar(200),
		@_token		 varchar(200)			
) as begin
	
	declare @_clie_cuit varchar(200)
	
	select @_clie_cuit = Usuario from portal_pass 
	where LTRIM(rtrim(UsuarioEncriptado)) = ltrim(rtrim(@_clie_cuit_encriptado))
		  and ltrim(rtrim(TokenHash)) = ltrim(rtrim(@_token))
		  
	select ltrim(rtrim(@_clie_cuit)) as 'Cuit'
end
 
go 
