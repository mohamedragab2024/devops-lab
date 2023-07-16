namespace productService.Doamin.Entities {
    public class Product {
        public Product()
        {
            this.Images = new HashSet<ProductImages>();
        }
        public Guid Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public decimal Price { get; set; }

        public virtual ICollection<ProductImages> Images { get;set;}

         public virtual ICollection<ProductFile> Files { get;set;}
    }
}