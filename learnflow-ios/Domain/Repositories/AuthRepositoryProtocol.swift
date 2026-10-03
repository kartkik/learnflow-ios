import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func getCurrentUser() -> User?
    var isAuthenticated: Bool { get }
}
