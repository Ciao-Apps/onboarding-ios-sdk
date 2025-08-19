# OnboardingSDK

A dynamic, JSON-driven onboarding SDK for iOS apps built with SwiftUI.

## Features

✨ **Dynamic Onboarding Flows** - Configure onboarding screens via JSON  
🎯 **Multiple Page Types** - Text/Image, Input fields, Selectors, Sliders  
📱 **Native SwiftUI** - Beautiful, responsive UI components  
🔧 **Easy Integration** - Simple setup with app_id and flow_id  
📊 **Analytics Ready** - Track user inputs and flow completion  
🎨 **Customizable Styling** - Colors, fonts, and button styles via JSON  

## Quick Start

### 1. Installation

#### Swift Package Manager

Add via Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/Ciao-Apps/onboarding-ios-sdk.git`
3. Choose "Up to Next Major Version" starting from `1.0.0`

### 2. Ultra-Lean Integration (Just 2 Lines!)

Add these 2 modifiers to your existing ContentView:

```swift
import OnboardingSDK

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        // 🎯 YOUR EXISTING APP UI - NO CHANGES NEEDED
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        // ✨ Just add these 2 modifiers
        .onAppear {
            if !hasCompletedOnboarding { showOnboarding = true }
        }
        .sheet(isPresented: $showOnboarding) {
            DynamicOnboardingView(
                appID: "bubulab_app",
                flowID: "bubulab_onboarding_v1"  // Loads from JSON file
            ) { results in
                print("User data:", results)
                hasCompletedOnboarding = true
                showOnboarding = false
            }
        }
    }
}
```

**That's it!** Your app now shows onboarding for first-time users.

### 3. Alternative Display Options

**Fullscreen Cover (blocks everything until complete):**
```swift
.fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
    DynamicOnboardingView(appID: "your_app", flowID: "your_flow") { _ in
        hasCompletedOnboarding = true
    }
}
```

**Manual Trigger (show anytime):**
```swift
Button("Show Onboarding") {
    showOnboarding = true
}
```

### 4. Testing

Reset onboarding anytime:
```swift
Button("Reset Onboarding") {
    hasCompletedOnboarding = false
}
```

## JSON Configuration

Create dynamic onboarding flows using JSON:

```json
{
  "flowID": "fitness_onboarding_v1",
  "appID": "fitness_tracker_app",
  "version": "1.0",
  "pages": [
    {
      "id": "welcome",
      "type": "text_image",
      "title": "Welcome to FitTracker",
      "subtitle": "Your journey to better health starts here",
      "imageURL": "https://example.com/welcome.png",
      "style": {
        "titleColor": "#1D1D1F",
        "subtitleColor": "#6E6E73"
      }
    },
    {
      "id": "weight_input",
      "type": "input",
      "title": "What's your current weight?",
      "placeholder": "e.g., 70 kg",
      "inputType": "number",
      "key": "weight"
    },
    {
      "id": "goal_selection",
      "type": "selector",
      "title": "What's your fitness goal?",
      "key": "fitness_goal",
      "options": ["Lose weight", "Maintain weight", "Gain muscle"]
    },
    {
      "id": "activity_level",
      "type": "slider",
      "title": "How active are you daily?",
      "key": "activity_level",
      "min": 0,
      "max": 10,
      "step": 1
    }
  ]
}
```

## Page Types

### Text & Image
```json
{
  "type": "text_image",
  "title": "Welcome!",
  "subtitle": "Get started with our app",
  "imageURL": "https://example.com/image.png"
}
```

### Input Field
```json
{
  "type": "input",
  "title": "Enter your email",
  "placeholder": "your@email.com",
  "inputType": "email",
  "key": "user_email"
}
```

### Selector (Multiple Choice)
```json
{
  "type": "selector",
  "title": "Choose your preference",
  "key": "preference",
  "options": ["Option A", "Option B", "Option C"]
}
```

### Slider
```json
{
  "type": "slider",
  "title": "Set your budget",
  "key": "budget",
  "min": 0,
  "max": 1000,
  "step": 50
}
```

## Styling

Customize appearance via JSON:

```json
{
  "style": {
    "titleColor": "#1D1D1F",
    "subtitleColor": "#6E6E73",
    "backgroundColor": "#FFFFFF"
  },
  "button": {
    "title": "Get Started",
    "action": "finish",
    "style": {
      "backgroundColor": "#007AFF",
      "textColor": "#FFFFFF",
      "cornerRadius": 25
    }
  }
}
```

## Available Flows

The SDK loads flows from JSON files (simulating database):
- `"bubulab_onboarding_v1"` - Labubu collection experience (6 pages)

### User Data Structure

The completion handler returns user inputs:
```swift
[
    "experience_level": "Just starting out 🌱",
    "collection_goal": "Complete specific series", 
    "monthly_budget": 150.0,
    "notification_preferences": "New releases & restocks",
    "family_name": "The Bubu Squad"
]
```

## Advanced Usage

### Analytics Integration

```swift
// Track user progress
OnboardingSDK.shared.updateUserInput(
    key: "user_age",
    value: 25,
    pageID: "age_input"
)

// Get completion results
OnboardingSDK.shared.finishOnboarding { results in
    // Send to your analytics service
    Analytics.track("onboarding_completed", properties: results)
}
```

### Custom Flow Loading

```swift
// Load flow from your own JSON source
let customFlow = try JSONDecoder().decode(OnboardingFlow.self, from: jsonData)

// Present directly
OnboardingView(flow: customFlow) { results in
    // Handle completion
}
```

## Architecture

```
Sources/
├── OnboardingSDK/
│   ├── Models/
│   │   └── OnboardingModels.swift      # Data models
│   ├── Views/
│   │   ├── DynamicOnboardingView.swift # Main entry point
│   │   └── OnboardingView.swift        # UI components
│   └── OnboardingSDK.swift             # SDK manager
└── resources/
    └── bubulab_onboarding_v1.json      # JSON flow definition
```

### Key Components:
- **DynamicOnboardingView** - Drop-in component that loads flows from JSON
- **OnboardingSDK** - Manages flow loading and user data
- **JSON files** - Define onboarding flows (simulates database)

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

## Roadmap

- [ ] Remote JSON loading from CMS
- [ ] A/B testing support  
- [ ] Video background support
- [ ] Custom animation transitions
- [ ] Conditional page logic
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for better user onboarding experiences**
