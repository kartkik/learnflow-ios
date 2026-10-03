import Foundation

enum NetworkError: LocalizedError, Equatable {
    case offline
    case serverError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return "No internet connection available."
        case .serverError:
            return "Server error occurred while fetching courses."
        case .invalidResponse:
            return "Invalid response received from server."
        }
    }
}

protocol CourseRemoteDataSourceProtocol {
    func fetchCourses() async throws -> [Course]
}

final class CourseRemoteDataSource: CourseRemoteDataSourceProtocol {
    var shouldFail: Bool = false
    
    func fetchCourses() async throws -> [Course] {
        // Simulate remote API call latency
        try await Task.sleep(nanoseconds: 700_000_000)
        
        if shouldFail {
            throw NetworkError.serverError
        }
        
        // Exactly matches requirement specification courses + detailed lessons
        return [
            Course(
                id: 1,
                title: "Python Programming",
                instructor: "John Smith",
                progress: 65,
                lessonsCount: 20,
                lessons: [
                    Lesson(id: 101, title: "Introduction to Python", isCompleted: true),
                    Lesson(id: 102, title: "Variables & Data Types", isCompleted: true),
                    Lesson(id: 103, title: "Functions & Scope", isCompleted: true),
                    Lesson(id: 104, title: "Object-Oriented Programming (OOP)", isCompleted: true),
                    Lesson(id: 105, title: "Modules & Package Management", isCompleted: true),
                    Lesson(id: 106, title: "File I/O Operations", isCompleted: false),
                    Lesson(id: 107, title: "Exception Handling & Debugging", isCompleted: false),
                    Lesson(id: 108, title: "Async IO & Multithreading", isCompleted: false)
                ]
            ),
            Course(
                id: 2,
                title: "Generative AI",
                instructor: "Sarah Williams",
                progress: 40,
                lessonsCount: 16,
                lessons: [
                    Lesson(id: 201, title: "Introduction to Generative Models", isCompleted: true),
                    Lesson(id: 202, title: "Neural Networks & Backpropagation", isCompleted: true),
                    Lesson(id: 203, title: "Transformer Architecture", isCompleted: false),
                    Lesson(id: 204, title: "Large Language Models (LLMs)", isCompleted: false),
                    Lesson(id: 205, title: "Prompt Engineering Techniques", isCompleted: false)
                ]
            ),
            Course(
                id: 3,
                title: "Full Stack Development",
                instructor: "David Brown",
                progress: 25,
                lessonsCount: 28,
                lessons: [
                    Lesson(id: 301, title: "Web Architecture Overview", isCompleted: true),
                    Lesson(id: 302, title: "HTML5 & Modern CSS", isCompleted: true),
                    Lesson(id: 303, title: "JavaScript ES6+ Fundamentals", isCompleted: false),
                    Lesson(id: 304, title: "React Component Lifecycle", isCompleted: false)
                ]
            )
        ]
    }
}
