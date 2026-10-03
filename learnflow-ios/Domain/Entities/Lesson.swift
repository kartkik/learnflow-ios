import Foundation

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

