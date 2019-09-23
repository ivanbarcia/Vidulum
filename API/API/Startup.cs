using System;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.AspNetCore.Mvc.Versioning;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using NLog.Extensions.Logging;
using NLog.Web;
using API.Context;
using API.Infrastructure;
using API.Models;
using static API.Services.Encriptacion;
using API.Interfaces;
using API.Repositories;

namespace API
{
    public class Startup
    {
        public IConfiguration Configuration { get; set; }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public string GetConnectionString(string connectionString)
        {
            if (!string.IsNullOrEmpty(Configuration["Encriptacion:Activar"]))
            {
                if (Configuration["Encriptacion:Activar"] == "ON")
                {
                    var csb = connectionString.Split(";");

                    var server = RijndaelSimple.Desencriptar(csb[0].Split("server=")[1]); //server
                    var database = RijndaelSimple.Desencriptar(csb[1].Split("database=")[1]); //database
                    var user = RijndaelSimple.Desencriptar(csb[2].Split("User ID=")[1]); //user
                    var password = RijndaelSimple.Desencriptar(csb[3].Split("password=")[1]); //password

                    connectionString = string.Format("server={0};database={1};User ID={2};password={3};", server, database, user, password);
                }
            }

            return connectionString;
        }

        public virtual void ConfigureDatabase(IServiceCollection services)
        {
            services.AddDbContext<DataContext>(options =>
                options.UseSqlServer(GetConnectionString(Configuration.GetConnectionString("DATABASE"))));
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            ConfigureDatabase(services);

            services
                .AddAuthentication(options =>
                 {
                     options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                     options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                 })
                .AddCookie(cfg => cfg.SlidingExpiration = true)
                .AddJwtBearer(options =>
                {
                    options.SaveToken = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true, 
                        ValidateAudience = true, //you might want to validate the audience and issuer depending on your use case
                        ValidateLifetime = true, //here we are saying that we don't care about the token's expiration date
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = Configuration["Jwt:Issuer"],
                        ValidAudience = Configuration["Jwt:Issuer"],
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["Jwt:Key"])),
                        NameClaimType = ClaimTypes.NameIdentifier,
                        ClockSkew = TimeSpan.Zero //the default for this setting is 5 minutes
                    };
                    options.Events = new JwtBearerEvents
                    {
                        OnAuthenticationFailed = context =>
                        {
                            if (context.Exception.GetType() == typeof(SecurityTokenExpiredException))
                            {
                                context.Response.Headers.Add("Token-Expired", "true");
                            }
                            return Task.CompletedTask;
                        }
                    };
                });

            services.AddSingleton(Configuration);

            // INSTANCIO REPOSITORIOS
            services.AddScoped<IUsuarioRepository, UsuarioRepository>();
            services.AddScoped<IMonedaRepository, MonedaRepository>();
            services.AddScoped<ISindicatoRepository, SindicatoRepository>();
            services.AddScoped<ITrabajoRepository, TrabajoRepository>();

            services.AddMvc(config =>
            {
                // AGREGA EL AUTHORIZE EN TODOS LOS CONTROLLERS COMO REQUERIMIENTO
                var policy = new AuthorizationPolicyBuilder()
                    .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme)
                    .RequireAuthenticatedUser()
                    .Build();
                config.Filters.Add(new AuthorizeFilter(policy));
            });

            services.AddSwaggerDocumentation();
            services.AddApiVersioning(options =>
            {
                options.UseApiBehavior = false;
                options.AssumeDefaultVersionWhenUnspecified = true;
                options.ApiVersionReader = new MediaTypeApiVersionReader();
                options.ReportApiVersions = true;
                options.DefaultApiVersion = new ApiVersion(1, 0);
                options.ApiVersionSelector = new CurrentImplementationApiVersionSelector(options); // optional, but recommended
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            //add NLog to .NET Core
            loggerFactory.AddNLog();

            env.ConfigureNLog("nlog.config");

            //app.UseDefaultFiles();
            app.UseStaticFiles();

            app.UseSwaggerDocumentation();

            app.UseAuthentication();

            app.UseSecurityHeadersMiddleware(new SecurityHeadersBuilder()
              .AddDefaultSecurePolicy()
              .AddCustomHeader("X-Build-Version", Configuration["Environment:Ambiente"])
            );

            app.UseExceptionHandler(config =>
            {
                config.Run(async context =>
                {
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    context.Response.ContentType = "application/json";

                    var error = context.Features.Get<IExceptionHandlerFeature>();
                    if (error != null)
                    {
                        var ex = error.Error;
                        //_logger.LogError(ex.Message);

                        await context.Response.WriteAsync(new ErrorDetails()
                        {
                            StatusCode = 500,
                            Message = ex.Message
                        }.ToString()); //ToString() is overridden to Serialize object
                    }
                });
            });

            app.UseMvc();
        }
    }
}
