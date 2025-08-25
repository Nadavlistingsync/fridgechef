import SwiftUI
import CoreData

@main
struct FridgeChefApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "FridgeChef")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Log the error but don't crash the app
                print("❌ Core Data error: \(error.localizedDescription)")
                print("📁 Model name: \(description.url?.lastPathComponent ?? "unknown")")
                
                // Try to recover by deleting the store and recreating it
                if let url = description.url {
                    do {
                        try FileManager.default.removeItem(at: url)
                        print("🗑️ Deleted corrupted Core Data store")
                    } catch {
                        print("❌ Failed to delete corrupted store: \(error)")
                    }
                }
            } else {
                print("✅ Core Data initialized successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Enable automatic saving
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add some sample data for previews
        let sampleRecipe = FavoriteRecipe(context: viewContext)
        sampleRecipe.id = UUID()
        sampleRecipe.name = "Sample Recipe"
        sampleRecipe.timestamp = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FridgeChef")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
