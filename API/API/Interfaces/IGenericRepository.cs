using System;
using System.Collections.Generic;
using System.Linq.Expressions;

namespace API.Interfaces
{
    public interface IGenericRepository<T> where T : class
    {
        T Find(int id);
        IEnumerable<T> GetAll();
        IEnumerable<T> FindBy(Expression<Func<T, bool>> predicate);
        void Insert(T entity);
        void Delete(T entity);
        void Update(T entity);
        void Inactive(T entity);
        bool Any(Expression<Func<T, bool>> predicate);
    }
}
