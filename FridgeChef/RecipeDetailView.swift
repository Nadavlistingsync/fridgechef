import SwiftUI
import CoreData

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteRecipe.timestamp, ascending: false)],
        predicate: NSPredicate(format: "name == %@", recipe.name),
        animation: .default)
    private var existingFavorites: FetchedResults<FavoriteRecipe>
    
    @State private var showingShoppingList = false
    
    private var isFavorite: Bool {
        !existingFavorites.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            toggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Recipe Stats
                    HStack(spacing: 20) {
                        RecipeStatView(icon: "clock", value: recipe.formattedCookingTime, label: "Time")
                        RecipeStatView(icon: "person.2", value: "\(recipe.servings)", label: "Servings")
                        RecipeStatView(icon: "star", value: recipe.difficulty, label: "Difficulty")
                    }
                }
                .padding(.horizontal)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Ingredients
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Shopping List") {
                            showingShoppingList = true
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.green)
                                
                                Text(ingredient)
                                    .font(.body)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 15) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                
                                Text(instruction)
                                    .font(.body)
                                    .lineLimit(nil)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Nutrition Info
                if let nutrition = recipe.nutritionInfo {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Nutrition (per serving)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            NutritionStatView(value: "\(nutrition.calories)", label: "Calories")
                            NutritionStatView(value: "\(Int(nutrition.protein))g", label: "Protein")
                            NutritionStatView(value: "\(Int(nutrition.carbs))g", label: "Carbs")
                            NutritionStatView(value: "\(Int(nutrition.fat))g", label: "Fat")
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShoppingList) {
            ShoppingListView(recipe: recipe)
        }
    }
    
    private func toggleFavorite() {
        if isFavorite {
            // Remove from favorites
            existingFavorites.forEach { favorite in
                viewContext.delete(favorite)
            }
        } else {
            // Add to favorites
            let newFavorite = FavoriteRecipe(context: viewContext)
            newFavorite.id = UUID()
            newFavorite.name = recipe.name
            newFavorite.timestamp = Date()
            
            // Encode recipe data
            if let recipeData = try? JSONEncoder().encode(recipe) {
                newFavorite.recipeData = recipeData
            }
        }
        
        // Save changes
        do {
            try viewContext.save()
        } catch {
            print("Error saving favorite: \(error)")
        }
    }
}

struct RecipeStatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct NutritionStatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ShoppingListView: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Missing Ingredients")) {
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.green)
                                
                                Text(ingredient)
                                    .font(.body)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: Recipe(
            name: "Chicken Stir Fry",
            description: "A quick and healthy stir fry with vegetables",
            ingredients: ["Chicken Breast", "Bell Peppers", "Onions", "Garlic", "Olive Oil"],
            instructions: [
                "Cut chicken into bite-sized pieces",
                "Chop vegetables",
                "Heat oil in a large pan",
                "Cook chicken until golden",
                "Add vegetables and stir fry",
                "Season with salt and pepper"
            ],
            cookingTime: 25,
            difficulty: "Easy",
            servings: 4,
            imageURL: nil,
            tags: ["Quick", "Healthy", "Asian"],
            nutritionInfo: NutritionInfo(calories: 350, protein: 35, carbs: 15, fat: 12, fiber: 5)
        ))
    }
}
