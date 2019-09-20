if OBJECT_ID('dbo.parametrizar_portal') is null
begin
CREATE TABLE [dbo].[parametrizar_portal](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[param_alias] [varchar](6) NULL,
	[param_descrip] [varchar](250) NULL,
	[param_valor] [int] NULL,
	[usua_estado] [varchar](3) NULL,
	[param_festado] [datetime] NULL
) ON [PRIMARY]

end
GO


