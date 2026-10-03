import Foundation
import CoreData

final class CoreDataCourseLocalDataSource: CourseLocalDataSourceProtocol {
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    func getCachedCourses() throws -> [Course]? {
        let context = coreDataManager.viewContext
        let request: NSFetchRequest<CDCourse> = NSFetchRequest<CDCourse>(entityName: "CDCourse")
        
        let cdCourses = try context.fetch(request)
        if cdCourses.isEmpty {
            return nil
        }
        
        return cdCourses.map { cdCourse in
            let cdLessons = (cdCourse.lessons?.allObjects as? [CDLesson]) ?? []
            let lessons = cdLessons.map { cdLesson in
                Lesson(id: Int(cdLesson.id), title: cdLesson.title, isCompleted: cdLesson.isCompleted)
            }.sorted { $0.id < $1.id }
            
            return Course(
                id: Int(cdCourse.id),
                title: cdCourse.title,
                instructor: cdCourse.instructor,
                progress: Int(cdCourse.progress),
                lessonsCount: Int(cdCourse.lessonsCount),
                lessons: lessons
            )
        }.sorted { $0.id < $1.id }
    }
    
    func saveCourses(_ courses: [Course]) throws {
        let context = coreDataManager.viewContext
        try clearCache()
        
        for course in courses {
            let cdCourse = CDCourse(context: context)
            cdCourse.id = Int64(course.id)
            cdCourse.title = course.title
            cdCourse.instructor = course.instructor
            cdCourse.progress = Int64(course.progress)
            cdCourse.lessonsCount = Int64(course.lessonsCount)
            
            let lessonSet = NSMutableSet()
            for lesson in course.lessons {
                let cdLesson = CDLesson(context: context)
                cdLesson.id = Int64(lesson.id)
                cdLesson.title = lesson.title
                cdLesson.isCompleted = lesson.isCompleted
                cdLesson.course = cdCourse
                lessonSet.add(cdLesson)
            }
            cdCourse.lessons = lessonSet
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    func updateCourse(_ course: Course) throws {
        let context = coreDataManager.viewContext
        let request: NSFetchRequest<CDCourse> = NSFetchRequest<CDCourse>(entityName: "CDCourse")
        request.predicate = NSPredicate(format: "id == %d", course.id)
        
        if let cdCourse = try context.fetch(request).first {
            cdCourse.progress = Int64(course.progress)
            if let existingLessons = cdCourse.lessons?.allObjects as? [CDLesson] {
                for cdLesson in existingLessons {
                    if let updatedLesson = course.lessons.first(where: { $0.id == Int(cdLesson.id) }) {
                        cdLesson.isCompleted = updatedLesson.isCompleted
                    }
                }
            }
            try context.save()
        } else {
            var all = (try getCachedCourses()) ?? []
            all.append(course)
            try saveCourses(all)
        }
    }
    
    func clearCache() throws {
        let context = coreDataManager.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDCourse")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try context.execute(deleteRequest)
        try context.save()
    }
}
