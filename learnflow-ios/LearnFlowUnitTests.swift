import XCTest
@testable import learnflow_ios

final class LearnFlowUnitTests: XCTestCase {
    
    // MARK: - 1. Progress Calculation & Business Logic Tests
    
    func testCalculateProgress_WithPartialCompletedLessons_ReturnsCorrectPercentage() {
        // Given
        let lessons = [
            Lesson(id: 1, title: "Lesson 1", isCompleted: true),
            Lesson(id: 2, title: "Lesson 2", isCompleted: true),
            Lesson(id: 3, title: "Lesson 3", isCompleted: false),
            Lesson(id: 4, title: "Lesson 4", isCompleted: false)
        ]
        let course = Course(
            id: 1,
            title: "Test Course",
            instructor: "Test Instructor",
            progress: 0,
            lessonsCount: 4,
            lessons: lessons
        )
        
        // When
        let calculated = course.calculatedProgress
        
        // Then
        XCTAssertEqual(calculated, 50, "Progress should be exactly 50% when 2 out of 4 lessons are completed")
    }
    
    func testCalculateProgress_WithEmptyLessons_ReturnsFallbackProgress() {
        // Given
        let course = Course(
            id: 1,
            title: "Empty Course",
            instructor: "Test Instructor",
            progress: 65,
            lessonsCount: 20,
            lessons: []
        )
        
        // When
        let calculated = course.calculatedProgress
        
        // Then
        XCTAssertEqual(calculated, 65, "Progress should return initial progress property when lessons array is empty")
    }
    
    // MARK: - 2. LoginViewModel & Validation Unit Tests
    
    @MainActor
    func testLoginViewModel_WithInvalidEmail_SetsEmailError() {
        // Given
        let mockAuthRepo = AuthRepository(remoteDataSource: AuthRemoteDataSource())
        let loginUseCase = LoginUseCase(authRepository: mockAuthRepo)
        let viewModel = LoginViewModel(loginUseCase: loginUseCase)
        viewModel.email = "invalid-email"
        viewModel.password = "password123"
        
        // When
        let isValid = viewModel.validateFields()
        
        // Then
        XCTAssertFalse(isValid, "Validation should fail for invalid email format")
        XCTAssertEqual(viewModel.emailError, "Please enter a valid email address")
    }
    
    @MainActor
    func testLoginViewModel_WithValidInput_ValidatesSuccessfully() {
        // Given
        let mockAuthRepo = AuthRepository(remoteDataSource: AuthRemoteDataSource())
        let loginUseCase = LoginUseCase(authRepository: mockAuthRepo)
        let viewModel = LoginViewModel(loginUseCase: loginUseCase)
        viewModel.email = "learner@learnflow.com"
        viewModel.password = "password123"
        
        // When
        let isValid = viewModel.validateFields()
        
        // Then
        XCTAssertTrue(isValid, "Validation should succeed for valid email and password")
        XCTAssertNil(viewModel.emailError)
        XCTAssertNil(viewModel.passwordError)
    }
    
    // MARK: - 3. CourseDetailViewModel & Toggle Lesson Completion Test
    
    @MainActor
    func testToggleLessonCompletion_UpdatesProgressAndStatus() async {
        // Given
        let initialLessons = [
            Lesson(id: 101, title: "Lesson A", isCompleted: true),
            Lesson(id: 102, title: "Lesson B", isCompleted: false)
        ]
        let initialCourse = Course(
            id: 1,
            title: "SwiftUI Masterclass",
            instructor: "Apple Expert",
            progress: 50,
            lessonsCount: 2,
            lessons: initialLessons
        )
        
        let localDS = CourseLocalDataSource()
        try? localDS.saveCourses([initialCourse])
        
        let remoteDS = CourseRemoteDataSource()
        let repo = CourseRepository(remoteDataSource: remoteDS, localDataSource: localDS)
        let useCase = ToggleLessonCompletionUseCase(courseRepository: repo)
        let viewModel = CourseDetailViewModel(course: initialCourse, toggleLessonCompletionUseCase: useCase)
        
        // When: Toggle second lesson to completed
        viewModel.toggleLesson(initialLessons[1])
        
        // Wait briefly for async task completion
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Then
        XCTAssertEqual(viewModel.course.calculatedProgress, 100, "Progress should update to 100% after marking all lessons completed")
        XCTAssertTrue(viewModel.course.lessons.first(where: { $0.id == 102 })?.isCompleted == true)
    }
    
    // MARK: - 4. Repository Offline Fallback Test
    
    func testCourseRepository_OfflineMode_ServesCachedData() async throws {
        // Given
        let cachedCourses = [
            Course(id: 99, title: "Offline Course", instructor: "Cache Master", progress: 80, lessonsCount: 10)
        ]
        let localDS = CourseLocalDataSource()
        try localDS.saveCourses(cachedCourses)
        
        let remoteDS = CourseRemoteDataSource()
        let networkMonitor = NetworkMonitor.shared
        networkMonitor.isSimulatedOffline = true // Force offline mode
        
        let repository = CourseRepository(
            remoteDataSource: remoteDS,
            localDataSource: localDS,
            networkMonitor: networkMonitor
        )
        
        // When
        let resultCourses = try await repository.getCourses(forceRefresh: false)
        
        // Then
        XCTAssertFalse(resultCourses.isEmpty, "Repository should return cached courses when offline")
        XCTAssertEqual(resultCourses.first?.title, "Offline Course")
        
        // Reset network monitor
        networkMonitor.isSimulatedOffline = false
    }
}
