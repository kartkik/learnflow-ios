import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Build NSManagedObjectModel programmatically for 100% zero-config portability
        let model = NSManagedObjectModel()
        
        // CDCourse Entity
        let courseEntity = NSEntityDescription()
        courseEntity.name = "CDCourse"
        courseEntity.managedObjectClassName = NSStringFromClass(CDCourse.self)
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .integer64AttributeType
        idAttr.isOptional = false
        
        let titleAttr = NSAttributeDescription()
        titleAttr.name = "title"
        titleAttr.attributeType = .stringAttributeType
        titleAttr.isOptional = false
        
        let instructorAttr = NSAttributeDescription()
        instructorAttr.name = "instructor"
        instructorAttr.attributeType = .stringAttributeType
        instructorAttr.isOptional = false
        
        let progressAttr = NSAttributeDescription()
        progressAttr.name = "progress"
        progressAttr.attributeType = .integer64AttributeType
        progressAttr.isOptional = false
        
        let lessonsCountAttr = NSAttributeDescription()
        lessonsCountAttr.name = "lessonsCount"
        lessonsCountAttr.attributeType = .integer64AttributeType
        lessonsCountAttr.isOptional = false
        
        // CDLesson Entity
        let lessonEntity = NSEntityDescription()
        lessonEntity.name = "CDLesson"
        lessonEntity.managedObjectClassName = NSStringFromClass(CDLesson.self)
        
        let lessonIdAttr = NSAttributeDescription()
        lessonIdAttr.name = "id"
        lessonIdAttr.attributeType = .integer64AttributeType
        lessonIdAttr.isOptional = false
        
        let lessonTitleAttr = NSAttributeDescription()
        lessonTitleAttr.name = "title"
        lessonTitleAttr.attributeType = .stringAttributeType
        lessonTitleAttr.isOptional = false
        
        let lessonCompletedAttr = NSAttributeDescription()
        lessonCompletedAttr.name = "isCompleted"
        lessonCompletedAttr.attributeType = .booleanAttributeType
        lessonCompletedAttr.isOptional = false
        
        // Relationships
        let lessonsRel = NSRelationshipDescription()
        lessonsRel.name = "lessons"
        lessonsRel.destinationEntity = lessonEntity
        lessonsRel.minCount = 0
        lessonsRel.maxCount = 0 // to-many
        lessonsRel.deleteRule = .cascadeDeleteRule
        
        let courseRel = NSRelationshipDescription()
        courseRel.name = "course"
        courseRel.destinationEntity = courseEntity
        courseRel.minCount = 0
        courseRel.maxCount = 1 // to-one
        courseRel.deleteRule = .nullifyDeleteRule
        
        lessonsRel.inverseRelationship = courseRel
        courseRel.inverseRelationship = lessonsRel
        
        courseEntity.properties = [idAttr, titleAttr, instructorAttr, progressAttr, lessonsCountAttr, lessonsRel]
        lessonEntity.properties = [lessonIdAttr, lessonTitleAttr, lessonCompletedAttr, courseRel]
        
        model.entities = [courseEntity, lessonEntity]
        
        container = NSPersistentContainer(name: "LearnFlowModel", managedObjectModel: model)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = container
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

@objc(CDCourse)
public class CDCourse: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var instructor: String
    @NSManaged public var progress: Int64
    @NSManaged public var lessonsCount: Int64
    @NSManaged public var lessons: NSSet?
}

@objc(CDLesson)
public class CDLesson: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var course: CDCourse?
}
