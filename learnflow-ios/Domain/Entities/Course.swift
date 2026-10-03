import Foundation

struct Course: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let instructor: String
    var progress: Int // percentage 0..100
    let lessonsCount: Int
    var lessons: [Lesson]

    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case instructor
        case progress
        case lessonsCount = "lessons"
        case lessonDetails = "lessonDetails"
    }
    
    // Custom decoding to support both integer count from simple JSON and embedded lessons array
    init(id: Int, title: String, instructor: String, progress: Int, lessonsCount: Int, lessons: [Lesson] = []) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.progress = progress
        self.lessonsCount = lessonsCount
        self.lessons = lessons
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.instructor = try container.decode(String.self, forKey: .instructor)
        self.progress = try container.decode(Int.self, forKey: .progress)
        
        // Decode lessons integer count or lessons array if present
        if let count = try? container.decode(Int.self, forKey: .lessonsCount) {
            self.lessonsCount = count
        } else {
            let decodedLessons = (try? container.decode([Lesson].self, forKey: .lessonDetails)) ?? []
            self.lessonsCount = decodedLessons.count
        }
        
        self.lessons = (try? container.decode([Lesson].self, forKey: .lessonDetails)) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(instructor, forKey: .instructor)
        try container.encode(progress, forKey: .progress)
        try container.encode(lessonsCount, forKey: .lessonsCount)
        try container.encode(lessons, forKey: .lessonDetails)
    }
    
    /// Dynamically calculates progress percentage based on completed lessons
    var calculatedProgress: Int {
        guard !lessons.isEmpty else { return progress }
        let completed = lessons.filter { $0.isCompleted }.count
        return Int((Double(completed) / Double(lessons.count) * 100.0).rounded())
    }
}
