if OBJECT_ID('dbo.GetEspecieHistoria') is not null
begin
	drop procedure dbo.GetEspecieHistoria
end
go

CREATE PROCEDURE dbo.GetEspecieHistoria
(
	@espe_codigo varchar(max)
)
AS BEGIN

	--declare @mercado varchar(max) = 'BOL'

	--if ((select tesp_codigo from especies where espe_codigo = @espe_codigo) = 'B')
	--BEGIN
	--	set @mercado = 'M20'
	--END
	
	select 
		espe_codigo as Especie,
		pval_fecha as Fecha,
		pval_precio	as Precio		 
	from 
		preciovaluacion 
	where 
		espe_codigo = @espe_codigo 
	--and merc_codigo = @mercado 
	--and espe_cotiza = '69B' 
	and pval_plazo = 0 
	and pval_fecha >= Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6,current_timestamp)), 0) 
	order by 
		pval_fecha desc

END

