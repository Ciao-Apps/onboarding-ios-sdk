# Ultra-Lean Integration Guide

## 🎯 Add Onboarding to Your Existing App in 2 Lines

### Step 1: Add Package
```
File → Add Package Dependencies → Your GitHub URL
```

### Step 2: Add to Your Existing View

**Just add these 2 modifiers to your existing ContentView:**

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
                appID: "your_app_id",
                flowID: "your_flow_id_v1"
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

## 🔄 Alternative Options

### Fullscreen Cover (Blocks everything until complete)
```swift
.fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
    DynamicOnboardingView(appID: "your_app", flowID: "your_flow") { _ in
        hasCompletedOnboarding = true
    }
}
```

### Manual Trigger (Show anytime)
```swift
Button("Show Onboarding") {
    showOnboarding = true
}
.sheet(isPresented: $showOnboarding) {
    DynamicOnboardingView(appID: "your_app", flowID: "your_flow") { _ in
        showOnboarding = false
    }
}
```

## 🎯 Available Flows

- `"fitness_onboarding_v1"` - Weight, goals, activity level
- `"ecommerce_onboarding_v1"` - Interests, budget, email
- `"banking_onboarding_v1"` - Account type, income, security

## 🧪 Testing

Add this button anywhere to reset:
```swift
Button("Reset Onboarding") {
    hasCompletedOnboarding = false
}
```

## 📊 User Data Structure

The completion handler returns:
```swift
[
    "weight": "70",
    "fitness_goal": "Lose weight", 
    "activity_level": 5.0,
    "completed_at": Date()
]
```

**Ultra-minimal. Drop-in. Works with any existing app structure.** 🚀
