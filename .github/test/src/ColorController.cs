using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;

namespace core_demo_api
{
    /// <summary>
    /// Endpoint for Color
    /// </summary>
    /// <remarks>
    /// Get a random color
    /// </remarks>
    /// <response code="200">Healthy</response>
    [Route("[controller]")]
    [AllowAnonymous]
    public class ColorController : Controller
    {
        [HttpGet]
        public ActionResult<string> GetColor()
        {
            var number = new Random().Next(4);
            var colors = new List<string> { "red", "green", "blue", "yellow" };

            return Ok(colors[number]);
        }
    }
}
