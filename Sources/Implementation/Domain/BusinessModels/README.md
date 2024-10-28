# Business Models

According to Clean Architecture, this section contains the business models. These models are the core of the application and should be framework-independent. They should be usable in any project without modification.

Business Models and their data are public.

Business Models typically originate from UseCases and shouldn't be instantiated externally.

They should not conform to any protocols unless necessary. For example, Codable should not appear in this layer. However, Identifiable can be used to indicate that the model has an identifier.

A typical business model structure looks like this:

```swift
public struct Product: Identifiable {
    public let id: ProductId
    public let name: String
    public let price: Double
    
    public typealias ProductId = String
}
```
