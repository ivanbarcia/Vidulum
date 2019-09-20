if exists(select * from sysobjects where type = 'p' and name = 'PortalLog_Read') 
 begin 
     drop procedure PortalLog_Read 
 end 
 go 
 
CREATE procedure [dbo].[PortalLog_Read](
       @_clie_cuit varchar(30),
       @_fdesde datetime,
       @_fhasta datetime,
       @_accion_id int
)
as 
begin 
	
	if (@_accion_id = -1) set @_accion_id = null
	
	-- inserto en la tabla de log un registro de alta usuario
	select l.accion_id, a.accion_descrip, l.log_fecha, l.clie_cuit, l.clie_nombreafip, isnull(l.log_ip,'') log_ip
	from portal_log l join portal_acciones a on a.accion_id = l.accion_id 
	where Convert(varchar(8),l.log_fecha,112) >= Convert(varchar(8),@_fdesde,112)
		  and Convert(varchar(8),l.log_fecha,112) <= Convert(varchar(8),@_fhasta,112)
		  and LTRIM(rtrim(clie_cuit)) like '%'+ltrim(rtrim(isnull(@_clie_cuit,'')))+'%'	  
		  and l.accion_id = isnull(@_accion_id,l.accion_id)	

	print @_fdesde
	print @_fhasta
end
