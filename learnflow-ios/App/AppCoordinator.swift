import SwiftUI
import Combine

enum NavigationScreen: Hashable {
    case login
    case dashboard
    case courseDetail(Course)
}

final class AppContainer: ObservableObject {
    let authRepository: AuthRepositoryProtocol
    let courseRepository: CourseRepositoryProtocol
    let loginUseCase: LoginUseCaseProtocol
    let getCoursesUseCase: GetCoursesUseCaseProtocol
    let toggleLessonCompletionUseCase: ToggleLessonCompletionUseCaseProtocol
    
    init() {
        let authRemote = AuthRemoteDataSource()
        let courseRemote = CourseRemoteDataSource()
        let courseLocal = CoreDataCourseLocalDataSource()
        let keychain = KeychainStorage.shared
        
        let authRepo = AuthRepository(remoteDataSource: authRemote, keychain: keychain)
        let courseRepo = CourseRepository(remoteDataSource: courseRemote, localDataSource: courseLocal)

        
        self.authRepository = authRepo
        self.courseRepository = courseRepo
        self.loginUseCase = LoginUseCase(authRepository: authRepo)
        self.getCoursesUseCase = GetCoursesUseCase(courseRepository: courseRepo)
        self.toggleLessonCompletionUseCase = ToggleLessonCompletionUseCase(courseRepository: courseRepo)
    }
    
    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(loginUseCase: loginUseCase)
    }
    
    @MainActor
    func makeCourseDashboardViewModel() -> CourseDashboardViewModel {
        return CourseDashboardViewModel(
            getCoursesUseCase: getCoursesUseCase,
            authRepository: authRepository
        )
    }
    
    @MainActor
    func makeCourseDetailViewModel(course: Course) -> CourseDetailViewModel {
        return CourseDetailViewModel(
            course: course,
            toggleLessonCompletionUseCase: toggleLessonCompletionUseCase
        )
    }
}

struct AppCoordinatorView: View {
    @StateObject private var container = AppContainer()
    @State private var navigationPath = NavigationPath()
    @State private var isAuthenticated: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if isAuthenticated {
                    CourseDashboardView(
                        viewModel: container.makeCourseDashboardViewModel(),
                        onSelectCourse: { course in
                            navigationPath.append(NavigationScreen.courseDetail(course))
                        },
                        onLogout: {
                            withAnimation {
                                isAuthenticated = false
                                navigationPath = NavigationPath()
                            }
                        }
                    )
                } else {
                    LoginView(
                        viewModel: container.makeLoginViewModel(),
                        onLoginSuccess: {
                            withAnimation {
                                isAuthenticated = true
                            }
                        }
                    )
                }
            }
            .navigationDestination(for: NavigationScreen.self) { screen in
                switch screen {
                case .login:
                    EmptyView()
                case .dashboard:
                    EmptyView()
                case .courseDetail(let course):
                    CourseDetailView(
                        viewModel: container.makeCourseDetailViewModel(course: course)
                    )
                }
            }
        }
        .onAppear {
            isAuthenticated = container.authRepository.isAuthenticated
        }
    }
}
