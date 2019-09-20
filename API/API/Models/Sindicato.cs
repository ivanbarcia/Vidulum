using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Sindicato
    {
        [Key]
        public int Id { get; set; }

        public string Descripcion { get; set; }
    }
}

