using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Vidulum.Context;
using Vidulum.Infrastructure;
using Vidulum.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Threading.Tasks;

namespace ApiSGMTrade.Controllers
{
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class EspecieController : Controller
    {
        private readonly DataContext _context;

        public EspecieController(DataContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Obtengo todas las especies
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetEspecies
        ///
        /// </remarks>
        /// <returns>Especies</returns>
        [AllowAnonymous]
        [HttpGet]
        [Route("GetEspecies")]
        [ETagFilter(200)]
        [ApiExplorerSettings(GroupName = "v2")]
        [ProducesResponseType(typeof(IEnumerable<Especie>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetEspecies()
        {
            var post = await _context.Especie.FromSql("EXEC GetEspecies").ToListAsync();

            return new ObjectResult(post);
        }

        /// <summary>
        /// Obtengo las especies para el banner de cotizaciones
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetStockSymbols
        ///
        /// </remarks>
        /// <returns>Especies</returns>
        [AllowAnonymous]
        [HttpGet]
        [Route("GetStockSymbols")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<EspeciesBanner>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetStockSymbols(string fecha = null)
        {
            var post = await _context.EspeciesBanner.FromSql("EXEC ObtenerEspeciesBanner {0}", fecha).ToListAsync();

            return new ObjectResult(post);
        }

        /// <summary>
        /// Obtengo la ultima cotizacion de la especie
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /ObtenerUltimoPrecio
        ///     {
        ///        "Especie": "02B"
        ///     }
        /// </remarks>
        /// <returns>Ultima cotizacion</returns>
        [AllowAnonymous]
        [HttpGet]
        [Route("ObtenerUltimoPrecio")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<PrecioEspecie>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> ObtenerUltimoPrecio(string Especie)
        {
            var post = await _context.PrecioEspecie.FromSql("EXEC ObtenerUltimoPrecio {0}", Especie).ToListAsync();

            return new ObjectResult(post);
        }

        /// <summary>
        /// Obtengo la cotizacion del dolar
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetCotizacionDolar
        ///     {
        ///        "Fecha": "20190130"
        ///     }
        /// </remarks>
        /// <returns>Cotizacion dolar</returns>
        [AllowAnonymous]
        [HttpGet]
        [Route("GetCotizacionDolar")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<PrecioEspecie>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetCotizacionDolar(GetCotizacionDolar parameters)
        {
            var post = await _context.PrecioEspecie.FromSql("EXEC spGetCotizacionDolar {0}", parameters.Fecha).ToListAsync();

            return new ObjectResult(post);
        }

        /// <summary>
        /// Obtengo los titulos disponibles
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetTitulosDisponibles
        ///     {
        ///     }
        /// </remarks>
        /// <returns>Listado de titulos disponibles</returns>
        [AllowAnonymous]
        [HttpGet]
        [Route("GetTitulosDisponibles")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<Titulo>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetTitulosDisponibles()
        {
            var post = await _context.Titulo.FromSql("EXEC GetTitulosDisponibles").ToListAsync();

            return new ObjectResult(post);
        }


        /// <summary>
        /// Obtengo los datos de la composicion de la cartera
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetComposicionCartera
        ///     {
        ///         "FechaDesde": "20190101",
        ///         "FechaHasta": "20190530",
        ///         "Cuenta": "103",
        ///         "Especie": "FMGA01"
        ///     }
        /// </remarks>
        /// <returns>Listado de datos de la composicion de la cartera</returns>
        [HttpGet]
        [Route("GetComposicionCartera")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<ComposicionCartera>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetComposicionCartera(GetComposicionCartera parameters)
        {
            using (var con = (SqlConnection)_context.Database.GetDbConnection())
            {
                using (var cmd = new SqlCommand("cuenta_custodia_movim_detalle_fci_Imprimir", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@_fdesde", SqlDbType.VarChar).Value = parameters.FechaDesde;
                    cmd.Parameters.Add("@_fhasta", SqlDbType.VarChar).Value = parameters.FechaHasta;
                    cmd.Parameters.Add("@_ccus_id", SqlDbType.Int).Value = parameters.Cuenta;
                    cmd.Parameters.Add("@_incluir_bloqueos", SqlDbType.Int).Value = 1;
                    cmd.Parameters.Add("@_socger", SqlDbType.VarChar).Value = 0;
                    cmd.Parameters.Add("@_espe_codigoFiltro", SqlDbType.VarChar).Value = parameters.Especie;
                    con.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    int i = 0;
                    var datos = new List<ComposicionCartera>();

                    do
                    {
                        while (reader.Read())
                        {
                            switch (i)
                            {
                                //Movimientos
                                case 3:
                                    do
                                    {
                                        datos.Add(MapearDatosComposicionCartera(reader));
                                    } while (reader.Read());
                                    break;
                                default:
                                    break;
                            }
                        }

                        i++;

                    } while (reader.NextResult());

                    return new ObjectResult(datos);
                }
            }
        }

        private static ComposicionCartera MapearDatosComposicionCartera(IDataRecord reader)
        {
            var dato = new ComposicionCartera()
            {
                espe_codigo = reader["espe_codigo"].ToString(),
                espe_descrip = reader["espe_descrip"].ToString(),
                espe_riesgo = reader["espe_riesgo"].ToString(),
                total = Convert.ToDecimal(reader["total"]),
                porcentaje = Convert.ToDecimal(reader["porcentaje"]),
                emisor = reader["emisor"].ToString(),
                especie = Convert.ToInt32(reader["especie"].ToString())
            };

            return dato;
        }

        /// <summary>
        /// Obtengo los titulos disponibles
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /GetComposicionCartera
        ///     {
        ///         "FechaDesde": "20190101",
        ///         "FechaHasta": "20190530",
        ///         "Cuenta": "103",
        ///         "Especie": "FMGA01"
        ///     }
        /// </remarks>
        /// <returns>Listado de titulos disponibles</returns>
        [HttpGet]
        [Route("GetComposicionCarteraGrafico")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<ComposicionCarteraGrafico>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> GetComposicionCarteraGrafico(GetComposicionCartera parameters)
        {
            using (var con = (SqlConnection)_context.Database.GetDbConnection())
            {
                using (var cmd = new SqlCommand("cuenta_custodia_movim_detalle_fci_Imprimir", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@_fdesde", SqlDbType.VarChar).Value = parameters.FechaDesde;
                    cmd.Parameters.Add("@_fhasta", SqlDbType.VarChar).Value = parameters.FechaHasta;
                    cmd.Parameters.Add("@_ccus_id", SqlDbType.Int).Value = parameters.Cuenta;
                    cmd.Parameters.Add("@_incluir_bloqueos", SqlDbType.Int).Value = 1;
                    cmd.Parameters.Add("@_socger", SqlDbType.VarChar).Value = 0;
                    cmd.Parameters.Add("@_espe_codigoFiltro", SqlDbType.VarChar).Value = parameters.Especie;
                    con.Open();

                    SqlDataReader reader = cmd.ExecuteReader();

                    int i = 0;
                    var datos = new List<ComposicionCarteraGrafico>();

                    do
                    {
                        while (reader.Read())
                        {
                            switch (i)
                            {
                                //Movimientos
                                case 5:
                                    do
                                    {
                                        datos.Add(MapearDatosComposicionCarteraGrafico(reader));
                                    } while (reader.Read());
                                    break;
                                default:
                                    break;
                            }
                        }

                        i++;

                    } while (reader.NextResult());

                    return new ObjectResult(datos);
                }
            }
        }

        private static ComposicionCarteraGrafico MapearDatosComposicionCarteraGrafico(IDataRecord reader)
        {
            var dato = new ComposicionCarteraGrafico()
            {
                espe_riesgo = reader["espe_riesgo"].ToString(),
                total = Convert.ToDecimal(reader["total"])
            };

            return dato;
        }
    }
}
