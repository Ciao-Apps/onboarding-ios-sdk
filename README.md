# OnboardingSDK

A dynamic, JSON-driven onboarding SDK for iOS apps built with SwiftUI.
**Version 0.0.0** - Enhanced Template System

## 🚀 Features

✨ **Dynamic Onboarding Flows** - Configure onboarding screens via JSON  
🎨 **Global Templates** - 5 built-in themes (Minimal, Vibrant, Corporate, Modern, Playful)  
📊 **Modular Navigation** - 6 progress types, 5 button styles, flexible positioning  
🎯 **Multiple Page Types** - Hero, Content, Form, Feature, Completion layouts  
📱 **Native SwiftUI** - Beautiful, responsive UI components with animations  
🔧 **Easy Integration** - Simple setup with app_id and flow_id  
📊 **Analytics Ready** - Track user inputs and flow completion  
🌈 **Fully Customizable** - Colors, fonts, navigation styles, and layouts via JSON  

## Quick Start

### 1. Installation

#### Swift Package Manager

Add via Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/Ciao-Apps/onboarding-ios-sdk.git`
3. Choose "Up to Next Major Version" starting from `0.0.0`

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
                flowID: "bubulab_enhanced_v1",  // Enhanced flow with templates
                templateID: "vibrant"           // Optional: minimal, vibrant, corporate, modern, playful
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

## 🎨 Templates & Navigation

### Built-in Templates

Choose from 5 professionally designed templates:

- **`minimal`** - Clean text navigation with step counter
- **`vibrant`** - Colorful floating buttons with bouncing bubbles  
- **`corporate`** - Professional rectangles with gradient progress
- **`modern`** - Sleek design with animated dots
- **`playful`** - Fun animations with custom elements

### Template Usage

```swift
// Use a specific template
DynamicOnboardingView(
    appID: "your_app", 
    flowID: "your_flow",
    templateID: "vibrant"  // Instant theme change!
)

// Or let JSON define the template
DynamicOnboardingView(appID: "your_app", flowID: "your_flow")
```

## 📊 Navigation Styles

### Progress Indicators
- **Line** - Horizontal progress bar
- **Dots** - Animated circular indicators  
- **Bubbles** - Bouncing bubble animation
- **Step Counter** - "2 of 5" text display
- **Gradient** - Smooth color transitions
- **None** - Hidden progress

### Button Types  
- **Circle** - Floating circular buttons
- **Rectangle** - Clean rectangular buttons
- **Pill** - Rounded corner buttons
- **FAB** - Floating action buttons
- **Text** - Minimal text-only buttons

## 📱 Page Types

### Hero Pages
Large imagery with compelling headlines
```json
{
  "pageType": "hero",
  "contentType": "text_image",
  "title": "Welcome to Your App!",
  "subtitle": "Start your journey here",
  "imageURL": "https://example.com/hero.png"
}
```

### Content Pages  
Balanced text and media
```json
{
  "pageType": "content",
  "contentType": "text_image",
  "title": "Key Features",
  "subtitle": "Everything you need to know",
  "imageURL": "https://example.com/features.png"
}
```

### Form Pages
User input collection
```json
{
  "pageType": "form",
  "contentType": "input",
  "title": "Enter your email",
  "placeholder": "your@email.com", 
  "inputType": "email",
  "key": "user_email"
}
```

### Feature Pages
Showcase specific capabilities
```json
{
  "pageType": "feature",
  "contentType": "selector",
  "title": "Choose your plan",
  "key": "subscription_plan",
  "options": ["Basic", "Pro", "Enterprise"]
}
```

### Completion Pages
Success and next steps
```json
{
  "pageType": "completion",
  "contentType": "text_image",
  "title": "You're all set! 🎉",
  "subtitle": "Welcome to the community"
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

## 📦 Available Flows

The SDK includes example flows:
- `"bubulab_enhanced_v1"` - Enhanced Labubu collection experience (7 pages)
- Supports custom template selection and navigation styles

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

## 🏗️ Architecture

```
Sources/OnboardingSDK/
├── Models/
│   └── TemplateSystem.swift           # Enhanced data models & templates
├── Views/
│   ├── DynamicOnboardingView.swift    # Main entry point (lean)
│   └── Navigation/                    # Modular navigation system
│       ├── NavigationRenderer.swift   # Main navigation coordinator
│       ├── ProgressIndicators.swift   # Progress styles (dots, bubbles, etc.)
│       ├── NavigationButtons.swift    # Button types (circle, rectangle, etc.)
│       └── NavigationStyles.swift     # Positioning & animations
├── ViewModels/
│   └── EnhancedOnboardingViewModel.swift # State management
├── Utils/
│   ├── ImageCache.swift              # Performance optimization
│   └── CachedAsyncImage.swift        # Cached image loading
├── OnboardingSDK.swift               # SDK manager
└── Resources/
    └── bubulab_enhanced_v1.json      # Enhanced JSON flow definition
```

### ✨ Key Improvements:
- **Modular Navigation** - Separate files for different navigation components
- **Template System** - Global themes with consistent styling  
- **Enhanced Performance** - Image caching and optimized rendering
- **Type Safety** - Comprehensive Swift models matching JSON structure
- **Clean Architecture** - MVVM pattern with clear separation of concerns

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

## 🗺️ Roadmap

### 🎯 Version 2.1 (Q1 2024)
- [ ] **No-Code Constructor** - Web-based flow builder
- [ ] **Remote JSON loading** - CMS integration
- [ ] **A/B testing support** - Template performance comparison
- [ ] **Additional templates** - Industry-specific themes

### 🚀 Version 3.0 (Q2 2024)  
- [ ] **Video backgrounds** - Rich media support
- [ ] **Custom animations** - Advanced transitions
- [ ] **Conditional logic** - Smart page flow
- [ ] **Multi-language** - Localization support
- [ ] **Analytics dashboard** - Flow performance insights

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
