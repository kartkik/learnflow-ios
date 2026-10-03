import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case invalidPassword
    case invalidCredentials
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 6 characters long."
        case .invalidCredentials:
            return "Invalid credentials. Use any valid email & password."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}

protocol AuthRemoteDataSourceProtocol {
    func login(email: String, password: String) async throws -> User
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    func login(email: String, password: String) async throws -> User {
        // Simulate network API delay
        try await Task.sleep(nanoseconds: 800_000_000)
        
        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail == "fail@learnflow.com" {
            throw AuthError.invalidCredentials
        }
        
        let userName = trimmedEmail.components(separatedBy: "@").first?.capitalized ?? "Learner"
        
        return User(
            id: UUID().uuidString,
            name: userName.replacingOccurrences(of: ".", with: " "),
            email: trimmedEmail,
            token: "jwt_token_\(UUID().uuidString.prefix(8))"
        )
    }
}
