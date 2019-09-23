using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using API.Models;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using API.Interfaces;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class MonedaController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly IMonedaRepository _dataRepository;

        public MonedaController(IMonedaRepository dataRepository, IConfiguration configuration)
        {
            _dataRepository = dataRepository;
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
            var data = _dataRepository.GetAll();

            return new ObjectResult(data);
        }
    }
}
