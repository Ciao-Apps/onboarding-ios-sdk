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

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/onboarding-ios-sdk.git", from: "1.0.0")
]
```

Or add via Xcode:
1. File → Add Packages
2. Enter: `https://github.com/your-org/onboarding-ios-sdk.git`

### 2. Basic Setup

```swift
import OnboardingSDK
import SwiftUI

// Configure the SDK
OnboardingSDK.shared.configure(appID: "your_app_id")

// Start onboarding
OnboardingSDK.shared.startOnboarding(flowID: "welcome_flow_v1") { flow in
    if let flow = flow {
        // Present the onboarding view
        self.presentOnboarding(flow: flow)
    }
}
```

### 3. Present Onboarding

```swift
struct ContentView: View {
    @State private var showOnboarding = false
    @State private var currentFlow: OnboardingFlow?
    
    var body: some View {
        VStack {
            Button("Start Onboarding") {
                startOnboarding()
            }
        }
        .sheet(isPresented: $showOnboarding) {
            if let flow = currentFlow {
                OnboardingView(flow: flow) { results in
                    handleOnboardingComplete(results: results)
                    showOnboarding = false
                }
            }
        }
    }
    
    private func startOnboarding() {
        OnboardingSDK.shared.startOnboarding(flowID: "fitness_onboarding_v1") { flow in
            if let flow = flow {
                currentFlow = flow
                showOnboarding = true
            }
        }
    }
    
    private func handleOnboardingComplete(results: [String: Any]) {
        // Handle user inputs
        print("Onboarding completed with results:", results)
    }
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

## Demo App

Run the included demo app to see the SDK in action:

```bash
cd DemoApp
open OnboardingSDKDemo.xcodeproj
```

The demo includes example flows for:
- 🏃‍♂️ Fitness Tracker App
- 🛒 E-commerce Shop
- 🏦 Banking Application

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
OnboardingSDK/
├── Models/
│   └── OnboardingModels.swift      # Data models
├── Views/
│   └── OnboardingView.swift        # SwiftUI components
├── OnboardingSDK.swift             # Main SDK class
└── Resources/
    ├── fitness_onboarding_v1.json
    ├── ecommerce_onboarding_v1.json
    └── banking_onboarding_v1.json
```

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
