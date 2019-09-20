if OBJECT_ID('dbo.GCPlazoFijo_ValidarFechas') is not null
begin
	drop procedure dbo.GCPlazoFijo_ValidarFechas
end
go

create procedure dbo.GCPlazoFijo_ValidarFechas(  
 @_dpFechaConcertacion datetime = null,  
 @_dpFechaLiquidacion  datetime = null,  
 @_dpFechaRecepcion   datetime = null  
)  
as  
begin  
   
 declare @_Respuesta varchar(100),  
   @_FechaOut datetime  
   
 exec calc_fecha_xdiashabiles @_dpFechaConcertacion,0,0,@_FechaOut output   
  
 if(@_FechaOut != cast(@_dpFechaConcertacion as date))   
  begin  
  select @_Respuesta = 'Fecha de Concertaci�n no pertenece a una d�a H�bil'  
  goto SALIDA  
  end  
  
 exec calc_fecha_xdiashabiles @_dpFechaLiquidacion,0,0,@_FechaOut output   
  
 if(@_FechaOut != cast(@_dpFechaLiquidacion as date))   
  begin  
  select @_Respuesta = 'Fecha de Liquidaci�n no pertenece a una d�a H�bil'  
  goto SALIDA  
  end  
  
 exec calc_fecha_xdiashabiles @_dpFechaRecepcion,0,0,@_FechaOut output   
  
 if(@_FechaOut != cast(@_dpFechaRecepcion as date))   
  begin  
  select @_Respuesta = 'Fecha de Recepci�n no pertenece a una d�a H�bil'  
  goto SALIDA  
  end  
  
  select @_Respuesta = 'OK'  
  
SALIDA:  
 select @_Respuesta as 'Texto'
  
end  