import Foundation

struct Config {
    // MARK: - OpenAI Configuration
    // 🔑 IMPORTANT: Add your OpenAI API key here
    // 1. Go to https://platform.openai.com/api-keys
    // 2. Create a new API key or copy your existing one
    // 3. Replace the empty string below with your actual API key
    // 4. Example: static let openAIAPIKey = "sk-1234567890abcdef..."
    static let openAIAPIKey = "" // ⚠️ ADD YOUR API KEY HERE
    
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
        return !openAIAPIKey.isEmpty && openAIAPIKey != "your-openai-api-key-here"
    }
    
    // MARK: - Debug Configuration
    static let enableDebugLogging = true
    static let mockAnalysisDelay: TimeInterval = 2.0 // Simulate API delay
    
    // MARK: - Error Messages
    static let apiKeyMissingMessage = "OpenAI API key not configured. Please add your API key in Config.swift"
    static let networkErrorMessage = "Network error. Please check your internet connection."
    static let apiErrorMessage = "API error. Please try again later."
    static let imageProcessingErrorMessage = "Error processing image. Please try again."
}
