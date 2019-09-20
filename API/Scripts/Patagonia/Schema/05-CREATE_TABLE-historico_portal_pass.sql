if OBJECT_ID('dbo.historico_portal_pass') is null
begin
CREATE TABLE [dbo].[historico_portal_pass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Usuario] [varchar](200) NULL,
	[Contrasena] [varchar](200) NULL,
	[clie_alias] [varchar](6) NULL,
	[FechaAlta] [datetime] NULL
) ON [PRIMARY]

end
GO


