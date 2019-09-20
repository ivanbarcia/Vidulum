
if exists(select top 1 1 from INFORMATION_SCHEMA.COLUMNS c where c.TABLE_NAME = 'historico_portal_pass' and c.COLUMN_NAME = 'Contraseña')
	exec sp_RENAME 'historico_portal_pass.Contraseña', 'Contrasena' , 'COLUMN';

GO

if exists(select top 1 1 from INFORMATION_SCHEMA.COLUMNS c where c.TABLE_NAME = 'ClientesLogin' and c.COLUMN_NAME = 'Contraseña')
	exec sp_RENAME 'ClientesLogin.Contraseña', 'Contrasena' , 'COLUMN';

GO