using System;
using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Moneda
    {
        [Key]
        public int Id { get; set; }

        public string Codigo { get; set; }
        public string Descripcion { get; set; }
        public DateTime Fecha { get; set; }
        public double Cotizacion { get; set; }        
    }
}

