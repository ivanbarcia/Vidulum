using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using API.Models;
using System;

namespace API.Context
{
    public class DataContext : DbContext
    {
        public DataContext()
        {
        }

        public DataContext(DbContextOptions<DataContext> options)
            : base(options)
        {
        }

        public DbSet<Cotizacion> Cotizacion { get; set; }
        public DbSet<ErrorDetails> ErrorDetails { get; set; }
        public DbSet<Moneda> Moneda { get; set; }
        public DbSet<Sindicato> Sindicato { get; set; }
        public DbSet<Sueldo> Sueldo { get; set; }
        public DbSet<Trabajo> Trabajo { get; set; }
        public DbSet<Usuario> Usuario { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                IConfigurationRoot configuration = new ConfigurationBuilder().SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
                .AddJsonFile("appsettings.json").Build();

                optionsBuilder.UseSqlServer(configuration.GetConnectionString("DATABASE"));
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            //modelBuilder.Entity<Moneda>()
            //    .HasData(new Moneda
            //    {
            //        Id = 1,
            //        Codigo = "USD",
            //        Descripcion = "Dolares"
            //    }, new Moneda
            //    {
            //        Id = 2,
            //        Codigo = "ARS",
            //        Descripcion = "Pesos Argentinos"
            //    });
        }
    }
}
