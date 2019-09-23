using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Swashbuckle.AspNetCore.Swagger;
using System.Collections.Generic;

namespace API.Infrastructure
{
    public static class SwaggerServiceExtensions
    {
        public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
        {
            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info
                {
                    Version = "v1",
                    Title = "API Trade10",
                    Description = "Web API de SurecompSGM",
                    TermsOfService = "None",
                    Contact = new Contact(){ Name = "Ivan Barcia", Email = "ivan.barcia@surecomp.com", Url = "" },
                    License = new License(){ Name = "", Url = "" }
                });

                c.AddSecurityDefinition("Bearer", new ApiKeyScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                    Name = "Authorization",
                    In = "header",
                    Type = "apiKey"
                });

                // Swagger 2.+ support
                c.AddSecurityRequirement(
                    new Dictionary<string, IEnumerable<string>>
                    {
                        {
                            "Bearer", new string[] { }
                        },
                    }
                );

                c.IncludeXmlComments(System.IO.Path.Combine(System.AppContext.BaseDirectory, "API.xml"));
                c.DescribeAllEnumsAsStrings();
                c.EnableAnnotations();

                c.OperationFilter<AddRequiredHeaderParameter>();
            });
            
            return services;
        }

        public static IApplicationBuilder UseSwaggerDocumentation(this IApplicationBuilder app)
        {
            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.), 
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "API Trade10");

                c.RoutePrefix = string.Empty;
                c.InjectStylesheet("/swagger/ui/theme-feeling-blue.css");
                c.DefaultModelExpandDepth(0);
                c.DefaultModelsExpandDepth(-1);
            });

            return app;
        }
    }
}