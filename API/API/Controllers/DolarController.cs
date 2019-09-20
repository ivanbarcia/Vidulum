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
    public class DolarController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public DolarController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Obtengo la cotizacion del dolar
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /GetCotizacionDolar
        ///     {
        ///        "Fecha": "20190830"
        ///     }
        /// </remarks>
        /// <returns>Obtengo cotizacion del dolar a la fecha</returns>
        [HttpGet]
        [Route("GetCotizacionDolar")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetCotizacionDolar([FromQuery]string Fecha)
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }
    }
}
