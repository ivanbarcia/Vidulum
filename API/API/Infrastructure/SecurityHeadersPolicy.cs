using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace API.Infrastructure
{
    /// <summary>
    /// X-Frame-Options-related constants.
    /// </summary>
    public static class FrameOptionsConstants
    {
        /// <summary>
        /// The header value for X-Frame-Options
        /// </summary>
        public static readonly string Header = "X-Frame-Options";

        /// <summary>
        /// The page cannot be displayed in a frame, regardless of the site attempting to do so.
        /// </summary>
        public static readonly string Deny = "DENY";

        /// <summary>
        /// The page can only be displayed in a frame on the same origin as the page itself.
        /// </summary>
        public static readonly string SameOrigin = "SAMEORIGIN";

        /// <summary>
        /// The page can only be displayed in a frame on the specified origin. {0} specifies the format string
        /// </summary>
        public static readonly string AllowFromUri = "ALLOW-FROM {0}";
    }

    public class SecurityHeadersPolicy
    {
        public IDictionary<string, string> SetHeaders { get; }
             = new Dictionary<string, string>();

        public ISet<string> RemoveHeaders { get; }
            = new HashSet<string>();
    }

    public class SecurityHeadersMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly SecurityHeadersPolicy _policy;

        public SecurityHeadersMiddleware(RequestDelegate next, SecurityHeadersPolicy policy)
        {
            _next = next;
            _policy = policy;
        }

        public async Task Invoke(HttpContext context)
        {
            IHeaderDictionary headers = context.Response.Headers;

            foreach (var headerValuePair in _policy.SetHeaders)
            {
                headers[headerValuePair.Key] = headerValuePair.Value;
            }

            foreach (var header in _policy.RemoveHeaders)
            {
                headers.Remove(header);
            }

            await _next(context);
        }
    }

    public class SecurityHeadersBuilder
    {
        private readonly SecurityHeadersPolicy _policy = new SecurityHeadersPolicy();

        public SecurityHeadersBuilder AddDefaultSecurePolicy()
        {
            AddFrameOptionsDeny();
            //AddXssProtectionBlock();
            //AddContentTypeOptionsNoSniff();
            //AddStrictTransportSecurityMaxAge();
            RemoveServerHeader();

            return this;
        }

        public SecurityHeadersBuilder AddFrameOptionsDeny()
        {
            _policy.SetHeaders[FrameOptionsConstants.Header] = FrameOptionsConstants.Deny;
            return this;
        }

        public SecurityHeadersBuilder AddFrameOptionsSameOrigin()
        {
            _policy.SetHeaders[FrameOptionsConstants.Header] = FrameOptionsConstants.SameOrigin;
            return this;
        }

        public SecurityHeadersBuilder AddFrameOptionsSameOrigin(string uri)
        {
            _policy.SetHeaders[FrameOptionsConstants.Header] = string.Format(FrameOptionsConstants.AllowFromUri, uri);
            return this;
        }

        public SecurityHeadersBuilder RemoveServerHeader()
        {
            //_policy.RemoveHeaders.Add(ServerConstants.Header);
            return this;
        }

        public SecurityHeadersBuilder AddCustomHeader(string header, string value)
        {
            _policy.SetHeaders[header] = value;
            return this;
        }

        public SecurityHeadersBuilder RemoveHeader(string header)
        {
            _policy.RemoveHeaders.Add(header);
            return this;
        }

        public SecurityHeadersPolicy Build()
        {
            return _policy;
        }
    }
}
