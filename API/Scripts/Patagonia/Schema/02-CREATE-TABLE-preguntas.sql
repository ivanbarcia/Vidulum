if object_id('dbo.preguntas') is null
	CREATE TABLE [dbo].[preguntas](
		[id] [int] NULL,
		[pregunta] [varchar](200) NULL
	) ON [PRIMARY]
go
