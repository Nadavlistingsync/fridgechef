#!/bin/bash

# FridgeChef iOS App Build Script
# This script helps build and deploy the app to your device

echo "🍳 FridgeChef iOS App Build Script"
echo "=================================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "FridgeChef.xcodeproj/project.pbxproj" ]; then
    echo "❌ Not in the FridgeChef project directory"
    echo "Please run this script from the FridgeChef directory"
    exit 1
fi

# Check if Config.swift exists and has API key
if [ -f "Config.swift" ]; then
    if grep -q 'static let openAIAPIKey = ""' Config.swift; then
        echo "⚠️  Warning: OpenAI API key not configured"
        echo "   Edit Config.swift and add your OpenAI API key for full functionality"
    else
        echo "✅ OpenAI API key configured"
    fi
else
    echo "❌ Config.swift not found"
    exit 1
fi

# List available devices
echo ""
echo "📱 Available Devices:"
xcrun xctrace list devices 2>/dev/null | grep -E "(iPhone|iPad)" | head -10

echo ""
echo "🔧 Build Options:"
echo "1. Build for Simulator"
echo "2. Build for Device (requires device connected)"
echo "3. Clean Build"
echo "4. Open in Xcode"
echo "5. Exit"

read -p "Choose an option (1-5): " choice

case $choice in
    1)
        echo "🏗️  Building for Simulator..."
        xcodebuild -project FridgeChef.xcodeproj -scheme FridgeChef -destination 'platform=iOS Simulator,name=iPhone 15' build
        ;;
    2)
        echo "📱 Building for Device..."
        echo "Make sure your device is connected and trusted"
        xcodebuild -project FridgeChef.xcodeproj -scheme FridgeChef -destination 'generic/platform=iOS' build
        ;;
    3)
        echo "🧹 Cleaning build..."
        xcodebuild -project FridgeChef.xcodeproj clean
        echo "✅ Clean complete"
        ;;
    4)
        echo "🚀 Opening in Xcode..."
        open FridgeChef.xcodeproj
        ;;
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "✅ Build script completed!"
echo ""
echo "Next steps:"
echo "1. Open FridgeChef.xcodeproj in Xcode"
echo "2. Select your target device"
echo "3. Press Cmd+R to build and run"
echo "4. Grant camera and photo library permissions"
echo ""
echo "For OpenAI integration:"
echo "1. Get your API key from https://platform.openai.com/api-keys"
echo "2. Add it to Config.swift"
echo "3. Rebuild the app"
