#!/bin/bash

echo "🔍 Checking for common errors in FridgeChef project..."

# Check for missing imports
echo "📦 Checking imports..."
grep -r "import " FridgeChef/ --include="*.swift" | grep -v "import Foundation" | grep -v "import SwiftUI" | grep -v "import CoreData" | grep -v "import AVFoundation" | grep -v "import PhotosUI" | grep -v "import UIKit"

# Check for potential Core Data issues
echo "🗄️ Checking Core Data setup..."
if [ -f "FridgeChef/FridgeChef.xcdatamodeld/FridgeChef.xcdatamodel/contents" ]; then
    echo "✅ Core Data model found"
else
    echo "❌ Core Data model missing"
fi

# Check for API key configuration
echo "🔑 Checking API key configuration..."
if grep -q "OPENAI_API_KEY" Config.swift; then
    echo "✅ API key configuration found"
else
    echo "❌ API key configuration missing"
fi

# Check for permission usage
echo "📱 Checking permission usage..."
if [ -f "FridgeChef/Info.plist" ] && grep -q "NSCameraUsageDescription" FridgeChef/Info.plist; then
    echo "✅ Camera permission found"
else
    echo "❌ Camera permission missing - add to Info.plist"
fi

if [ -f "FridgeChef/Info.plist" ] && grep -q "NSPhotoLibraryUsageDescription" FridgeChef/Info.plist; then
    echo "✅ Photo library permission found"
else
    echo "❌ Photo library permission missing - add to Info.plist"
fi

# Check for potential memory leaks
echo "🧠 Checking for potential memory leaks..."
grep -r "@StateObject\|@ObservedObject" FridgeChef/ --include="*.swift" | grep -v "private"

echo "✅ Error check complete!"
