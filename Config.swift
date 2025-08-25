import Foundation

struct Config {
    // MARK: - OpenAI Configuration
    static let openAIAPIKey = "" // Add your OpenAI API key here
    
    // MARK: - App Configuration
    static let appName = "FridgeChef"
    static let appVersion = "1.0.0"
    static let bundleIdentifier = "com.fridgechef.app"
    
    // MARK: - API Configuration
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let maxTokens = 2000
    static let imageAnalysisMaxTokens = 1000
    
    // MARK: - Feature Flags
    static let enableRealAIAnalysis = true // Set to false to use mock data
    static let enableRecipeGeneration = true
    static let enableFavorites = true
    
    // MARK: - UI Configuration
    static let primaryColor = "green"
    static let accentColor = "blue"
    static let cornerRadius: CGFloat = 15
    static let animationDuration: Double = 0.3
    
    // MARK: - Validation
    static var isOpenAIConfigured: Bool {
        return !openAIAPIKey.isEmpty
    }
    
    // MARK: - Debug Configuration
    static let enableDebugLogging = true
    static let mockAnalysisDelay: TimeInterval = 2.0 // Simulate API delay
}
