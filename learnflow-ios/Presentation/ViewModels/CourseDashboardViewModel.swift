import Foundation
import Combine

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case empty
    case failure(String)
}

@MainActor
final class CourseDashboardViewModel: ObservableObject {
    @Published var state: ViewState<[Course]> = .idle
    @Published var courses: [Course] = []
    @Published var isOfflineMode: Bool = false
    @Published var showOfflineBanner: Bool = false
    
    private let getCoursesUseCase: GetCoursesUseCaseProtocol
    private let authRepository: AuthRepositoryProtocol
    private let networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    init(
        getCoursesUseCase: GetCoursesUseCaseProtocol,
        authRepository: AuthRepositoryProtocol,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.getCoursesUseCase = getCoursesUseCase
        self.authRepository = authRepository
        self.networkMonitor = networkMonitor
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        networkMonitor.$isEffectiveConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOfflineMode = !isConnected
                self?.showOfflineBanner = !isConnected
            }
            .store(in: &cancellables)
    }
    
    func loadCourses(forceRefresh: Bool = false) {
        state = .loading
        
        Task {
            do {
                let fetchedCourses = try await getCoursesUseCase.execute(forceRefresh: forceRefresh)
                self.courses = fetchedCourses
                if fetchedCourses.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .success(fetchedCourses)
                }
            } catch {
                if let netErr = error as? NetworkError, netErr == .offline {
                    self.state = .failure("You are offline and no cached courses were found.")
                } else {
                    self.state = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    func toggleSimulatedOffline() {
        networkMonitor.isSimulatedOffline.toggle()
        loadCourses(forceRefresh: true)
    }
    
    func logout() {
        Task {
            try? await authRepository.logout()
        }
    }
    
    var userName: String {
        return authRepository.getCurrentUser()?.name ?? "Learner"
    }
}
