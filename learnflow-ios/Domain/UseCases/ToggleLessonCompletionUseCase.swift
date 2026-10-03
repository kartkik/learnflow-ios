import Foundation

protocol ToggleLessonCompletionUseCaseProtocol {
    func execute(courseId: Int, lessonId: Int) async throws -> Course
}

final class ToggleLessonCompletionUseCase: ToggleLessonCompletionUseCaseProtocol {
    private let courseRepository: CourseRepositoryProtocol
    
    init(courseRepository: CourseRepositoryProtocol) {
        self.courseRepository = courseRepository
    }
    
    func execute(courseId: Int, lessonId: Int) async throws -> Course {
        return try await courseRepository.toggleLessonCompletion(courseId: courseId, lessonId: lessonId)
    }
}
