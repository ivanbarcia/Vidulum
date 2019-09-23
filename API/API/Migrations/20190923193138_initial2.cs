using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace API.Migrations
{
    public partial class initial2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo");

            migrationBuilder.DropColumn(
                name: "Password",
                table: "Usuario");

            migrationBuilder.AlterColumn<int>(
                name: "SindicatoId",
                table: "Trabajo",
                nullable: true,
                oldClrType: typeof(int));

            migrationBuilder.CreateTable(
                name: "Login",
                columns: table => new
                {
                    UserName = table.Column<string>(nullable: false),
                    Password = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Login", x => x.UserName);
                });

            migrationBuilder.AddForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo",
                column: "SindicatoId",
                principalTable: "Sindicato",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo");

            migrationBuilder.DropTable(
                name: "Login");

            migrationBuilder.AddColumn<string>(
                name: "Password",
                table: "Usuario",
                nullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "SindicatoId",
                table: "Trabajo",
                nullable: false,
                oldClrType: typeof(int),
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Trabajo_Sindicato_SindicatoId",
                table: "Trabajo",
                column: "SindicatoId",
                principalTable: "Sindicato",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
