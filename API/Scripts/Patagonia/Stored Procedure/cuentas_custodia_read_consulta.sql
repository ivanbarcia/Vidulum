if OBJECT_ID('dbo.cuentas_custodia_read_consulta') is not null
begin
	drop procedure dbo.cuentas_custodia_read_consulta
end
go

create procedure [dbo].[cuentas_custodia_read_consulta]
(
	@_clie_cuentas varchar(max),@_tipo_custodia int
)
as begin
	
	DECLARE @sqlCommand varchar(1000)
	
	SET @sqlCommand = CONCAT('
	select 
		cc.ccus_id,
		t.tccus_alias + '' - '' + t.tccus_descrip + '' - '' + convert(varchar(50),cc.ccus_numero) as ''ccus_numero'',
		c.clie_alias		,
		rtrim(ltrim(ISNULL(c.clie_apellido,''''))) + '' '' + rtrim(ltrim(ISNULL(c.clie_nombre,''''))) as ''titular'',
		c.tpersona_alias as ''tpersona_titular''	,
		cc.tccus_alias
	from
		cuentas_custodia cc,
		cuentas_custodia_vinculadas ccv,
		clientes c,
		tiposcuentas_custodia t
	where
		cc.ccus_id = ccv.ccus_id
		and	ccv.clie_alias = c.clie_alias
		and cc.ccus_estado in (''A'',''B'')
		and cc.tccus_alias = t.tccus_alias
		and c.clie_cuenta in(',@_clie_cuentas,')
		and t.cg=',@_tipo_custodia,'')
	
	EXEC (@sqlCommand)

end
 
