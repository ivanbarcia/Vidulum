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
    public class TrabajoController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public TrabajoController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Cargo el sueldo recibido
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /SetSueldo
        ///     {
        ///        "DNI": "32991894",
        ///        "Fecha": "20190830",
        ///        "SueldoNeto": "20000",
        ///        "SueldoBruto": "40000"
        ///     }
        /// </remarks>
        [HttpPost]
        [Route("SetSueldo")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> SetSueldo([FromQuery]string DNI, [FromQuery]string Fecha, [FromQuery]decimal SueldoNeto, [FromQuery]decimal SueldoBruto)
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }

        /// <summary>
        /// Cargo el bono recibido
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /SetBono
        ///     {
        ///        "DNI": "32991894",
        ///        "Fecha": "20190830",
        ///        "Importe": "20000"
        ///     }
        /// </remarks>
        [HttpPost]
        [Route("SetBono")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> SetBono([FromQuery]string DNI, [FromQuery]string Fecha, [FromQuery]decimal Importe)
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }
    }
}
