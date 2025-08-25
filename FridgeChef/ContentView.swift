import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Scan Fridge")
                }
                .tag(0)
            
            RecipeView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Recipes")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(2)
        }
        .accentColor(.green)
    }
}

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteRecipe.timestamp, ascending: false)],
        animation: .default)
    private var favoriteRecipes: FetchedResults<FavoriteRecipe>
    
    var body: some View {
        NavigationView {
            VStack {
                if favoriteRecipes.isEmpty {
                    VStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("Your Favorite Recipes")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Save your favorite recipes here by tapping the heart icon on any recipe")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(favoriteRecipes, id: \.id) { favorite in
                            if let recipeData = favorite.recipeData,
                               let recipe = try? JSONDecoder().decode(Recipe.self, from: recipeData) {
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    FavoriteRecipeRowView(recipe: recipe)
                                }
                            }
                        }
                        .onDelete(perform: deleteFavorites)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func deleteFavorites(offsets: IndexSet) {
        withAnimation {
            offsets.map { favoriteRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting favorite: \(error)")
            }
        }
    }
}

struct FavoriteRecipeRowView: View {
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

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
