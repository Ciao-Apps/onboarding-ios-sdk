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
        // Try to find JSON file for this flow
        guard let url = Bundle.module.url(forResource: flowID, withExtension: "json", subdirectory: "resources") else {
            print("OnboardingSDK: No JSON file found for flowID: \(flowID)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonFlow = try JSONDecoder().decode(OnboardingFlow.self, from: data)
            print("OnboardingSDK: ✅ Loaded flow '\(flowID)' from JSON file (simulating database)")
            return jsonFlow
        } catch {
            print("OnboardingSDK: ❌ Failed to load JSON for flowID: \(flowID), error: \(error)")
            return nil
        }
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
