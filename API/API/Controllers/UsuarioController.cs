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
    public class UsuarioController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly IUsuarioRepository _dataRepository;

        public UsuarioController(IUsuarioRepository dataRepository, IConfiguration configuration)
        {
            _dataRepository = dataRepository;
            _configuration = configuration;
        }

        /// <summary>
        /// Alta de Usuario
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /AddUsuario
        ///     {
        ///     }
        /// </remarks>
        /// <returns>Usuario se da de alta al sistema</returns>
        [HttpGet]
        [Route("AddUsuario")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> AddUsuario(Usuario data)
        {
            _dataRepository.Insert(data);
            
            return new ObjectResult(data);
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
            var data = _dataRepository.GetAll();

            return new ObjectResult(data);
        }
    }
}
