using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.PlatformAbstractions;
using Microsoft.IdentityModel.Tokens;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Net.Http;
using System.Text;

namespace API.IntegrationTest
{
    public class TestFixture : IDisposable
    {
        protected readonly TestServer _server;
        protected readonly HttpClient _client;

        public TestFixture()
        {
            var integrationTestsPath = PlatformServices.Default.Application.ApplicationBasePath;
            var applicationPath = Path.GetFullPath(Path.Combine(integrationTestsPath, "../../../../API"));

            _server = new TestServer(WebHost.CreateDefaultBuilder()
                .UseStartup<TestStartup>()
                .UseContentRoot(applicationPath)
                .UseEnvironment("Development"));
            _client = _server.CreateClient();

            // FAKE JWT TOKEN
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("ThisismySecretKey"));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: "Test.com",
                audience: "Test.com",
                notBefore: DateTime.UtcNow,
                expires: DateTime.UtcNow.AddMinutes(Convert.ToInt32(5)),
                signingCredentials: credentials);

            _client.DefaultRequestHeaders.Add("Authorization", "Bearer " + new JwtSecurityTokenHandler().WriteToken(token));
        }

        public void Dispose()
        {
            _client.Dispose();
            _server.Dispose();
        }
    }
}
