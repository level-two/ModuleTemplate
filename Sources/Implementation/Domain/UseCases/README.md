# Use Cases

This folder contains Use Cases.

Each Use Case name should include a verb to reflect the business action it performs.

Use Cases follow the command pattern. For simplicity, both the Protocol and Implementation should be in the same file.

Typical use case file structure:

```swift
protocol GetProductUseCase {
    func execute(productId: Product.ProductId) async throws -> Product
}

struct GetProductUseCaseImp: GetProductUseCase {
    let productRepository: ProductRepository

    func execute(productId: Product.ProductId) async throws -> Product {
        try await productRepository.getProduct(productId: productId)
    }
}
```
