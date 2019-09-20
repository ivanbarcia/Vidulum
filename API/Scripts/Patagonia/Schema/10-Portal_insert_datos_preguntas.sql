if not exists(select top 1 1 from preguntas)
begin 
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (1, N'Nombre de tu primera mascota')
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (2, N'Â¿CuÃ¡l es tu apellido materno?')
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (3, N'Â¿Color preferido?')
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (4, N'Marca de tu primer auto')
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (5, N'Â¿Localidad de nacimiento?')
INSERT [dbo].[preguntas] ([id], [pregunta]) VALUES (6, N'Nombre de tu escuela primaria')
end
