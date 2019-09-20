using Newtonsoft.Json;
using NUnit.Framework;
using API.IntegrationTest;
using API.Models;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace SGMApi.IntegrationTest
{
    [TestFixture]
    public class MonedaApiTest : TestFixture
    {
        [Test]
        public async Task GetCotizacion()
        {
            // Act
            var response = await _client.GetAsync("api/Moneda/GetCotizacion?Moneda=USD&Fecha=20190920");

            // Arrange
            response.EnsureSuccessStatusCode();
            Assert.AreEqual(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadAsStringAsync();
            var json = JsonConvert.DeserializeObject<Moneda>(result);
        }
    }
}
