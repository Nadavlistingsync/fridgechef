import SwiftUI

struct RecipeView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var recipes: [Recipe] = []
    
    let categories = ["All", "Quick", "Healthy", "Vegetarian", "Asian", "Italian", "Mexican"]
    
    var filteredRecipes: [Recipe] {
        var filtered = recipes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if selectedCategory != "All" {
            filtered = filtered.filter { recipe in
                recipe.tags.contains(selectedCategory)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search recipes...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.green : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                // Recipe List
                if filteredRecipes.isEmpty {
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No recipes found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try scanning your fridge first or adjust your search")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                loadSampleRecipes()
            }
        }
    }
    
    private func loadSampleRecipes() {
        recipes = [
            Recipe(
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
            ),
            Recipe(
                name: "Tomato Basil Pasta",
                description: "Simple and delicious pasta with fresh tomatoes",
                ingredients: ["Tomatoes", "Garlic", "Olive Oil", "Pasta"],
                instructions: [
                    "Cook pasta according to package",
                    "Dice tomatoes",
                    "Sauté garlic in olive oil",
                    "Add tomatoes and cook",
                    "Toss with pasta",
                    "Garnish with basil"
                ],
                cookingTime: 20,
                difficulty: "Easy",
                servings: 2,
                imageURL: nil,
                tags: ["Italian", "Vegetarian", "Quick"],
                nutritionInfo: NutritionInfo(calories: 400, protein: 12, carbs: 65, fat: 8, fiber: 4)
            ),
            Recipe(
                name: "Vegetable Curry",
                description: "Aromatic and spicy vegetable curry",
                ingredients: ["Onions", "Garlic", "Bell Peppers", "Tomatoes", "Coconut Milk"],
                instructions: [
                    "Sauté onions and garlic",
                    "Add spices and cook",
                    "Add vegetables",
                    "Pour in coconut milk",
                    "Simmer until vegetables are tender",
                    "Serve with rice"
                ],
                cookingTime: 45,
                difficulty: "Medium",
                servings: 6,
                imageURL: nil,
                tags: ["Vegetarian", "Healthy", "Spicy"],
                nutritionInfo: NutritionInfo(calories: 280, protein: 8, carbs: 25, fat: 18, fiber: 8)
            )
        ]
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(recipe.formattedCookingTime)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(recipe.difficulty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text("\(recipe.servings) servings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecipeSuggestionsView: View {
    let recipes: [Recipe]
    let ingredients: [Ingredient]
    
    var body: some View {
        NavigationView {
            VStack {
                if recipes.isEmpty {
                    VStack {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No recipes found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try adding more ingredients to your fridge")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                }
            }
            .navigationTitle("Recipe Suggestions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RecipeView()
}
