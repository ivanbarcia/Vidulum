using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using API.Context;
using API.Infrastructure;
using API.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.SqlClient;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using API.Interfaces;

namespace API.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class AutenticacionController : Controller
    {
        private IConfiguration _configuration;
        private readonly IUsuarioRepository _dataRepository;

        public AutenticacionController(IUsuarioRepository dataRepository, IConfiguration configuration)
        {
            _dataRepository = dataRepository;
            _configuration = configuration;
        }

        /// <summary>
        /// Verifico datos de autenticacion del usuario
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /Login
        ///     {
        ///        "UserName": "80009515-4",
        ///        "Password": "Noviembre$2018"
        ///     }
        /// </remarks>
        /// <returns>Obtengo Datos del Cliente para poder utilizar en otras consultas como parametro</returns>
        [AllowAnonymous]
        [HttpPost]
        [Route("Login")]
        [ETagFilter(200)]
        [ProducesResponseType(typeof(IEnumerable<string>), (int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public async Task<IActionResult> Login([Required]string UserName, [Required]string Password, bool Encrypt = true)
        {
            if (Encrypt)
            {
                Password = new Services.Encriptacion().Md5Encryption(Password);
            }

            var post = _dataRepository.FindBy(x => x.Email == UserName && x.Password == Password);

            if (string.IsNullOrEmpty(post.FirstOrDefault().Email))
            {
                return StatusCode((int)HttpStatusCode.Unauthorized, post);
            }

            var tokenString = GenerateJSONWebToken(UserName);

            var result = new { Login = post, Authentication = tokenString };

            return new ObjectResult(result);
        }

        private object GenerateJSONWebToken(string userInfo)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Issuer"],
                claims: new[]
                {
                    // You can add more claims if you want
                    new Claim(JwtRegisteredClaimNames.Sub, userInfo),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                },
                notBefore: DateTime.UtcNow,
                expires: DateTime.UtcNow.AddMinutes(Convert.ToInt32(_configuration["Jwt:ExpiryMinutes"])),
                signingCredentials: credentials);

            var refreshToken = GenerateRefreshToken();

            //_dataRepository.Database.ExecuteSqlCommand(string.Format("update dbo.ClientesLogin set refreshToken = '{1}' where Usuario = '{0}'", userInfo, refreshToken));

            return new
            {
                token = new JwtSecurityTokenHandler().WriteToken(token),
                expires_in = Convert.ToInt32(_configuration["Jwt:ExpiryMinutes"]),
                refresh_token = refreshToken
            };

            //return new JwtSecurityTokenHandler().WriteToken(token);
        }
        
        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(randomNumber);
                return Convert.ToBase64String(randomNumber);
            }
        }

        /// <summary>
        /// Actualizo token de autorizacion
        /// </summary>
        /// <remarks>
        /// Sample request:
        ///
        ///     POST /Refresh
        ///     {
        ///        "token": "",
        ///        "refreshToken": ""
        ///     }
        /// </remarks>
        /// <returns>Token actualizado de autorizacion</returns>
        [AllowAnonymous]
        [HttpPost]
        [Route("RefreshToken")]
        [ETagFilter(200)]
        [ProducesResponseType((int)HttpStatusCode.OK)]
        [ProducesResponseType(typeof(ErrorDetails), (int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        public IActionResult RefreshToken([FromBody]RefreshToken parameters)
        {
            var principal = GetPrincipalFromExpiredToken(parameters.token);
            var username = principal.Identity.Name;

            var resultParameter = new SqlParameter("@result", SqlDbType.VarChar, 200);
            resultParameter.Direction = ParameterDirection.Output;
            //_context.Database.ExecuteSqlCommand("set @result = (select refreshToken FROM dbo.ClientesLogin where Usuario = {0});", username, resultParameter); //retrieve the refresh token from a data store
            var savedRefreshToken = resultParameter.Value.ToString();

            if (savedRefreshToken != parameters.refreshToken)
                throw new SecurityTokenException("Invalid refresh token");

            var newJwtToken = GenerateJSONWebToken(username);            

            return new ObjectResult(newJwtToken);
        }

        private ClaimsPrincipal GetPrincipalFromExpiredToken(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = false,
                ValidateAudience = false, //you might want to validate the audience and issuer depending on your use case
                ValidateLifetime = false, //here we are saying that we don't care about the token's expiration date
                ValidateIssuerSigningKey = true,
                ValidIssuer = _configuration["Jwt:Issuer"],
                ValidAudience = _configuration["Jwt:Issuer"],
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"])),
                NameClaimType = ClaimTypes.NameIdentifier,
                ClockSkew = TimeSpan.Zero //the default for this setting is 5 minutes
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            SecurityToken securityToken;
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out securityToken);
            var jwtSecurityToken = securityToken as JwtSecurityToken;

            if (jwtSecurityToken == null || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                throw new SecurityTokenException("Invalid token");

            return principal;
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
        public async Task<IActionResult> ChangePassword(Usuario datos)
        {
            _dataRepository.Update(datos);

            return new ObjectResult(datos);
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
        public async Task<IActionResult> UpdatePassword(Usuario datos)
        {
            _dataRepository.Update(datos);

            return new ObjectResult(datos);
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