import Foundation

protocol GetCoursesUseCaseProtocol {
    func execute(forceRefresh: Bool) async throws -> [Course]
}

final class GetCoursesUseCase: GetCoursesUseCaseProtocol {
    private let courseRepository: CourseRepositoryProtocol
    
    init(courseRepository: CourseRepositoryProtocol) {
        self.courseRepository = courseRepository
    }
    
    func execute(forceRefresh: Bool = false) async throws -> [Course] {
        return try await courseRepository.getCourses(forceRefresh: forceRefresh)
    }
}
