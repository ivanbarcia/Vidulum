if OBJECT_ID('dbo.tmp_saldos_tenencias_float') is null
begin

CREATE TABLE [dbo].[tmp_saldos_tenencias_float](
	[ccus_id] [int] NULL,
	[espe_codigo] [varchar](6) NULL,
	[ccm_monto] [float] NULL,
	[precio_val] [float] NULL,
	[monto_val] [float] NULL,
	[ccus_numero] [varchar](500) NULL,
	[fecha_precios] [datetime] NULL,
	[PPCpa] [float] NULL,
	[PPVta] [float] NULL,
	[Rendimiento] [float] NULL,
	[saldo_disponible] [float] NULL,
	[saldo_bloqueado] [float] NULL,
	[Saldo_total] [float] NULL,
	[descripcion_bloqueos] [varchar](400) NULL,
	[saldo_inmovilizado] [float] NULL,
	[saldo_bloqueado_interno] [float] NULL,
	[saldo_bloqueado_externo] [float] NULL
) ON [PRIMARY]

end
GO
