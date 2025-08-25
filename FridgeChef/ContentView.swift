import SwiftUI

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
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Your Favorite Recipes")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Save your favorite recipes here")
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    ContentView()
}
