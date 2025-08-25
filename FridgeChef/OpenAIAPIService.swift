import Foundation
import UIKit

class OpenAIAPIService: ObservableObject {
    private let apiKey: String
    private let baseURL = Config.openAIBaseURL
    
    init(apiKey: String = Config.openAIAPIKey) {
        self.apiKey = apiKey
    }
    
    // MARK: - Validation
    private func validateAPIKey() -> Bool {
        guard !apiKey.isEmpty else {
            print("❌ OpenAI API key is missing. Please add your API key in Config.swift")
            return false
        }
        return true
    }
    
    // MARK: - Image Analysis
    func analyzeFridgeImage(_ image: UIImage, completion: @escaping (Result<[Ingredient], Error>) -> Void) {
        // Check if API key is configured
        guard validateAPIKey() else {
            completion(.failure(APIError.missingAPIKey))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.invalidImage))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this image of a refrigerator/fridge contents and identify all food items visible. 
        Return a JSON array of objects with the following structure:
        {
            "name": "ingredient name",
            "confidence": 0.95,
            "category": "category (Vegetables, Protein, Dairy, Pantry, etc.)"
        }
        
        Be specific with ingredient names and provide confidence scores between 0.0 and 1.0.
        Only include items that are clearly visible and identifiable.
        """
        
        let requestBody = ImageAnalysisRequest(
            model: "gpt-4-vision-preview",
            messages: [
                Message(
                    role: "user",
                    content: [
                        Content(type: "text", text: prompt),
                        Content(type: "image_url", imageURL: ImageURL(url: "data:image/jpeg;base64,\(base64Image)"))
                    ]
                )
            ],
            maxTokens: 1000
        )
        
        makeRequest(endpoint: "/chat/completions", body: requestBody) { (result: Result<ImageAnalysisResponse, Error>) in
            switch result {
            case .success(let response):
                do {
                    let ingredients = try self.parseIngredientsFromResponse(response)
                    completion(.success(ingredients))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Recipe Generation
    func generateRecipes(from ingredients: [Ingredient], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        // Check if API key is configured
        guard validateAPIKey() else {
            completion(.failure(APIError.missingAPIKey))
            return
        }
        
        let ingredientNames = ingredients.map { $0.name }.joined(separator: ", ")
        
        let prompt = """
        Based on these available ingredients: \(ingredientNames)
        
        Generate 3-5 delicious recipes that can be made with these ingredients. 
        You may suggest a few additional common pantry items if needed.
        
        Return a JSON array of recipe objects with this structure:
        {
            "name": "Recipe Name",
            "description": "Brief description",
            "ingredients": ["ingredient1", "ingredient2"],
            "instructions": ["step1", "step2"],
            "cookingTime": 30,
            "difficulty": "Easy/Medium/Hard",
            "servings": 4,
            "tags": ["tag1", "tag2"],
            "nutritionInfo": {
                "calories": 350,
                "protein": 25.5,
                "carbs": 30.2,
                "fat": 15.8,
                "fiber": 8.5
            }
        }
        
        Make recipes practical, delicious, and suitable for home cooking.
        """
        
        let requestBody = ChatRequest(
            model: "gpt-4",
            messages: [Message(role: "user", content: [Content(type: "text", text: prompt)])],
            maxTokens: 2000
        )
        
        makeRequest(endpoint: "/chat/completions", body: requestBody) { (result: Result<ChatResponse, Error>) in
            switch result {
            case .success(let response):
                do {
                    let recipes = try self.parseRecipesFromResponse(response)
                    completion(.success(recipes))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeRequest<T: Codable, U: Codable>(endpoint: String, body: T, completion: @escaping (Result<U, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(U.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func parseIngredientsFromResponse(_ response: ImageAnalysisResponse) throws -> [Ingredient] {
        guard let content = response.choices.first?.message.content else {
            throw APIError.invalidResponse
        }
        
        // Extract JSON from the response
        let jsonStart = content.firstIndex(of: "[")
        let jsonEnd = content.lastIndex(of: "]")
        
        guard let start = jsonStart, let end = jsonEnd else {
            throw APIError.invalidResponse
        }
        
        let jsonString = String(content[start...end])
        
        do {
            let ingredients = try JSONDecoder().decode([Ingredient].self, from: Data(jsonString.utf8))
            return ingredients
        } catch {
            throw APIError.parsingError
        }
    }
    
    private func parseRecipesFromResponse(_ response: ChatResponse) throws -> [Recipe] {
        guard let content = response.choices.first?.message.content else {
            throw APIError.invalidResponse
        }
        
        // Extract JSON from the response
        let jsonStart = content.firstIndex(of: "[")
        let jsonEnd = content.lastIndex(of: "]")
        
        guard let start = jsonStart, let end = jsonEnd else {
            throw APIError.invalidResponse
        }
        
        let jsonString = String(content[start...end])
        
        do {
            let recipes = try JSONDecoder().decode([Recipe].self, from: Data(jsonString.utf8))
            return recipes
        } catch {
            throw APIError.parsingError
        }
    }
}

// MARK: - Request/Response Models
struct ImageAnalysisRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
}

struct Message: Codable {
    let role: String
    let content: [Content]
}

struct Content: Codable {
    let type: String
    let text: String?
    let imageURL: ImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

struct ImageURL: Codable {
    let url: String
}

struct ImageAnalysisResponse: Codable {
    let choices: [Choice]
}

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

// MARK: - Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidImage
    case noData
    case invalidResponse
    case parsingError
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidImage:
            return "Invalid image data"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response from API"
        case .parsingError:
            return "Error parsing response"
        case .missingAPIKey:
            return "OpenAI API key is missing. Please add your API key in Config.swift"
        }
    }
}
