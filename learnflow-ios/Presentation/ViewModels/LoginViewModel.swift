import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn = false
    
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    
    private let loginUseCase: LoginUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }
    
    var isValidInput: Bool {
        return Validators.isValidEmail(email) && Validators.isValidPassword(password)
    }
    
    func validateFields() -> Bool {
        emailError = nil
        passwordError = nil
        
        var valid = true
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            emailError = "Email cannot be empty"
            valid = false
        } else if !Validators.isValidEmail(trimmedEmail) {
            emailError = "Please enter a valid email address"
            valid = false
        }
        
        if password.isEmpty {
            passwordError = "Password cannot be empty"
            valid = false
        } else if !Validators.isValidPassword(password) {
            passwordError = "Password must be at least 6 characters"
            valid = false
        }
        return valid
    }
    
    func login() {
        guard validateFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await loginUseCase.execute(credentials: LoginCredentials(email: email, password: password))
                self.isLoading = false
                self.isLoggedIn = true
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func fillDemoCredentials() {
        email = "john.smith@learnflow.com"
        password = "password123"
        emailError = nil
        passwordError = nil
    }
}
