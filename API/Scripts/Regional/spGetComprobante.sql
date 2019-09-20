if exists(select * from sysobjects where xtype='P' and name = 'spGetComprobante')
begin
	drop procedure dbo.spGetComprobante
end
go 

create procedure spGetComprobante (@oper_numero int)
as
begin
	
	select top 1 * from reportes_almacenados where oper_numero = @oper_numero

end