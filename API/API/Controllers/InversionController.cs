using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class InversionController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public InversionController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

    }
}
