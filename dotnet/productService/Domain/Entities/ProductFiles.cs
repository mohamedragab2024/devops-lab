namespace productService.Doamin.Entities {
    public class ProductFile {
        public Guid Id { get; set; }

        public string FilePath { get; set; } = string.Empty;

        public Product Product {get;set;}

        public Guid ProductId {get;set;}

    }
}