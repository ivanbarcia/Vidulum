if OBJECT_ID('dbo.reportes_almacenados') is null
begin

CREATE TABLE [dbo].reportes_almacenados(
	[fecha] [datetime] NULL,
	[clie_alias] [int],
	[espe_codigo] [varchar](max) NULL,
	[oper_numero] [int] NULL,
	[tipo_reporte] [varchar](max) NULL,
	[reporte] [varbinary](max) NULL
) ON [PRIMARY]

end
GO