import Foundation
import UIKit
import CoreData

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    private init() {}
    
    // MARK: - Create Data
    func createData(data: [[String: Any]]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "WaterLog", in: managedContext) else {
            print("Failed to find entity: WaterLog")
            return
        }
        
        for record in data {
            let object = NSManagedObject(entity: entity, insertInto: managedContext)
            for (key, value) in record {
                object.setValue(value, forKey: key)
            }
        }
        
        do {
            try managedContext.save()
            print("Data saved successfully for entity: WaterLog")
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Retrieve Data
    func retrieveData() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WaterLog")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            createData(data: [])
            return []
        }
    }
    
    // MARK: - Update Data
    func updateData(logDate: String, updatedFields: [String: Any]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WaterLog")
        fetchRequest.predicate = NSPredicate(format: "logDate == %@", logDate)
        
        do {
            if let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject], let object = objects.first {
                for (key, value) in updatedFields {
                    object.setValue(value, forKey: key)
                }
                try managedContext.save()
                print("Data updated successfully for entity: WaterLog")
            } else {
                print("No matching record found for update.")
            }
        } catch {
            print("Failed to update data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Data
    func deleteData(logDate: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WaterLog")
        fetchRequest.predicate = NSPredicate(format: "logDate == %@", logDate)
        
        do {
            if let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject], let objectToDelete = objects.first {
                managedContext.delete(objectToDelete)
                try managedContext.save()
                print("Data deleted successfully for entity: WaterLog")
            } else {
                print("No matching record found for deletion.")
            }
        } catch {
            print("Failed to delete data: \(error.localizedDescription)")
        }
    }
}
