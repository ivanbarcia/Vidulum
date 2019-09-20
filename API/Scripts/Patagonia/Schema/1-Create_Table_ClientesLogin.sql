if object_id('ClientesLogin') is null 
begin
CREATE TABLE [dbo].[ClientesLogin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Usuario] [varchar](max) NOT NULL,
	[Contrasena] [varchar](max) NOT NULL,
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
	[Celular] [varchar](max) NULL,
	[FechaNacimiento] [datetime] NULL,
 CONSTRAINT [PK_ClientesLogin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


SET ANSI_PADDING OFF


ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT (NULL) FOR [Pregunta]


ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT (NULL) FOR [Respuesta]


ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [Bloqueado]


ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [CantidadIntentosFallidos]


ALTER TABLE [dbo].[ClientesLogin] ADD  DEFAULT ((0)) FOR [RenovarClave]
end

go
-- FIX ContraseÃ±a
if exists(select top 1 1 from information_schema.columns c where c.TABLE_NAME = 'ClientesLogin' and c.column_name = 'ContraseÃ±a')
	exec sp_RENAME 'ClientesLogin.ContraseÃ±a' , 'Contrasena', 'COLUMN'
go

