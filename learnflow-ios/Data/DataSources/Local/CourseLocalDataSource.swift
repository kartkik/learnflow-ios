import Foundation

protocol CourseLocalDataSourceProtocol {
    func getCachedCourses() throws -> [Course]?
    func saveCourses(_ courses: [Course]) throws
    func updateCourse(_ course: Course) throws
    func clearCache() throws
}

final class CourseLocalDataSource: CourseLocalDataSourceProtocol {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        let folder = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        self.fileURL = folder.appendingPathComponent("cached_courses.json")
    }

    func getCachedCourses() throws -> [Course]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Course].self, from: data)
    }

    func saveCourses(_ courses: [Course]) throws {
        let data = try encoder.encode(courses)
        try data.write(to: fileURL, options: .atomic)
    }

    func updateCourse(_ course: Course) throws {
        var cached = (try getCachedCourses()) ?? []
        if let index = cached.firstIndex(where: { $0.id == course.id }) {
            cached[index] = course
        } else {
            cached.append(course)
        }
        try saveCourses(cached)
    }

    func clearCache() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
