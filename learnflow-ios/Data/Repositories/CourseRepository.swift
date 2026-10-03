import Foundation

final class CourseRepository: CourseRepositoryProtocol {
    private let remoteDataSource: CourseRemoteDataSourceProtocol
    private let localDataSource: CourseLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitor
    
    init(
        remoteDataSource: CourseRemoteDataSourceProtocol,
        localDataSource: CourseLocalDataSourceProtocol,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    func getCourses(forceRefresh: Bool = false) async throws -> [Course] {
        let cachedCourses = try? localDataSource.getCachedCourses()
        
        // 1. If offline, serve from cache
        if !networkMonitor.isEffectiveConnected {
            if let cached = cachedCourses, !cached.isEmpty {
                return cached.map { updateCalculatedProgress(for: $0) }
            } else {
                throw NetworkError.offline
            }
        }
        
        // 2. If online and not forcing refresh, return cached courses if available
        if !forceRefresh, let cached = cachedCourses, !cached.isEmpty {
            return cached.map { updateCalculatedProgress(for: $0) }
        }
        
        // 3. Fetch remote courses
        do {
            let remoteCourses = try await remoteDataSource.fetchCourses()
            let mergedCourses: [Course]
            
            if let cached = cachedCourses {
                mergedCourses = remoteCourses.map { remote in
                    if let cachedMatch = cached.first(where: { $0.id == remote.id }) {
                        var updated = remote
                        updated.lessons = cachedMatch.lessons
                        return updateCalculatedProgress(for: updated)
                    }
                    return updateCalculatedProgress(for: remote)
                }
            } else {
                mergedCourses = remoteCourses.map { updateCalculatedProgress(for: $0) }
            }
            
            try? localDataSource.saveCourses(mergedCourses)
            return mergedCourses
        } catch {
            // Fallback to local cache on network error
            if let cached = cachedCourses, !cached.isEmpty {
                return cached.map { updateCalculatedProgress(for: $0) }
            }
            throw error
        }
    }
    
    func getCourseDetails(id: Int) async throws -> Course {
        let courses = try await getCourses(forceRefresh: false)
        guard let course = courses.first(where: { $0.id == id }) else {
            throw NetworkError.invalidResponse
        }
        return course
    }
    
    func toggleLessonCompletion(courseId: Int, lessonId: Int) async throws -> Course {
        var cachedCourses = (try? localDataSource.getCachedCourses()) ?? []
        
        guard let courseIndex = cachedCourses.firstIndex(where: { $0.id == courseId }) else {
            throw NetworkError.invalidResponse
        }
        
        var course = cachedCourses[courseIndex]
        if let lessonIndex = course.lessons.firstIndex(where: { $0.id == lessonId }) {
            course.lessons[lessonIndex].isCompleted.toggle()
            course.progress = course.calculatedProgress
            
            cachedCourses[courseIndex] = course
            try localDataSource.saveCourses(cachedCourses)
        }
        
        return course
    }
    
    private func updateCalculatedProgress(for course: Course) -> Course {
        var updated = course
        updated.progress = updated.calculatedProgress
        return updated
    }
}
