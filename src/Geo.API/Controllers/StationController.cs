using Geo.Service.Services;
using Geo.Service.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace Geo.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StationController : ControllerBase
    {
        private readonly IStationService _service;

        public StationController(IStationService service)
        {
            _service = service;
        }

        [SwaggerOperation("查詢站點列表")]
        [HttpGet, Route("Index")]
        public async Task<IActionResult> Index([FromQuery] StationSearchVM vm)
            => Ok(await _service.Index(vm));

        [SwaggerOperation("取得單站詳情")]
        [HttpGet, Route("Get")]
        public async Task<IActionResult> Get([FromQuery] string sno)
            => Ok(await _service.Get(sno));

        [SwaggerOperation("取得行政區與站數")]
        [HttpGet, Route("Districts")]
        public async Task<IActionResult> Districts()
            => Ok(await _service.Districts());
    }
}
