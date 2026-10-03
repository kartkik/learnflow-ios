import Foundation

protocol CourseRepositoryProtocol {
    func getCourses(forceRefresh: Bool) async throws -> [Course]
    func getCourseDetails(id: Int) async throws -> Course
    func toggleLessonCompletion(courseId: Int, lessonId: Int) async throws -> Course
}
