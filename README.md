# Module Architecture Guide

## Directory Structure
```
Sources/
├── Interface/               # Public module API
│   ├── MyModule.swift      # Main module protocol
│   └── ExternalDependencies.swift
├── Implementation/
│   ├── Data/               # Data layer
│   │   ├── Repositories/
│   │   └── DataSources/
│   ├── Domain/             # Domain layer
│   │   ├── BusinessModels/
│   │   ├── Gateways/
│   │   └── UseCases/
│   ├── Presentation/       # Presentation layer
│   │   ├── Views/
│   │   └── ViewModels/
│   └── Module/             # Module composition
│       ├── MyModuleImp.swift
│       └── DependenciesContainer.swift
└── Tests/                  # Test suite
```

## Clean Architecture Overview

The module follows Clean Architecture principles with clear separation of concerns:

### 1. Interface Layer (`Sources/Interface/`)

The public API of the module. This layer defines:
- Module's public interface
- External dependencies required by the module
- Data structures shared with other modules

The interface typically includes:
```swift
public protocol MyModule {
    // Actions
    func performAction() async throws -> Result

    // Widgets
    func widgetView(id: String) -> WidgetView

    // Flows
    func mainFlow(router: FlowRouter) -> MainView
}
```

External dependencies are defined as:
```swift
public struct ExternalDependencies {
    let otherModule: () -> OtherModule
    let logger: Logger

    public init(
        otherModule: @escaping () -> OtherModule,
        logger: Logger
    ) {
        self.otherModule = otherModule
        self.logger = logger
    }
}
```

### 2. Domain Layer (`Sources/Implementation/Domain/`)

The core business logic layer, framework-independent and pure Swift.

#### Business Models
Located in `Domain/BusinessModels/`
- Models are the core entities of the application
- Should be framework-independent
- Public properties for data access
- Typically conform to Identifiable if they have an ID
- Nested types go after properties

Example:
```swift
public struct Item: Identifiable {
    public let id: ItemId
    public let name: String
    public let price: Double
    public let categories: [Category.CategoryId]

    public typealias ItemId = String
}
```

#### Use Cases
Located in `Domain/UseCases/`
- Follow Command pattern
- One business action per use case
- Protocol and implementation in same file
- Throw errors instead of returning Result type
- Use async/await for asynchronous operations

Example:
```swift
protocol GetItemUseCase {
    func execute(itemId: Item.ItemId) async throws -> Item
}

struct GetItemUseCaseImp: GetItemUseCase {
    let itemRepository: ItemRepository

    func execute(itemId: Item.ItemId) async throws -> Item {
        try await itemRepository.getItem(itemId: itemId)
    }
}
```

#### Gateways
Located in `Domain/Gateways/`
- Define repository interfaces
- Abstract data access from business logic
- Use only domain models

Example:
```swift
protocol ItemRepository {
    func getItem(itemId: Item.ItemId) async throws -> Item
    func getItems(filter: ItemFilter) async throws -> [Item]
}
```

### 3. Data Layer (`Sources/Implementation/Data/`)

Implements repository interfaces and handles data persistence:
- Contains repository implementations
- Manages data sources
- Handles data mapping
- Implements caching if needed

Example:
```swift
struct ItemRepositoryImp: ItemRepository {
    let dataSource: ItemDataSource

    func getItem(itemId: Item.ItemId) async throws -> Item {
        let dto = try await dataSource.fetchItem(id: itemId)
        return dto.toDomain()
    }
}
```

### 4. Presentation Layer (`Sources/Implementation/Presentation/`)

UI components and presentation logic:
- Uses SwiftUI for views
- Implements MVVM pattern
- ViewModels handle presentation logic
- Uses Intents pattern for user actions

Example ViewModel:
```swift
final class ItemViewModel: ObservableObject {
    enum Intent {
        case loadItem(Item.ItemId)
        case updateItem(Item)
    }

    @Published var item: Item?
    @Published var isLoading = false

    init(getItemUseCase: GetItemUseCase) {
        self.getItemUseCase = getItemUseCase
    }

    func perform(_ intent: Intent) {
        switch intent {
        case .loadItem(let id):
            Task {
                isLoading = true
                do {
                    item = try await getItemUseCase.execute(itemId: id)
                } catch {
                    // Handle error
                }
                isLoading = false
            }
        }
    }

    private let getItemUseCase: GetItemUseCase
}
```

Example View:
```swift
struct ItemView: View {
    let router: ItemViewRouter
    @ObservedObject var viewModel: ItemViewModel

    var body: some View {
        List {
            if let item = viewModel.item {
                Text(item.name)
                Button("Show details") {
                    router.showDetails(for: item)
                }
            }
        }
        .onAppear {
            viewModel.perform(.loadItem(itemId))
        }
    }
}
```

