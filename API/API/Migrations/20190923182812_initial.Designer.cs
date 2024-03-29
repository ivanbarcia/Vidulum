﻿// <auto-generated />
using API.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore.Storage.Internal;
using System;

namespace API.Migrations
{
    [DbContext(typeof(DataContext))]
    [Migration("20190923182812_initial")]
    partial class initial
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.0.3-rtm-10026")
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("API.Models.Cotizacion", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<DateTime>("Fecha");

                    b.Property<int?>("MonedaId");

                    b.Property<decimal>("Precio");

                    b.HasKey("Id");

                    b.HasIndex("MonedaId");

                    b.ToTable("Cotizacion");
                });

            modelBuilder.Entity("API.Models.ErrorDetails", b =>
                {
                    b.Property<int>("StatusCode")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Message");

                    b.HasKey("StatusCode");

                    b.ToTable("ErrorDetails");
                });

            modelBuilder.Entity("API.Models.Moneda", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Codigo");

                    b.Property<string>("Descripcion");

                    b.HasKey("Id");

                    b.ToTable("Moneda");
                });

            modelBuilder.Entity("API.Models.Sindicato", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Descripcion");

                    b.HasKey("Id");

                    b.ToTable("Sindicato");
                });

            modelBuilder.Entity("API.Models.Sueldo", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<decimal>("Bono");

                    b.Property<DateTime>("Fecha");

                    b.Property<decimal>("SueldoBruto");

                    b.Property<decimal>("SueldoNeto");

                    b.Property<int?>("TrabajoId");

                    b.Property<string>("UsuarioUserName");

                    b.HasKey("Id");

                    b.HasIndex("TrabajoId");

                    b.HasIndex("UsuarioUserName");

                    b.ToTable("Sueldo");
                });

            modelBuilder.Entity("API.Models.Trabajo", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("RazonSocial");

                    b.Property<int>("SindicatoId");

                    b.HasKey("Id");

                    b.HasIndex("SindicatoId");

                    b.ToTable("Trabajo");
                });

            modelBuilder.Entity("API.Models.Usuario", b =>
                {
                    b.Property<string>("UserName")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Email");

                    b.Property<string>("Password");

                    b.Property<int?>("TrabajoId");

                    b.HasKey("UserName");

                    b.HasIndex("TrabajoId");

                    b.ToTable("Usuario");
                });

            modelBuilder.Entity("API.Models.Cotizacion", b =>
                {
                    b.HasOne("API.Models.Moneda", "Moneda")
                        .WithMany()
                        .HasForeignKey("MonedaId");
                });

            modelBuilder.Entity("API.Models.Sueldo", b =>
                {
                    b.HasOne("API.Models.Trabajo", "Trabajo")
                        .WithMany()
                        .HasForeignKey("TrabajoId");

                    b.HasOne("API.Models.Usuario", "Usuario")
                        .WithMany()
                        .HasForeignKey("UsuarioUserName");
                });

            modelBuilder.Entity("API.Models.Trabajo", b =>
                {
                    b.HasOne("API.Models.Sindicato", "Sindicato")
                        .WithMany()
                        .HasForeignKey("SindicatoId")
                        .OnDelete(DeleteBehavior.Cascade);
                });

            modelBuilder.Entity("API.Models.Usuario", b =>
                {
                    b.HasOne("API.Models.Trabajo", "Trabajo")
                        .WithMany()
                        .HasForeignKey("TrabajoId");
                });
#pragma warning restore 612, 618
        }
    }
}
