if object_id('dbo.portal_pass') is null
CREATE TABLE [dbo].[portal_pass](
	[Id] [int] NULL,
	[Usuario] [varchar](200) NULL,
	[UsuarioEncriptado] [varchar](200) NULL,
	[TokenHash] [varchar](200) NULL,
	[FechaExpira] [datetime] NULL,
	[Usado] [int] NULL,
	[Registro] [int] NULL
) ON [PRIMARY]
GO
