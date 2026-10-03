import Foundation

struct LoginCredentials {
    let email: String
    let password: String
}

protocol LoginUseCaseProtocol {
    func execute(credentials: LoginCredentials) async throws -> User
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(credentials: LoginCredentials) async throws -> User {
        let trimmedEmail = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Validators.isValidEmail(trimmedEmail) else {
            throw AuthError.invalidEmail
        }
        guard Validators.isValidPassword(credentials.password) else {
            throw AuthError.invalidPassword
        }
        
        return try await authRepository.login(email: trimmedEmail, password: credentials.password)
    }
}
