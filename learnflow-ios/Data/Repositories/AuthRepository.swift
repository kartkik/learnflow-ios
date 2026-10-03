import Foundation
import Combine

final class AuthRepository: ObservableObject, AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSourceProtocol
    private let keychain: KeychainStorage
    
    @Published private(set) var currentUser: User?
    
    var isAuthenticated: Bool {
        return currentUser != nil || keychain.get(forKey: "authToken") != nil
    }
    
    init(remoteDataSource: AuthRemoteDataSourceProtocol = AuthRemoteDataSource(),
         keychain: KeychainStorage = .shared) {
        self.remoteDataSource = remoteDataSource
        self.keychain = keychain
        
        // Restore existing user session if token exists
        if let token = keychain.get(forKey: "authToken"),
           let savedName = UserDefaults.standard.string(forKey: "user_name"),
           let savedEmail = UserDefaults.standard.string(forKey: "user_email") {
            self.currentUser = User(id: "saved_user", name: savedName, email: savedEmail, token: token)
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        let user = try await remoteDataSource.login(email: email, password: password)
        keychain.save(token: user.token, forKey: "authToken")
        UserDefaults.standard.set(user.name, forKey: "user_name")
        UserDefaults.standard.set(user.email, forKey: "user_email")
        
        await MainActor.run {
            self.currentUser = user
        }
        return user
    }
    
    func logout() async throws {
        keychain.delete(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "user_email")
        
        await MainActor.run {
            self.currentUser = nil
        }
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
}
