# 🍳 FridgeChef - AI-Powered Recipe Generator

**FridgeChef** is an innovative iOS app that uses computer vision and AI to analyze your fridge contents and suggest delicious recipes you can make with the ingredients you have.

## ✨ Features

### 📸 Smart Fridge Scanning
- **Camera Integration**: Take photos of your fridge contents
- **AI-Powered Recognition**: Uses OpenAI's GPT-4 Vision to identify ingredients
- **Confidence Scoring**: See how confident the AI is about each detected ingredient
- **Category Classification**: Automatically categorizes ingredients (Vegetables, Protein, Dairy, etc.)

### 🍽️ Recipe Generation
- **AI Recipe Suggestions**: Get personalized recipes based on your available ingredients
- **Step-by-Step Instructions**: Detailed cooking instructions for each recipe
- **Cooking Time & Difficulty**: Know exactly how long and how hard each recipe is
- **Nutritional Information**: Complete nutritional breakdown per serving
- **Dietary Tags**: Filter by dietary preferences (Vegetarian, Quick, Healthy, etc.)

### 📱 Beautiful UI/UX
- **Modern SwiftUI Design**: Clean, intuitive interface
- **Tab-Based Navigation**: Easy access to all features
- **Recipe Favorites**: Save your favorite recipes for quick access
- **Shopping Lists**: Generate shopping lists for missing ingredients
- **Responsive Design**: Works perfectly on iPhone and iPad

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+** (Latest version recommended)
- **iOS 17.0+** deployment target
- **iPhone/iPad** for testing
- **OpenAI API Key** (for full functionality)

### Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd FridgeChef
   ```

2. **Open in Xcode**
   ```bash
   open FridgeChef.xcodeproj
   ```

3. **Configure OpenAI API**
   - Open `FridgeChef/OpenAIAPIService.swift`
   - Replace the empty `apiKey` parameter with your OpenAI API key:
   ```swift
   init(apiKey: String = "your-openai-api-key-here") {
       self.apiKey = apiKey
   }
   ```

4. **Build and Run**
   - Select your target device (iPhone/iPad)
   - Press `Cmd + R` to build and run
   - Grant camera and photo library permissions when prompted

### Testing on Your Phone

1. **Connect Your Device**
   - Connect your iPhone/iPad to your Mac via USB
   - Trust the computer on your device if prompted

2. **Select Your Device**
   - In Xcode, select your device from the device dropdown
   - Make sure your device is unlocked

3. **Build and Install**
   - Press `Cmd + R` to build and install on your device
   - The app will appear on your home screen

4. **Grant Permissions**
   - Allow camera access for taking fridge photos
   - Allow photo library access for selecting existing photos

## 🔧 Configuration

### OpenAI API Setup
1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Add it to the `OpenAIAPIService.swift` file
3. The app will use GPT-4 Vision for image analysis and GPT-4 for recipe generation

### Camera Permissions
The app requires camera access to:
- Take photos of your fridge contents
- Analyze ingredients using AI

### Photo Library Permissions
The app requires photo library access to:
- Select existing photos of your fridge
- Save recipe images (future feature)

## 📱 App Structure

### Main Views
- **Camera View**: Take/select photos and analyze ingredients
- **Recipes View**: Browse and search all available recipes
- **Favorites View**: Access your saved favorite recipes

### Key Components
- `FridgeChefApp.swift`: Main app entry point with Core Data setup
- `ContentView.swift`: Tab-based navigation
- `CameraView.swift`: Camera functionality and image analysis
- `RecipeView.swift`: Recipe browsing and filtering
- `RecipeDetailView.swift`: Detailed recipe view with instructions
- `OpenAIAPIService.swift`: AI integration for image analysis and recipe generation
- `IngredientModel.swift`: Data models for ingredients and recipes

## 🎯 How to Use

### 1. Scan Your Fridge
1. Open the app and tap the "Scan Fridge" tab
2. Take a photo of your fridge contents or select from your photo library
3. Tap "Analyze Ingredients" to process the image
4. Review the detected ingredients and their confidence scores

### 2. Get Recipe Suggestions
1. After analyzing ingredients, tap "Find Recipes"
2. Browse through AI-generated recipes that use your available ingredients
3. Filter by dietary preferences, cooking time, or difficulty level

### 3. Follow Recipes
1. Tap on any recipe to see detailed instructions
2. View step-by-step cooking instructions
3. Check nutritional information and serving sizes
4. Generate shopping lists for missing ingredients

### 4. Save Favorites
1. Tap the heart icon on any recipe to save it to favorites
2. Access your saved recipes from the Favorites tab

## 🔍 Technical Details

### AI Integration
- **Image Analysis**: Uses OpenAI's GPT-4 Vision API
- **Recipe Generation**: Uses OpenAI's GPT-4 API
- **JSON Parsing**: Structured responses for reliable data extraction

### Data Persistence
- **Core Data**: Local storage for favorites and saved ingredients
- **CloudKit Ready**: Prepared for future cloud synchronization

### Performance
- **Async Image Processing**: Non-blocking UI during AI analysis
- **Caching**: Efficient data management for smooth performance
- **Error Handling**: Graceful handling of API failures and network issues

## 🛠️ Development

### Project Structure
```
FridgeChef/
├── FridgeChef/
│   ├── FridgeChefApp.swift
│   ├── ContentView.swift
│   ├── CameraView.swift
│   ├── RecipeView.swift
│   ├── RecipeDetailView.swift
│   ├── IngredientModel.swift
│   ├── OpenAIAPIService.swift
│   ├── Assets.xcassets/
│   ├── Preview Content/
│   └── FridgeChef.xcdatamodeld/
├── FridgeChef.xcodeproj/
└── README.md
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence
- **AVFoundation**: Camera and photo library access
- **OpenAI API**: AI-powered image analysis and recipe generation
- **Combine**: Reactive programming for data flow

## 🚀 Future Enhancements

### Planned Features
- **Voice Commands**: "Hey Siri, what can I make for dinner?"
- **Meal Planning**: Weekly meal planning with shopping lists
- **Nutrition Tracking**: Daily nutrition goals and tracking
- **Social Features**: Share recipes with friends and family
- **Barcode Scanning**: Scan product barcodes for ingredient detection
- **Dietary Restrictions**: Advanced filtering for allergies and preferences
- **Recipe Ratings**: Community-driven recipe ratings and reviews

### Technical Improvements
- **Offline Mode**: Local recipe database for offline use
- **Cloud Sync**: Sync favorites and preferences across devices
- **Performance Optimization**: Faster image processing and recipe generation
- **Accessibility**: Enhanced accessibility features for all users

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI**: For providing the AI APIs that power the app
- **Apple**: For SwiftUI and the iOS development platform
- **Community**: For inspiration and feedback

## 📞 Support

If you encounter any issues or have questions:
1. Check the troubleshooting section below
2. Open an issue on GitHub
3. Contact the development team

## 🔧 Troubleshooting

### Common Issues

**App won't build:**
- Make sure you're using Xcode 15.0+
- Check that all files are included in the project
- Verify iOS deployment target is set to 17.0+

**Camera not working:**
- Check that camera permissions are granted
- Ensure you're testing on a physical device (camera doesn't work in simulator)

**AI analysis not working:**
- Verify your OpenAI API key is correctly set
- Check your internet connection
- Ensure you have sufficient API credits

**Recipes not loading:**
- Check network connectivity
- Verify API key is valid
- Try restarting the app

---

**Made with ❤️ for food lovers everywhere**
