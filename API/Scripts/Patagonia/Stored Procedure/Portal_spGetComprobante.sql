if OBJECT_ID('dbo.spGetComprobante') is not null
begin
	drop procedure dbo.spGetComprobante
end
go

create procedure dbo.spGetComprobante (@oper_numero int)
as
begin
	
	select top 1 * from reportes_almacenados where oper_numero = @oper_numero

end
