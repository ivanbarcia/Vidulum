if OBJECT_ID('dbo.GetFondo') is not null
begin
	drop procedure dbo.GetFondo
end
go

CREATE PROCEDURE dbo.GetFondo
(
	@espe_codigo varchar(max)
)
AS BEGIN

	declare @valorCP decimal(18,2)
	declare @totalMonto decimal(18,2)
	declare @totalCP decimal(18,2)

	set @valorCP = (select top 1 pval_precio from preciovaluacion where pval_origen = 'VCP' and espe_codigo = @espe_codigo order by pval_fechora desc)
	set @totalMonto = (select sum(oper_monto) from operaciones where espe_codigo = @espe_codigo)
	set @totalCP = cast((@totalMonto / @valorCP) as decimal(18,2))

	select 
		ltrim(rtrim(espe_codigo)) as Codigo,
		ltrim(rtrim(espe_descrip)) as Descripcion, 
		ltrim(rtrim(espe_codcot)) as Moneda,
		@valorCP as ValorCuotaParte,
		@totalMonto as TotalMonto,
		@totalCP as TotalCP,
		0 as CuentaMonetaria,
		0 as CuentaFondo
	from 
		especies
	where 
		ltrim(rtrim(espe_codigo)) = @espe_codigo

END

