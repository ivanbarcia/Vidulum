using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using API.Models;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class SindicatoController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public SindicatoController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Obtengo lista de sindicatos
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /GetSindicatos
        ///     {
        ///
        ///     }
        /// </remarks>
        /// <returns>Obtengo cotizacion del dolar a la fecha</returns>
        [HttpGet]
        [Route("GetSindicatos")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetSindicatos()
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }
    }
}
