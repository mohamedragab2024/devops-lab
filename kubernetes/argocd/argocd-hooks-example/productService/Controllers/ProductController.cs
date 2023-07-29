using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using productService.Doamin.Entities;
using productService.Infrastructure;

namespace productService.Controllers;

[ApiController]
[Route("[controller]")]
public class ProductController : ControllerBase
{

    private readonly ILogger<ProductController> _logger;
    private readonly ProductContext _context;

    public ProductController(ILogger<ProductController> logger, ProductContext context)
    {
        _logger = logger;
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> CreateAsync(Product model)
    {
        await _context.Products.AddAsync(model);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet]
    public async Task<List<Product>> GetAsync(){
        return await _context.Products.ToListAsync();
    }

}
