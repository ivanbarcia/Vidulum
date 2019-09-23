using API.Context;
using API.Interfaces;
using API.Models;
using Microsoft.EntityFrameworkCore;

namespace API.Repositories
{
    public class MonedaRepository : GenericRepository<Moneda>, IMonedaRepository
    {
        private readonly DataContext Entities;
        private readonly DbSet<Moneda> Dbset;

        public MonedaRepository(DataContext context)
            : base(context)
        {
            Entities = context;
            Dbset = context.Set<Moneda>();
        }


    }
}
