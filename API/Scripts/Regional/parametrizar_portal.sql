/****** Object:  Table [dbo].[parametrizar_portal]    Script Date: 14/2/2019 11:03:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[parametrizar_portal](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[param_alias] [varchar](6) NULL,
	[param_descrip] [varchar](250) NULL,
	[param_valor] [int] NULL,
	[usua_estado] [varchar](3) NULL,
	[param_festado] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


