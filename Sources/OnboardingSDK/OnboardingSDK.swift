import Foundation
import SwiftUI

// MARK: - Main SDK Class
@available(iOS 15.0, *)
public class OnboardingSDK: ObservableObject {
    public static let shared = OnboardingSDK()
    
    @Published public var currentFlow: OnboardingFlow?
    @Published public var userInputs: [String: Any] = [:]
    
    private var appID: String?
    
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
        
        // 🎯 Load from JSON file (simulating database)
        return loadFlowFromJSON(flowID: flowID)
    }
    
    // MARK: - JSON Loading (Database Simulation)
    private func loadFlowFromJSON(flowID: String) -> OnboardingFlow? {
        let bundle = Bundle.module
        
        // Look for JSON file in Resources folder
        guard let url = bundle.url(forResource: flowID, withExtension: "json", subdirectory: "Resources") else {
            print("OnboardingSDK: ❌ No JSON file found for flowID: \(flowID)")
            print("OnboardingSDK: Bundle path: \(bundle.bundlePath)")
            
            // List all available resources for debugging
            if let allJsonFiles = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) {
                print("OnboardingSDK: Available JSON files: \(allJsonFiles.map { $0.lastPathComponent })")
            }
            
            // Use fallback only if JSON file is missing
            print("OnboardingSDK: 🔄 Using fallback flow instead of JSON")
            return createFallbackFlow(flowID: flowID)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonFlow = try JSONDecoder().decode(OnboardingFlow.self, from: data)
            print("OnboardingSDK: ✅ Successfully loaded flow '\(flowID)' from JSON file")
            print("OnboardingSDK: JSON path: \(url.path)")
            return jsonFlow
        } catch {
            print("OnboardingSDK: ❌ Failed to decode JSON for flowID: \(flowID)")
            print("OnboardingSDK: Error: \(error)")
            print("OnboardingSDK: 🔄 Using fallback flow instead")
            return createFallbackFlow(flowID: flowID)
        }
    }
    
    // MARK: - Fallback Flow
    private func createFallbackFlow(flowID: String) -> OnboardingFlow {
        print("OnboardingSDK: 🔄 Creating fallback flow for: \(flowID)")
        
        // Create specific flow based on flowID
        if flowID == "bubulab_onboarding_v1" {
            return createBubulabFallbackFlow()
        }
        
        // Generic fallback
        return OnboardingFlow(
            flowID: flowID,
            appID: appID ?? "fallback_app",
            version: "1.0-fallback",
            pages: [
                OnboardingPage(
                    id: "fallback_welcome",
                    type: .textImage,
                    title: "Welcome! 👋",
                    subtitle: "We're setting up your experience..."
                ),
                OnboardingPage(
                    id: "fallback_complete",
                    type: .textImage,
                    title: "All Set! ✅",
                    subtitle: "You're ready to start using the app"
                )
            ]
        )
    }
    
    private func createBubulabFallbackFlow() -> OnboardingFlow {
        return OnboardingFlow(
            flowID: "bubulab_onboarding_v1",
            appID: appID ?? "bubulab_app",
            version: "1.0-fallback",
            pages: [
                OnboardingPage(
                    id: "welcome",
                    type: .textImage,
                    title: "Welcome to Bubulab! 🧸",
                    subtitle: "Your ultimate Labubu collection companion"
                ),
                OnboardingPage(
                    id: "collection_experience",
                    type: .selector,
                    title: "How experienced are you with Labubu collecting?",
                    key: "experience_level",
                    options: [
                        "Just starting out 🌱",
                        "Collecting for a while 📚",
                        "Experienced collector 🏆",
                        "Expert/Trader 💎"
                    ]
                ),
                OnboardingPage(
                    id: "collection_goal",
                    type: .selector,
                    title: "What's your main collecting goal?",
                    key: "collection_goal",
                    options: [
                        "Complete specific series",
                        "Collect rare pieces",
                        "Track collection value",
                        "Share with community",
                        "Investment purposes"
                    ]
                ),
                OnboardingPage(
                    id: "budget_range",
                    type: .slider,
                    title: "What's your monthly collecting budget?",
                    subtitle: "This helps us show relevant items",
                    key: "monthly_budget",
                    min: 0,
                    max: 500,
                    step: 25
                ),
                OnboardingPage(
                    id: "notifications",
                    type: .selector,
                    title: "How would you like to stay updated?",
                    key: "notification_preferences",
                    options: [
                        "New releases & restocks",
                        "Price alerts only",
                        "Community updates",
                        "All notifications",
                        "No notifications"
                    ]
                ),
                OnboardingPage(
                    id: "family_name",
                    type: .input,
                    title: "What should we call your collection family?",
                    subtitle: "Give your Labubu family a special name!",
                    placeholder: "e.g., The Bubu Squad",
                    inputType: .text,
                    key: "family_name"
                ),
                OnboardingPage(
                    id: "completion",
                    type: .textImage,
                    title: "You're all set! 🎉",
                    subtitle: "Let's start building your amazing Labubu collection together"
                )
            ]
        )
    }
    
    // MARK: - Remote Database Simulation
    /// Simulates fetching onboarding flow from remote database/API
    public func fetchFlowFromRemote(flowID: String, completion: @escaping (OnboardingFlow?) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let flow = self.loadFlowFromJSON(flowID: flowID)
            DispatchQueue.main.async {
                completion(flow)
            }
        }
    }
    
    /// Load flow from custom JSON data (for remote API responses)
    public func loadFlowFromData(_ jsonData: Data) -> OnboardingFlow? {
        do {
            let flow = try JSONDecoder().decode(OnboardingFlow.self, from: jsonData)
            print("OnboardingSDK: ✅ Loaded flow from custom JSON data")
            return flow
        } catch {
            print("OnboardingSDK: ❌ Failed to decode JSON data: \(error)")
            return nil
        }
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
        // All flows are now loaded dynamically from JSON files
        // This simulates loading from a database/CMS
        print("OnboardingSDK: ✅ Configured to load flows from JSON files (database simulation)")
    }
    
    // MARK: - Analytics
    private func trackUserInput(_ input: OnboardingUserInput) {
        // In production, send to analytics service
        print("OnboardingSDK: User input tracked - Key: \(input.key), Page: \(input.pageID)")
    }
    
    // MARK: - Utility Methods
    public func getAvailableFlows() -> [String] {
        // In production, this would query your database/API for available flows
        // For now, return known flow IDs from your JSON files
        return ["bubulab_onboarding_v1"]
    }
    
    public func getFlowInfo(flowID: String) -> OnboardingFlow? {
        return loadFlowFromJSON(flowID: flowID)
    }
}
