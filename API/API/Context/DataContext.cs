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

        public DbSet<ErrorDetails> ErrorDetails { get; set; }
        
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                IConfigurationRoot configuration = new ConfigurationBuilder().SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
                .AddJsonFile("appsettings.json").Build();

                optionsBuilder.UseSqlServer(configuration.GetConnectionString("DATABASE"));
            }
        }
    }
}
