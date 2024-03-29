﻿using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using API.Models;
using API.Interfaces;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class TrabajoController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ITrabajoRepository _dataRepository;

        public TrabajoController(ITrabajoRepository dataRepository, IConfiguration configuration)
        {
            _dataRepository = dataRepository;
            _configuration = configuration;
        }

        /// <summary>
        /// Cargo el trabajo
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /AddTrabajo
        ///     {
        ///        "RazonSocial": "Job S.A.",
        ///        "SueldoBruto": "20000",
        ///        "SueldoNeto": "10000",
        ///        "SindicatoId": "1",
        ///        "Bono":"0"
        ///     }
        /// </remarks>
        [HttpPost]
        [Route("AddTrabajo")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<Trabajo>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> SetSueldo(Trabajo datosTrabajo)
        {
            _dataRepository.Insert(datosTrabajo);

            return new ObjectResult(datosTrabajo);
        }

        /// <summary>
        /// Cargo el sueldo recibido
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /AddSueldo
        ///     {
        ///        "DNI": "32991894",
        ///        "Fecha": "20190830",
        ///        "SueldoNeto": "20000",
        ///        "SueldoBruto": "40000"
        ///     }
        /// </remarks>
        [HttpPut]
        [Route("AddSueldo")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> AddSueldo(Sueldo datosSueldo)
        {
            //_dataRepository.Insert(datosSueldo);

            //return new ObjectResult(datosSueldo);
            return new ObjectResult("");
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
        [HttpPut]
        [Route("UpdateBono")]
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
