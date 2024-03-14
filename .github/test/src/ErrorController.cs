using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;

namespace core_demo_api
{
    /// <summary>
    /// Endpoint for testing error handling
    /// </summary>
    /// <remarks>
    /// Get a random error
    /// </remarks>
    /// <response code="200">Healthy</response>
    [Route("[controller]")]
    [AllowAnonymous]
    public class ErrorController : Controller
    {
        [HttpGet]
        public ActionResult<string> GetError()
        {
            var number = new Random().Next(3);
            switch (number)
            {
                case 0:
                    throw new InvalidOperationException("Error error error!");
                case 1:
                    throw new InvalidOperationException("Outer error", new InvalidOperationException("Error error error!"));
                case 2:
                    throw new InvalidOperationException("Outer error",
                        new InvalidOperationException("Inner error", 
                        new InvalidOperationException("Error error error!")));
            }
            // we never get here
            return Ok();
        }
    }
}
