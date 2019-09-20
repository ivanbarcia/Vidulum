if object_id('portal_log') is null 
begin 
	
CREATE TABLE [dbo].[portal_log](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[accion_id] [varchar](100) NULL,
	[log_fecha] [datetime] NULL,
	[clie_alias] [varchar](5) NULL,
	[clie_cuit] [varchar](20) NULL,
	[clie_nombreafip] [varchar](200) NULL,
	[log_ip] [varchar](15) NULL
) ON [PRIMARY]

end
go


