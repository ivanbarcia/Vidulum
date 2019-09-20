delete dbo.parametrizar_portal
GO
SET IDENTITY_INSERT [dbo].[parametrizar_portal] ON 
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (1, N'TLINK', N'tiempo_link_activo_minutos', 30, N'SGM', CAST(N'2018-01-23T19:24:12.080' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (2, N'MINMAY', N'cantidad_minima_mayusculas_pass', 1, N'SGM', CAST(N'2018-01-23T19:24:12.083' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (3, N'MINCAR', N'cantidad_minima_caracteres_especiales_pass', 1, N'SGM', CAST(N'2018-01-23T19:24:12.087' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (4, N'MINNUM', N'cantidad_minima_numeros_pass', 2, N'SGM', CAST(N'2018-01-23T19:24:12.090' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (5, N'TAMMAX', N'tamanio_max_pass', 20, N'SGM', CAST(N'2018-01-23T19:24:12.093' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (6, N'TAMMIN', N'tamanio_min_pass', 6, N'SGM', CAST(N'2018-01-23T19:24:12.097' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (7, N'CINT', N'cantidad_intentos_fallidos', 3, N'SGM', CAST(N'2018-01-23T19:24:12.097' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (8, N'TPASS', N'tiempo_pass_activa_dias', 30, N'SGM', CAST(N'2018-01-23T19:24:12.100' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (9, N'CHIS', N'cantidad_historico_pass', 5, N'SGM', CAST(N'2018-01-23T19:24:12.103' AS DateTime))
INSERT [dbo].[parametrizar_portal] ([id], [param_alias], [param_descrip], [param_valor], [usua_estado], [param_festado]) VALUES (10, N'CUSU', N'cantidad_sesiones_por_usuario', 1, N'SGM', CAST(N'2018-01-23T19:24:12.107' AS DateTime))
SET IDENTITY_INSERT [dbo].[parametrizar_portal] OFF
GO
update dbo.parametrizar_portal set param_valor = 6 where param_alias = 'TAMMAX'
update dbo.parametrizar_portal set param_valor = 6 where param_alias = 'MINNUM'
update dbo.parametrizar_portal set param_valor = 0 where param_alias = 'MINMAY'
update dbo.parametrizar_portal set param_valor = 0 where param_alias = 'MINCAR'

