# Interface

This folder contains the module's public interface, including the module factory and structures for external dependencies.

The module interface typically includes:

```swift
public protocol ProductsModule {
    // actions
    func getProducts() -> async throws [Product]
    
    // widgets
    func productCard(productId: ProductId) -> ProductCardView
    
    // flows
    func productsList(router: ProductsListRouter) -> ProductsListView
}
```

The factory creates a module instance with specified parameters and dependencies:

```swift
public enum ProductsModuleFactory {
    public static func create(
        configuration: ProductsModuleConfiguration,
        externalDependencies: ProductsExternalDependencies
    ) -> ProductsModule { 
        ProductsModuleImp(
            configuration: configuration,
            dependenciesContainer: DependenciesContainer(externalDependencies: externalDependencies)
        )
    }
}
```

External dependencies are usually other modules or specific requirements like data sources:

```swift
import Cms

public struct ProductsExternalDependencies {
    let cmsModule: () -> Cms
    let logger: Logger

    public init(
        cmsModule: @escaping () -> Cms,
        logger: @escaping () -> Logger
    ) {
        self.cmsModule = cmsModule
        self.logger = logger
    }
}
```
