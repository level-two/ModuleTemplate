# Module Layer

This folder contains the module's implementation and dependency container.

`ModuleImp` handles module initialization and implements the public Module interface.

`DependencyContainer` resolves module dependencies. It is organized by Clean Architecture layers: data, domain, and presentation. The presentation layer knows about the domain, and the data layer knows about the domain. They may also access external module dependencies if needed.

```swift
struct DependenciesContainer {
    init(externalDependencies: ProductsExternalDependencies) {
        let data = Data(external: externalDependencies)
        let domain = Domain(data: data)
        let presentation = Presentation(domain: domain)

        self.domain = domain
        self.presentation = presentation
    }

    private let domain: Domain
    private let presentation: Presentation
}

private struct Domain {
    let data: Data
    // Additional domain logic
}

private struct Presentation {
    let domain: Domain
    // Additional presentation logic
}

private struct Data {
    let external: ProductsExternalDependencies
    // Additional data logic
}
```

Dependencies are resolved through functions, while singleton dependencies use lazy properties.

`DependencyContainer` can provide use cases or views to `ModuleImp`:

```swift
extension DependenciesContainer {
    func getProductsUseCase() -> GetProductsUseCase {
        domain.getProductsUseCase()
    }
     
    func productsView(router: ProductsViewRouter) -> ProductsView {
        presentation.productsView(router: router)
    }
}
```
