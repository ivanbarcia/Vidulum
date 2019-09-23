using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace API.Migrations
{
    public partial class initial3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Cotizacion_Moneda_MonedaId",
                table: "Cotizacion");

            migrationBuilder.DropForeignKey(
                name: "FK_Sueldo_Trabajo_TrabajoId",
                table: "Sueldo");

            migrationBuilder.DropForeignKey(
                name: "FK_Sueldo_Usuario_UsuarioUserName",
                table: "Sueldo");

            migrationBuilder.DropForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo");

            migrationBuilder.DropForeignKey(
                name: "FK_Usuario_Trabajo_TrabajoId",
                table: "Usuario");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Usuario",
                table: "Usuario");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Trabajo",
                table: "Trabajo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Sueldo",
                table: "Sueldo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Sindicato",
                table: "Sindicato");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Moneda",
                table: "Moneda");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Cotizacion",
                table: "Cotizacion");

            migrationBuilder.DropColumn(
                name: "UserName",
                table: "Usuario");

            migrationBuilder.RenameTable(
                name: "Usuario",
                newName: "Usuarios");

            migrationBuilder.RenameTable(
                name: "Trabajo",
                newName: "Trabajos");

            migrationBuilder.RenameTable(
                name: "Sueldo",
                newName: "Sueldos");

            migrationBuilder.RenameTable(
                name: "Sindicato",
                newName: "Sindicatos");

            migrationBuilder.RenameTable(
                name: "Moneda",
                newName: "Monedas");

            migrationBuilder.RenameTable(
                name: "Cotizacion",
                newName: "Cotizaciones");

            migrationBuilder.RenameIndex(
                name: "IX_Usuario_TrabajoId",
                table: "Usuarios",
                newName: "IX_Usuarios_TrabajoId");

            migrationBuilder.RenameIndex(
                name: "IX_Trabajo_SindicatoId",
                table: "Trabajos",
                newName: "IX_Trabajos_SindicatoId");

            migrationBuilder.RenameColumn(
                name: "UsuarioUserName",
                table: "Sueldos",
                newName: "UsuarioEmail");

            migrationBuilder.RenameIndex(
                name: "IX_Sueldo_UsuarioUserName",
                table: "Sueldos",
                newName: "IX_Sueldos_UsuarioEmail");

            migrationBuilder.RenameIndex(
                name: "IX_Sueldo_TrabajoId",
                table: "Sueldos",
                newName: "IX_Sueldos_TrabajoId");

            migrationBuilder.RenameColumn(
                name: "UserName",
                table: "Login",
                newName: "Email");

            migrationBuilder.RenameIndex(
                name: "IX_Cotizacion_MonedaId",
                table: "Cotizaciones",
                newName: "IX_Cotizaciones_MonedaId");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Usuarios",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Usuarios",
                table: "Usuarios",
                column: "Email");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Trabajos",
                table: "Trabajos",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Sueldos",
                table: "Sueldos",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Sindicatos",
                table: "Sindicatos",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Monedas",
                table: "Monedas",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Cotizaciones",
                table: "Cotizaciones",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Cotizaciones_Monedas_MonedaId",
                table: "Cotizaciones",
                column: "MonedaId",
                principalTable: "Monedas",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Sueldos_Trabajos_TrabajoId",
                table: "Sueldos",
                column: "TrabajoId",
                principalTable: "Trabajos",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Sueldos_Usuarios_UsuarioEmail",
                table: "Sueldos",
                column: "UsuarioEmail",
                principalTable: "Usuarios",
                principalColumn: "Email",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Trabajos_Sindicatos_SindicatoId",
                table: "Trabajos",
                column: "SindicatoId",
                principalTable: "Sindicatos",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Usuarios_Trabajos_TrabajoId",
                table: "Usuarios",
                column: "TrabajoId",
                principalTable: "Trabajos",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Cotizaciones_Monedas_MonedaId",
                table: "Cotizaciones");

            migrationBuilder.DropForeignKey(
                name: "FK_Sueldos_Trabajos_TrabajoId",
                table: "Sueldos");

            migrationBuilder.DropForeignKey(
                name: "FK_Sueldos_Usuarios_UsuarioEmail",
                table: "Sueldos");

            migrationBuilder.DropForeignKey(
                name: "FK_Trabajos_Sindicatos_SindicatoId",
                table: "Trabajos");

            migrationBuilder.DropForeignKey(
                name: "FK_Usuarios_Trabajos_TrabajoId",
                table: "Usuarios");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Usuarios",
                table: "Usuarios");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Trabajos",
                table: "Trabajos");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Sueldos",
                table: "Sueldos");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Sindicatos",
                table: "Sindicatos");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Monedas",
                table: "Monedas");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Cotizaciones",
                table: "Cotizaciones");

            migrationBuilder.RenameTable(
                name: "Usuarios",
                newName: "Usuario");

            migrationBuilder.RenameTable(
                name: "Trabajos",
                newName: "Trabajo");

            migrationBuilder.RenameTable(
                name: "Sueldos",
                newName: "Sueldo");

            migrationBuilder.RenameTable(
                name: "Sindicatos",
                newName: "Sindicato");

            migrationBuilder.RenameTable(
                name: "Monedas",
                newName: "Moneda");

            migrationBuilder.RenameTable(
                name: "Cotizaciones",
                newName: "Cotizacion");

            migrationBuilder.RenameIndex(
                name: "IX_Usuarios_TrabajoId",
                table: "Usuario",
                newName: "IX_Usuario_TrabajoId");

            migrationBuilder.RenameIndex(
                name: "IX_Trabajos_SindicatoId",
                table: "Trabajo",
                newName: "IX_Trabajo_SindicatoId");

            migrationBuilder.RenameColumn(
                name: "UsuarioEmail",
                table: "Sueldo",
                newName: "UsuarioUserName");

            migrationBuilder.RenameIndex(
                name: "IX_Sueldos_UsuarioEmail",
                table: "Sueldo",
                newName: "IX_Sueldo_UsuarioUserName");

            migrationBuilder.RenameIndex(
                name: "IX_Sueldos_TrabajoId",
                table: "Sueldo",
                newName: "IX_Sueldo_TrabajoId");

            migrationBuilder.RenameColumn(
                name: "Email",
                table: "Login",
                newName: "UserName");

            migrationBuilder.RenameIndex(
                name: "IX_Cotizaciones_MonedaId",
                table: "Cotizacion",
                newName: "IX_Cotizacion_MonedaId");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Usuario",
                nullable: true,
                oldClrType: typeof(string));

            migrationBuilder.AddColumn<string>(
                name: "UserName",
                table: "Usuario",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Usuario",
                table: "Usuario",
                column: "UserName");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Trabajo",
                table: "Trabajo",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Sueldo",
                table: "Sueldo",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Sindicato",
                table: "Sindicato",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Moneda",
                table: "Moneda",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Cotizacion",
                table: "Cotizacion",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Cotizacion_Moneda_MonedaId",
                table: "Cotizacion",
                column: "MonedaId",
                principalTable: "Moneda",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Sueldo_Trabajo_TrabajoId",
                table: "Sueldo",
                column: "TrabajoId",
                principalTable: "Trabajo",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Sueldo_Usuario_UsuarioUserName",
                table: "Sueldo",
                column: "UsuarioUserName",
                principalTable: "Usuario",
                principalColumn: "UserName",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo",
                column: "SindicatoId",
                principalTable: "Sindicato",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Usuario_Trabajo_TrabajoId",
                table: "Usuario",
                column: "TrabajoId",
                principalTable: "Trabajo",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
