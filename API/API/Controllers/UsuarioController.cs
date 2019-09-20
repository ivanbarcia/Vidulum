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
    public class UsuarioController : Controller
    {
        private readonly DataContext _context;
        private readonly IConfiguration _configuration;

        public UsuarioController(DataContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        /// <summary>
        /// Obtengo dinero hasta el momento con su proyeccion a futuro
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /GetPosicionTotal
        ///     {
        ///        "DNI": "329918954",
        ///        "Fecha": "20190910"
        ///     }
        /// </remarks>
        /// <returns>Obtengo la posicion total de mis datos ingresados</returns>
        [HttpGet]
        [Route("GetPosicionTotal")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetPosicionTotal([FromQuery]string DNI, [FromQuery]string Fecha)
        {
            //var post = await _context.PaqueteCuentas.FromSql("EXEC paquetes_custodias_R {0}", cliente).AsNoTracking().ToListAsync();

            return new ObjectResult(""/*post*/);
        }
    }
}
