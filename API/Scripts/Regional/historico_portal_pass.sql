/****** Object:  Table [dbo].[historico_portal_pass]    Script Date: 14/2/2019 11:02:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[historico_portal_pass](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Usuario] [varchar](200) NULL,
	[Contraseña] [varchar](200) NULL,
	[clie_alias] [varchar](6) NULL,
	[FechaAlta] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


