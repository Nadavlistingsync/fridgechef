import Foundation
import SwiftUI

struct Ingredient: Identifiable, Codable {
    let id = UUID()
    let name: String
    let confidence: Double
    let category: String
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
    
    var confidenceColor: String {
        switch confidence {
        case 0.9...:
            return "green"
        case 0.7..<0.9:
            return "orange"
        default:
            return "red"
        }
    }
}

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let cookingTime: Int // in minutes
    let difficulty: String
    let servings: Int
    let imageURL: String?
    let tags: [String]
    let nutritionInfo: NutritionInfo?
    
    var formattedCookingTime: String {
        if cookingTime < 60 {
            return "\(cookingTime) min"
        } else {
            let hours = cookingTime / 60
            let minutes = cookingTime % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
}

struct NutritionInfo: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
}

struct IngredientsResultView: View {
    let ingredients: [Ingredient]
    @State private var showingRecipes = false
    @State private var suggestedRecipes: [Recipe] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if ingredients.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("No ingredients detected")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try taking a clearer photo of your fridge contents")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        Section(header: Text("Detected Ingredients")) {
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ingredient.name)
                                            .font(.headline)
                                        
                                        Text(ingredient.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("\(ingredient.confidencePercentage)%")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(ingredient.confidenceColor))
                                        
                                        ProgressView(value: ingredient.confidence)
                                            .progressViewStyle(LinearProgressViewStyle(tint: Color(ingredient.confidenceColor)))
                                            .frame(width: 60)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                if !ingredients.isEmpty {
                    Button(action: {
                        generateRecipes()
                    }) {
                        HStack {
                            Image(systemName: "fork.knife")
                            Text("Find Recipes")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                    }
                    .padding()
                }
            }
            .navigationTitle("Ingredients Found")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingRecipes) {
                RecipeSuggestionsView(recipes: suggestedRecipes, ingredients: ingredients)
            }
        }
    }
    
    private func generateRecipes() {
        // Mock recipe generation - in real app, this would call OpenAI API
        suggestedRecipes = [
            Recipe(
                name: "Chicken Stir Fry",
                description: "A quick and healthy stir fry using your available ingredients",
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
                ingredients: ["Tomatoes", "Garlic", "Olive Oil"],
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
            )
        ]
        showingRecipes = true
    }
}

#Preview {
    IngredientsResultView(ingredients: [
        Ingredient(name: "Tomatoes", confidence: 0.95, category: "Vegetables"),
        Ingredient(name: "Chicken Breast", confidence: 0.88, category: "Protein")
    ])
}
