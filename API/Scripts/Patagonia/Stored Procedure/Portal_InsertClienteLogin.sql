if OBJECT_ID('dbo.InsertClienteLogin') is not null
begin
	drop procedure dbo.InsertClienteLogin
end
go
 
CREATE procedure [dbo].InsertClienteLogin (
	@cuit varchar(max),
	@fechaNacimiento datetime,
	@celular varchar(max),
	@email varchar(max)
)
as begin

	if exists (select * from clientes where rtrim(ltrim(clie_nrodoc)) = rtrim(ltrim(@cuit)))
	begin

		if not exists(select * from ClientesLogin where rtrim(ltrim(Usuario)) = rtrim(ltrim(@cuit)))
		begin

			--BUSCO LOS DATOS DE LA TABLA CLIENTES Y LOS VALIDO
			DECLARE @clie_alias varchar(max)
			DECLARE @nombre varchar(max)
			DECLARE @fecha_nacimiento datetime
			DECLARE @telefonoCelular varchar(max)
			DECLARE @correo varchar(max)
		
			select 
				@clie_alias = clie_alias, 
				@nombre = clie_nombreafip,
				@fecha_nacimiento = clie_fnacimiento,
				@telefonoCelular = clie_telefono_celular,
				@correo = clie_email
			from 
				clientes 
			where 
				ltrim(rtrim(clie_nrodoc)) = ltrim(rtrim(@cuit))


			if (@fecha_nacimiento = convert(varchar(8),@fechaNacimiento,112) and
				replace(ltrim(rtrim(@telefonoCelular)),'-','') = replace(ltrim(rtrim(@Celular)),'-','') and ltrim(rtrim(@email)) = ltrim(rtrim(@correo)))
			begin
				insert into 
					ClientesLogin 
					(
						Usuario,
						Contrasena,
						clie_alias,
						NombreAfip,
						Estado,
						FechaAlta,
						UsuarioAlta,
						Email,
						Celular,
						FechaNacimiento,
						Pregunta,
						Bloqueado,
						CantidadIntentosFallidos,
						RenovarClave
					)
				values 
					(
						rtrim(ltrim(@cuit)),
						'',
						@clie_alias,
						@nombre,
						1,
						GETDATE(),
						'SGM',
						ltrim(rtrim(@email)),
						replace(ltrim(rtrim(@Celular)),'-',''),
						@fechaNacimiento,
						0,
						0,
						0,
						0
					)

				select 0 as Value, null as Mensaje
			end
			else
			begin 
				select 1 as Value, 'Los datos ingresados no son correctos' as Mensaje
			end
		end
		else
		begin 
			select 2 as Value, 'El cliente ya existe en el sistema' as Mensaje
		end
	end
	else
	begin 
		select 3 as Value, 'Los datos ingresados no corresponden a un cliente de BASA Capital' as Mensaje
	end

end 
go 
