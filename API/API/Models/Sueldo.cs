using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace API.Models
{
    [Table("Sueldos")]
    public class Sueldo
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
    
        public Trabajo Trabajo { get; set; }
        public Usuario Usuario { get; set; }
        public DateTime Fecha { get; set; }
        public decimal SueldoBruto { get; set; }
        public decimal SueldoNeto { get; set; }
        public decimal Bono { get; set; }
    }
}

