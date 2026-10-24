import SwiftUI

@MainActor
class AppRouter: ObservableObject {
    @Published var isLoading: Bool = false
    
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
    }
}
