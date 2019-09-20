using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.Extensions.Configuration;
using Swashbuckle.AspNetCore.Swagger;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace API.Infrastructure
{
    public class AddRequiredHeaderParameter : IOperationFilter
    {
        public IConfiguration Configuration { get; set; }

        public AddRequiredHeaderParameter(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public void Apply(Operation operation, OperationFilterContext context)
        {
            if (operation.Parameters == null)
                operation.Parameters = new List<IParameter>();

            operation.Parameters.Add(new NonBodyParameter
            {
                Name = "X-Build-Version",
                In = "header",
                Type = "string",
                Required = false,
                Default = Configuration["Environment:Ambiente"]
            });
        }
    }
}
