using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Usuario
    {
        [Key]
        public int NroDocumento { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Email { get; set; }
        public int TrabajoId { get; set; }

        public string UserName { get; set; }
        public string Password { get; set; }

        public virtual Trabajo Trabajo { get; set; }
    }
}

