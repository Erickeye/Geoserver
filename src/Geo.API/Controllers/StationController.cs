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
        {
            return Ok(await _service.Index(vm));
        }

        [SwaggerOperation("取得單站詳情")]
        [HttpGet, Route("Get")]
        public async Task<IActionResult> Get([FromQuery] string sno)
            => Ok(await _service.Get(sno));

        [SwaggerOperation("取得最近 N 個營運中站點")]
        [HttpGet, Route("Nearest")]
        public async Task<IActionResult> Nearest([FromQuery] NearestSearchVM vm)
            => Ok(await _service.Nearest(vm));

        [SwaggerOperation("取得地圖用的全部站點（精簡欄位）")]
        [HttpGet, Route("Map")]
        public async Task<IActionResult> Map()
        {
            return Ok(await _service.Map());
        }

        [SwaggerOperation("取得資料更新狀態")]
        [HttpGet, Route("Status")]
        public async Task<IActionResult> Status()
        {
            return Ok(await _service.Status());
        }

        [SwaggerOperation("取得單站歷史車輛數")]
        [HttpGet, Route("History")]
        public async Task<IActionResult> History([FromQuery] HistorySearchVM vm)
        {
            return Ok(await _service.History(vm));
        }

        [SwaggerOperation("取得行政區與站數")]
        [HttpGet, Route("Districts")]
        public async Task<IActionResult> Districts()
            => Ok(await _service.Districts());
    }
}
