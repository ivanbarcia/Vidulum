using API.Context;
using API.Interfaces;
using API.Models;
using Microsoft.EntityFrameworkCore;

namespace API.Repositories
{
    public class TrabajoRepository : GenericRepository<Trabajo>, ITrabajoRepository
    {
        private readonly DataContext Entities;
        private readonly DbSet<Trabajo> Dbset;

        public TrabajoRepository(DataContext context)
            : base(context)
        {
            Entities = context;
            Dbset = context.Set<Trabajo>();
        }


    }
}
