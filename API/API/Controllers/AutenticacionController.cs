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

namespace API.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class AutenticacionController : Controller
    {
        private readonly DataContext _context;
        private IConfiguration _configuration;

        public AutenticacionController(DataContext context, IConfiguration configuration)
        {
            _context = context;
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

            var post = "";//await _context.ClienteLogin.FromSql("EXEC ClienteLogin {0},{1}", UserName, Password).ToListAsync();

            //if (string.IsNullOrEmpty(post.FirstOrDefault().clie_alias))
            //{
            //    return StatusCode((int)HttpStatusCode.Unauthorized, post);
            //}

            var tokenString = GenerateJSONWebToken(UserName);

            var result = new { Login = post[0], Authentication = tokenString };

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

            _context.Database.ExecuteSqlCommand(string.Format("update dbo.ClientesLogin set refreshToken = '{1}' where Usuario = '{0}'", userInfo, refreshToken));

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
            _context.Database.ExecuteSqlCommand("set @result = (select refreshToken FROM dbo.ClientesLogin where Usuario = {0});", username, resultParameter); //retrieve the refresh token from a data store
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
    }
}