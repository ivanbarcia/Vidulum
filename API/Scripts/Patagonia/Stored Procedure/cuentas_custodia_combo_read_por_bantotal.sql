if OBJECT_ID('dbo.cuentas_custodia_combo_read_por_bantotal') is not null
begin
	drop procedure dbo.cuentas_custodia_combo_read_por_bantotal
end
go

create procedure [dbo].[cuentas_custodia_combo_read_por_bantotal]
(
	@_clie_cuenta varchar(100), @tipo_custodia int
)
as begin
	
	declare @_tpersona_alias varchar(100)
	declare @_clie_tipodoc varchar(100)
	declare @_clie_nrodoc varchar(100)

	select
	@_tpersona_alias = tpersona_alias,
	@_clie_tipodoc=clie_tipodoc,
	@_clie_nrodoc=clie_nrodoc
	from clientes
	where clie_cuenta=@_clie_cuenta

	if @tipo_custodia = 1
	begin
		exec cuentas_custodia_cg_read @_tpersona_alias,@_clie_tipodoc,@_clie_nrodoc
	end
	if @tipo_custodia = 0
	begin
		exec cuentas_custodia_cr_read @_tpersona_alias,@_clie_tipodoc,@_clie_nrodoc
	end

end
 
