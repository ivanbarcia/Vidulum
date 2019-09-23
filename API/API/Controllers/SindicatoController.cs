using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using API.Models;
using API.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class SindicatoController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ISindicatoRepository _dataRepository;

        public SindicatoController(ISindicatoRepository dataRepository, IConfiguration configuration)
        {
            _dataRepository = dataRepository;
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
        [AllowAnonymous]
        [HttpGet]
        [Route("GetSindicatos")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetSindicatos()
        {
            var data = _dataRepository.GetAll();

            return new ObjectResult(data);
        }
    }
}
