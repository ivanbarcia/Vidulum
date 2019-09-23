using API.Context;
using API.Interfaces;
using API.Models;
using Microsoft.EntityFrameworkCore;

namespace API.Repositories
{
    public class UsuarioRepository : GenericRepository<Usuario>, IUsuarioRepository
    {
        private readonly DataContext Entities;
        private readonly DbSet<Usuario> Dbset;

        public UsuarioRepository(DataContext context)
            : base(context)
        {
            Entities = context;
            Dbset = context.Set<Usuario>();
        }


    }
}
