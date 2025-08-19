import Foundation
import SwiftUI

// MARK: - Main SDK Class
@available(iOS 15.0, *)
public class OnboardingSDK: ObservableObject {
    public static let shared = OnboardingSDK()
    
    @Published public var currentFlow: OnboardingFlow?
    @Published public var userInputs: [String: Any] = [:]
    
    private var appID: String?
    private var flows: [String: OnboardingFlow] = [:]
    
    private init() {}
    
    // MARK: - SDK Configuration
    public func configure(appID: String) {
        self.appID = appID
        loadFlows()
    }
    
    // MARK: - Flow Management
    public func loadFlow(flowID: String) -> OnboardingFlow? {
        guard let appID = appID else {
            print("OnboardingSDK: App ID not configured. Call configure(appID:) first.")
            return nil
        }
        
        // In a real implementation, this would fetch from a server or local JSON
        // For POC, we'll load from bundled JSON files
        return flows[flowID]
    }
    
    public func startOnboarding(flowID: String, completion: @escaping (OnboardingFlow?) -> Void) {
        if let flow = loadFlow(flowID: flowID) {
            currentFlow = flow
            userInputs.removeAll()
            completion(flow)
        } else {
            completion(nil)
        }
    }
    
    public func updateUserInput(key: String, value: Any, pageID: String) {
        userInputs[key] = value
        
        // Track analytics or send to server here
        let input = OnboardingUserInput(key: key, value: value, pageID: pageID)
        trackUserInput(input)
    }
    
    public func finishOnboarding(completion: @escaping ([String: Any]) -> Void) {
        // Send final data to completion handler
        completion(userInputs)
        
        // Reset for next use
        currentFlow = nil
        userInputs.removeAll()
    }
    
    // MARK: - Data Loading
    private func loadFlows() {
        // Load example flows from JSON
        // In production, this would load from a server or local cache
        loadExampleFlows()
    }
    
    private func loadExampleFlows() {
        // Fitness App Onboarding
        let fitnessFlow = OnboardingFlow(
            flowID: "fitness_onboarding_v1",
            appID: appID ?? "",
            version: "1.0",
            pages: [
                OnboardingPage(
                    id: "welcome",
                    type: .textImage,
                    title: "Welcome to FitTracker",
                    subtitle: "Your journey to better health starts here",
                    imageURL: "https://example.com/fitness-welcome.png",
                    style: PageStyle(
                        titleColor: "#1D1D1F",
                        subtitleColor: "#6E6E73"
                    )
                ),
                OnboardingPage(
                    id: "weight_input",
                    type: .input,
                    title: "What's your current weight?",
                    placeholder: "e.g., 70 kg",
                    inputType: .number,
                    key: "weight"
                ),
                OnboardingPage(
                    id: "goal_selection",
                    type: .selector,
                    title: "What's your fitness goal?",
                    key: "fitness_goal",
                    options: ["Lose weight", "Maintain weight", "Gain muscle", "Improve endurance"]
                ),
                OnboardingPage(
                    id: "activity_level",
                    type: .slider,
                    title: "How active are you daily?",
                    subtitle: "0 = Sedentary, 10 = Very Active",
                    key: "activity_level",
                    min: 0,
                    max: 10,
                    step: 1
                ),
                OnboardingPage(
                    id: "completion",
                    type: .textImage,
                    title: "You're all set!",
                    subtitle: "Let's create your personalized fitness plan",
                    imageURL: "https://example.com/fitness-complete.png",
                    button: ButtonConfig(
                        title: "Start My Journey",
                        action: "finish"
                    )
                )
            ]
        )
        
        // E-commerce App Onboarding
        let ecommerceFlow = OnboardingFlow(
            flowID: "ecommerce_onboarding_v1",
            appID: appID ?? "",
            version: "1.0",
            pages: [
                OnboardingPage(
                    id: "welcome",
                    type: .textImage,
                    title: "Welcome to ShopEasy",
                    subtitle: "Discover amazing products at great prices",
                    imageURL: "https://example.com/shop-welcome.png"
                ),
                OnboardingPage(
                    id: "interests",
                    type: .selector,
                    title: "What interests you most?",
                    key: "interests",
                    options: ["Electronics", "Fashion", "Home & Garden", "Sports", "Books"]
                ),
                OnboardingPage(
                    id: "budget",
                    type: .slider,
                    title: "What's your typical budget range?",
                    subtitle: "This helps us show relevant products",
                    key: "budget_range",
                    min: 0,
                    max: 1000,
                    step: 50
                ),
                OnboardingPage(
                    id: "email",
                    type: .input,
                    title: "Stay updated with deals",
                    placeholder: "your@email.com",
                    inputType: .email,
                    key: "email"
                ),
                OnboardingPage(
                    id: "ready",
                    type: .textImage,
                    title: "Ready to shop?",
                    subtitle: "Find products tailored just for you",
                    button: ButtonConfig(title: "Start Shopping", action: "finish")
                )
            ]
        )
        
        flows["fitness_onboarding_v1"] = fitnessFlow
        flows["ecommerce_onboarding_v1"] = ecommerceFlow
    }
    
    // MARK: - Analytics
    private func trackUserInput(_ input: OnboardingUserInput) {
        // In production, send to analytics service
        print("OnboardingSDK: User input tracked - Key: \(input.key), Page: \(input.pageID)")
    }
    
    // MARK: - Utility Methods
    public func getAvailableFlows() -> [String] {
        return Array(flows.keys)
    }
    
    public func getFlowInfo(flowID: String) -> OnboardingFlow? {
        return flows[flowID]
    }
}
