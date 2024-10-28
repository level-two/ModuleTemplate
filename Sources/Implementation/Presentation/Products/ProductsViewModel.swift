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

import Combine

final class ProductsViewModel: ObservableObject {
    enum Intents {
        case fetchProducts
        case filterByName(String)
    }

    @Published var products: [Product] = []
    @Published var isLoading: Bool = false

    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
    }

    // ViewModel should gets user input through Intents
    func perform(_ intent: Intents) {
        switch intent {
        case .fetchProducts:
            Task {
                isLoading = true
                do {
                    products = try await getProductsUseCase.execute()
                } catch {
                    print("Error fetching products: \(error)")
                }
                isLoading = false
            }
        case .filterByName(let productName):
            // TBI
            break
        }
    }

    private let getProductsUseCase: GetProductsUseCase
}

