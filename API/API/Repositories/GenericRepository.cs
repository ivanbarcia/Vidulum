using API.Context;
using API.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;

namespace API.Repositories
{
    public abstract class GenericRepository<T> : IGenericRepository<T> where T : class
    {
        internal readonly DataContext Context;
        internal readonly DbSet<T> DbSet;

        protected GenericRepository(DataContext context)
        {
            this.Context = context;
            this.DbSet = context.Set<T>();
        }

        public T Find(int id)
        {
            return DbSet.Find(id);
        }

        public IEnumerable<T> GetAll()
        {
            return DbSet.AsEnumerable<T>();
        }

        public virtual IEnumerable<T> FindBy(Expression<Func<T, bool>> predicate)
        {
            var query = DbSet.Where(predicate).AsEnumerable();
            return query;
        }

        public virtual void Insert(T entity)
        {
            DbSet.Add(entity);
            Context.SaveChanges();
        }

        public virtual void Delete(T entity)
        {
            DbSet.Attach(entity);
            DbSet.Remove(entity);
            Context.SaveChanges();
        }

        public virtual void Inactive(T entity)
        {
            DbSet.Attach(entity);
            Context.Entry(entity).State = EntityState.Modified;
            Context.SaveChanges();
        }

        public virtual void Update(T entity)
        {
            DbSet.Attach(entity);
            Context.Entry(entity).State = EntityState.Modified;
            Context.SaveChanges();
        }

        public virtual bool Any(Expression<Func<T, bool>> predicate)
        {
            return DbSet.Any(predicate);
        }
    }
}