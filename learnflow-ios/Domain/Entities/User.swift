import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let token: String
}
