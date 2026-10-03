import Foundation
import Combine

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published var course: Course
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let toggleLessonCompletionUseCase: ToggleLessonCompletionUseCaseProtocol
    
    init(course: Course, toggleLessonCompletionUseCase: ToggleLessonCompletionUseCaseProtocol) {
        self.course = course
        self.toggleLessonCompletionUseCase = toggleLessonCompletionUseCase
    }
    
    func toggleLesson(_ lesson: Lesson) {
        Task {
            do {
                let updatedCourse = try await toggleLessonCompletionUseCase.execute(
                    courseId: course.id,
                    lessonId: lesson.id
                )
                self.course = updatedCourse
            } catch {
                self.errorMessage = "Failed to update lesson status."
            }
        }
    }
    
    var completedLessonsCount: Int {
        return course.lessons.filter { $0.isCompleted }.count
    }
    
    var totalLessonsCount: Int {
        return course.lessons.count
    }
}
