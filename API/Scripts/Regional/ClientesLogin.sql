/****** Object:  Table [dbo].[ClientesLogin]    Script Date: 14/2/2019 10:38:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ClientesLogin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Usuario] [varchar](max) NOT NULL,
	[Contraseña] [varchar](max) NOT NULL,
	[clie_alias] [varchar](50) NOT NULL,
	[NombreAfip] [varchar](max) NOT NULL,
	[Estado] [int] NOT NULL,
	[FechaAlta] [datetime] NOT NULL,
	[UsuarioAlta] [varchar](256) NOT NULL,
	[FechaModificacion] [datetime] NULL,
	[UsuarioModificacion] [varchar](256) NULL,
	[Pregunta] [int] NULL,
	[Respuesta] [varchar](256) NULL,
	[Bloqueado] [int] NULL,
	[CantidadIntentosFallidos] [int] NULL,
	[RenovarClave] [int] NULL,
	[Email] [varchar](max) NULL,
 CONSTRAINT [PK_ClientesLogin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

--SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT (NULL) FOR [Pregunta]
GO

ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT (NULL) FOR [Respuesta]
GO

ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [Bloqueado]
GO

ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [CantidadIntentosFallidos]
GO

ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [RenovarClave]
GO