### 5. Module Layer (`Sources/Implementation/Module/`)

Handles module composition and dependency injection:

#### Module Implementation
```swift
struct MyModuleImp: MyModule {
    let container: DependenciesContainer

    func mainView(router: ViewRouter) -> MainView {
        container.mainView(router: router)
    }
}
```

#### Dependencies Container
Organizes dependencies by Clean Architecture layers:
```swift
struct DependenciesContainer {
    init(externalDependencies: ExternalDependencies) {
        let data = Data(external: externalDependencies)
        let domain = Domain(data: data)
        let presentation = Presentation(domain: domain)

        self.domain = domain
        self.presentation = presentation
    }

    private let domain: Domain
    private let presentation: Presentation
}

private extension DependenciesContainer {
    struct Domain {
        let data: Data

        func itemRepository() -> ItemRepository {
            data.itemRepository()
        }

        func getItemUseCase() -> GetItemUseCase {
            GetItemUseCaseImp(itemRepository: itemRepository())
        }
    }

    struct Presentation {
        let domain: Domain

        func mainView(router: ViewRouter) -> MainView {
            MainView(
                router: router,
                viewModel: mainViewModel()
            )
        }

        private func mainViewModel() -> MainViewModel {
            MainViewModel(
                getItemUseCase: domain.getItemUseCase()
            )
        }
    }

    struct Data {
        let external: ExternalDependencies

        func itemRepository() -> ItemRepository {
            ItemRepositoryImp()
        }
    }
}
```

## Key Design Patterns

### 1. Clean Architecture
- Separates concerns into layers
- Dependencies point inward
- Domain layer is independent
- Outer layers depend on inner layers

### 2. Dependency Injection
- Used via DependenciesContainer
- Resolves dependencies by layer
- Supports testing and flexibility

### 3. Repository Pattern
- Abstracts data access
- Enables switching implementations
- Simplifies testing

### 4. Command Pattern (Use Cases)
- One operation per use case
- Clear business intent
- Easy to test and modify

### 5. MVVM
- SwiftUI views
- Observable ViewModels
- Intent-based user actions

## Implementation Guidelines

### Adding New Features

1. Define in Interface layer if needed
2. Add business models
3. Create use case(s)
4. Update/create repository interface
5. Implement repository
6. Add presentation components
7. Wire in DependenciesContainer

### Best Practices

1. Naming Conventions:
   - Protocols: No suffix
   - Implementations: `Imp` suffix
   - Use Cases: Verb + "UseCase"
   - ViewModels: Name + "ViewModel"

2. Code Organization:
   - One type per file
   - Group related files
   - Keep implementations private
   - Use extensions for protocol conformance

3. Architecture Rules:
   - Domain layer has no external dependencies
   - Use cases do one thing
   - ViewModels don't know about views
   - Repositories abstract data access

4. Swift Usage:
   - Prefer structs for stateless objects
   - Use `let` over `var` when possible
   - Limit type names to 40 characters
   - Use protocol-oriented programming

5. Asynchronuos Operations
   - Support async operations with async/await
   - Use AsyncSequence for one-shot actions that produce multiple values or provide an intermediate state
   - Use Combine for persistent streams

## Typical Data Flows

### 1. Loading Data
```
View.onAppear
    → ViewModel.perform(.loadItems)
        → GetItemsUseCase.execute()
            → ItemRepository.getItems()
                → DataSource.fetch()
                ← DTO
            ← [Item]
        ← [Item]
    → @Published var items
← View update
```

### 2. User Action
```
Button tap
    → ViewModel.perform(.userAction)
        → ActionUseCase.execute()
            → Repository.perform()
                → DataSource.update()
                ← Success/Error
            ← Result
        → Update @Published state
    → View update
```

### 3. Navigation
```
Button tap
    → View.router.navigate()
        → Parent module handles navigation
            → New view created
            ← View displayed
```

## Testing Strategy

1. Domain Layer:
   - Unit tests for use cases
   - Mock repositories
   - Test business rules

2. Data Layer:
   - Test repository implementations
   - Mock data sources
   - Test mapping logic

3. Presentation Layer:
   - Test ViewModels
   - Mock use cases
   - Test user interactions

Example test:
```swift
final class GetItemUseCaseTests: XCTestCase {
    func testExecute() async throws {
        // Given
        let repository = ItemRepositoryMock()
        let useCase = GetItemUseCaseImp(repository: repository)

        // When
        let result = try await useCase.execute(itemId: "123")

        // Then
        XCTAssertEqual(result.id, "123")
    }
}
```
