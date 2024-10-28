// Copyright (c) 2024 Yauheni Lychkouski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

extension DependenciesContainer {
    func productsView(router: ProductsViewRouter) -> ProductsView {
        presentation.productsView(router: router)
    }
}

private struct Domain {
    let data: Data

    func getProductsUseCase() -> GetProductsUseCase {
        GetProductsUseCaseImp(productRepository: data.productRepository())
    }
}

private struct Presentation {
    let domain: Domain

    func productsView(router: ProductsViewRouter) -> ProductsView {
        ProductsView(
            router: router,
            viewModel: productsViewModel()
        )
    }

    private func productsViewModel() -> ProductsViewModel {
        ProductsViewModel(
            getProductsUseCase: domain.getProductsUseCase()
        )
    }
}

private struct Data {
    let external: ProductsExternalDependencies

    func productRepository() -> ProductRepository {
        ProductRepositoryImp()
    }
}
