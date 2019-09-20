using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Trabajo
    {
        [Key]
        public int Id { get; set; }

        public string RazonSocial { get; set; }
        public int SindicatoId { get; set; }

        public virtual Sindicato Sindicato { get; set; }
    }
}

