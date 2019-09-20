using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using API.Context;
using API.Infrastructure;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace API.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    [ApiExplorerSettings(GroupName = "v1")]
    public class LoginController : Controller
    {
        private readonly DataContext _context;
        private IConfiguration _configuration;

        public LoginController(DataContext context, IConfiguration configuration)
        {
            _context = context;
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
        public async Task<IActionResult> AddUsuario()
        {
            return new ObjectResult("");
        }

        /// <summary>
        /// Obtengo los requisitos para el cambio de contraseña
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     GET /ChangePassword
        ///     {
        ///     }
        /// </remarks>
        /// <returns>Parametros cambio contraseña</returns>
        [HttpGet]
        [Route("ChangePassword")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> ChangePassword()
        {
            return new ObjectResult("");
        }
        
        /// <summary>
        /// Realizo el cambio de contraseña
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /UpdatePassword
        ///     {
        ///        "Cliente": "80009515-4",
        ///        "NuevaPassword": "Agosto$2019",
        ///        "RepeticionPassword": "Agosto$2019"
        ///     }
        /// </remarks>
        /// <returns>La respuesta contiene un valor numerico (0 en caso de exito) y ademas un mensaje en caso de error</returns>
        [HttpGet]
        [Route("UpdatePassword")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> UpdatePassword()
        {
            return new ObjectResult("");
        }

        private string Md5Encryption(string dataToEncrypt)
        {
            MD5 md5Hash = MD5.Create();
            byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(dataToEncrypt));
            StringBuilder sBuilder = new StringBuilder();

            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }

            return sBuilder.ToString();
        }

        private bool ValidatePassword(string password)
        {
            int minLength = 0; //_context.ValorParametro.FromSql("EXEC ReadParamValue {0}", "TAMMIN").FirstOrDefault().Value;
            int maxLength = 0; //_context.ValorParametro.FromSql("EXEC ReadParamValue {0}", "TAMMAX").FirstOrDefault().Value;

            bool meetsLengthRequirements = (password.Length >= minLength) & (password.Length <= maxLength);
            int numberCounter = 0;
            int upperCaseCounter = 0;
            int symbolCounter = 0;

            if (meetsLengthRequirements)
            {
                foreach (char c in password)
                {
                    if (char.IsUpper(c))
                    {
                        upperCaseCounter++;
                    }
                    else if (char.IsSymbol(c) || char.IsPunctuation(c)) symbolCounter++;
                    else if (char.IsDigit(c))
                    {
                        numberCounter++;
                    }
                }
            }

            bool isValid = meetsLengthRequirements
                        && upperCaseCounter >= 0 //_context.ValorParametro.FromSql("EXEC ReadParamValue {0}", "MINMAY").FirstOrDefault().Value
                        && symbolCounter >= 0 //_context.ValorParametro.FromSql("EXEC ReadParamValue {0}", "MINCAR").FirstOrDefault().Value
                        && numberCounter >= 0 //_context.ValorParametro.FromSql("EXEC ReadParamValue {0}", "MINNUM").FirstOrDefault().Value
                        ;

            return isValid;
        }
    }
}