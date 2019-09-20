if OBJECT_ID('dbo.GCInstrucciones_R1_Portal') is not null
begin
	drop procedure dbo.GCInstrucciones_R1_Portal
end
go

create procedure dbo.GCInstrucciones_R1_Portal (@Id int)  
as  
begin

	select   
		gci.ID,
		Numero,
		gci.Estado,
		gcei.Alias as EstadoDescrip,
		clie_alias,
		TipoInstruccion,
		FechaConcertacion,
		FechaLiquidacion,
		Referencia,
		espe_codigo,
		Cantidad,
		ccus_id,
		CasaCustodia,
		ContraparteDepositante,
		ContraparteComitente,
		espe_codcot,
		MontoLiquidacion,
		Observaciones,
		Precancelable,
		isnull(TipoPlazoFijo,0) as TipoPlazoFijo,
		isnull(BancoEmisor,0) as BancoEmisor,
		Intereses,
		convert(decimal(18,2),TNA) as TNA,
		NroCliente,
		CuentaDepositante,
		NroLote,
		isnull(TipoOtro,0) as TipoOtro,
		Concepto,
		Motivo,
		GeneraMensaje,
		isnull(CodigoMatching,0) as CodigoMatching,
		gci.FechaAlta,
		gci.UsuarioAlta,
		gci.FechaEstado,
		gci.UsuarioEstado,
		ClienteInterno
	from
		GCInstrucciones gci
		inner join GCEstadosInstrucciones gcei on gci.Estado = gcei.ID
	where
		gci.ID = @ID
		
end
