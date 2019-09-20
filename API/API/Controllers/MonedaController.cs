using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using API.Models;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class MonedaController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public MonedaController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Obtengo cotizacion
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /GetCotizacion
        ///     {
        ///        "Moneda": "USD",
        ///        "Fecha": "20190830"
        ///     }
        /// </remarks>
        /// <returns>Obtengo cotizacion del dolar a la fecha</returns>
        [HttpGet]
        [Route("GetCotizacion")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<Moneda>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetCotizacion([FromQuery]string Moneda, [FromQuery]string Fecha)
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }
    }
}
