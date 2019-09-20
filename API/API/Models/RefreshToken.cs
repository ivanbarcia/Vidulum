using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class RefreshToken
    {
        [Key]
        public string token { get; set; }
        public string refreshToken { get; set; }
    }
}
