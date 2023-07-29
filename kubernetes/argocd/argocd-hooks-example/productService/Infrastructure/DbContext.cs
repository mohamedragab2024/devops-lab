using Microsoft.EntityFrameworkCore;
using productService.Doamin.Entities;

namespace productService.Infrastructure {
    public class ProductContext : DbContext {

        public DbSet<Product> Products {get;set;}
        public ProductContext(DbContextOptions<ProductContext> opts): base(opts)
        {
            
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            var product = modelBuilder.Entity<Product>();
            product.ToTable("product");
            product.HasKey(p=> p.Id);

            var productImages = modelBuilder.Entity<ProductImages>();
            productImages.ToTable("product_images");
            productImages.HasKey(pm=> pm.Id);
            productImages.HasOne(pm=> pm.Product)
            .WithMany(p=> p.Images)
            .HasForeignKey(pm=> pm.ProductId);

            var ProductFiles = modelBuilder.Entity<ProductFile>();
              ProductFiles.ToTable("product_files");
            ProductFiles.HasKey(pf=> pf.Id);
            ProductFiles.HasOne(pf=> pf.Product)
            .WithMany(p=> p.Files)
            .HasForeignKey(pm=> pm.ProductId);
        
        }
    }
}