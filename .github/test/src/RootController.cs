using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace core_demo_api;

/// <summary>
/// Endpoint for Root
/// </summary>
/// <remarks>
/// Get OK
/// </remarks>
/// <response code="200">Healthy</response>
[Route("")]
[AllowAnonymous]
public class RootController : Controller
{
    [HttpGet]
    public ActionResult<string> GetOk()
    {
        return Ok("Ok");
    }
}