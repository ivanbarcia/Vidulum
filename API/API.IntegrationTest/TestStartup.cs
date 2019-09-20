using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using API.Context;

namespace API.IntegrationTest
{
    public class TestStartup : Startup
    {
        public TestStartup(IConfiguration configuration) : base(configuration)
        {
        }

        public override void ConfigureDatabase(IServiceCollection services)
        {
            // Replace default database connection with In-Memory database
            services.AddDbContext<DataContext>(options =>
                options.UseSqlServer(GetConnectionString(Configuration.GetConnectionString("DATABASE"))));
        }

    }
}
