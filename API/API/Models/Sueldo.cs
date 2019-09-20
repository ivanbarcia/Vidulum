using System;
using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Sueldo
    {
        [Key]
        public int Id { get; set; }
    
        public Trabajo Trabajo { get; set; }
        public string NroDocumento { get; set; }
        public DateTime Fecha { get; set; }
        public decimal SueldoBruto { get; set; }
        public decimal SueldoNeto { get; set; }
        public decimal Bono { get; set; }
    }
}

