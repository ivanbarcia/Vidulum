using API.Context;
using API.Interfaces;
using API.Models;
using Microsoft.EntityFrameworkCore;

namespace API.Repositories
{
    public class SindicatoRepository : GenericRepository<Sindicato>, ISindicatoRepository
    {
        private readonly DataContext Entities;
        private readonly DbSet<Sindicato> Dbset;

        public SindicatoRepository(DataContext context)
            : base(context)
        {
            Entities = context;
            Dbset = context.Set<Sindicato>();
        }


    }
}
