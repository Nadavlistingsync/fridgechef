import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var openAIService = OpenAIAPIService()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var detectedIngredients: [Ingredient] = []
    @State private var showingResults = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Scan Your Fridge")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Take a photo of your fridge contents to get recipe suggestions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                Spacer()
                
                // Camera Preview or Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green, lineWidth: 2)
                        )
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(20)
                    } else {
                        VStack {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("No image selected")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Choose from Library")
                        }
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    if selectedImage != nil {
                        Button(action: {
                            analyzeImage()
                        }) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                }
                                Text(isAnalyzing ? "Analyzing..." : "Analyze Ingredients")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAnalyzing ? Color.gray : Color.blue)
                            .cornerRadius(15)
                        }
                        .disabled(isAnalyzing)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Fridge Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCamera) {
                CameraSheet(image: $selectedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingResults) {
                IngredientsResultView(ingredients: detectedIngredients)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        
        // Check if API key is configured
        guard Config.isOpenAIConfigured else {
            isAnalyzing = false
            errorMessage = Config.apiKeyMissingMessage
            showingError = true
            return
        }
        
        // Use real API if configured, otherwise use mock data
        if Config.enableRealAIAnalysis && Config.isOpenAIConfigured {
            openAIService.analyzeFridgeImage(image) { result in
                DispatchQueue.main.async {
                    isAnalyzing = false
                    switch result {
                    case .success(let ingredients):
                        detectedIngredients = ingredients
                        showingResults = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
        } else {
            // Use mock data for testing
            DispatchQueue.main.asyncAfter(deadline: .now() + Config.mockAnalysisDelay) {
                detectedIngredients = [
                    Ingredient(name: "Tomatoes", confidence: 0.95, category: "Vegetables"),
                    Ingredient(name: "Chicken Breast", confidence: 0.88, category: "Protein"),
                    Ingredient(name: "Onions", confidence: 0.92, category: "Vegetables"),
                    Ingredient(name: "Bell Peppers", confidence: 0.87, category: "Vegetables"),
                    Ingredient(name: "Garlic", confidence: 0.78, category: "Vegetables"),
                    Ingredient(name: "Olive Oil", confidence: 0.85, category: "Pantry")
                ]
                isAnalyzing = false
                showingResults = true
            }
        }
    }
}

struct CameraSheet: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraSheet
        
        init(_ parent: CameraSheet) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class CameraManager: ObservableObject {
    @Published var isAuthorized = false
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                }
            }
        default:
            isAuthorized = false
        }
    }
}

#Preview {
    CameraView()
}
