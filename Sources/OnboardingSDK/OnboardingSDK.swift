import Foundation
import SwiftUI

// MARK: - Main SDK Class
@available(iOS 15.0, *)
public class OnboardingSDK: ObservableObject {
    public static let shared = OnboardingSDK()
    
    @Published public var currentFlow: EnhancedOnboardingFlow?
    @Published public var userInputs: [String: Any] = [:]
    
    private var appID: String?
    
    private init() {}
    
    // MARK: - SDK Configuration
    public func configure(appID: String) {
        self.appID = appID
        print("OnboardingSDK: ✅ Configured with enhanced template system")
    }
    
    // MARK: - Flow Management
    
    /// Load enhanced flow with global template support
    public func loadFlow(flowID: String) -> EnhancedOnboardingFlow? {
        guard let appID = appID else {
            print("OnboardingSDK: App ID not configured. Call configure(appID:) first.")
            return nil
        }
        
        return loadEnhancedFlowFromJSON(flowID: flowID)
    }
    
    /// Load flow with specific template applied
    public func loadFlowWithTemplate(flowID: String, templateID: String) -> EnhancedOnboardingFlow? {
        guard let appID = appID else {
            print("OnboardingSDK: App ID not configured. Call configure(appID:) first.")
            return nil
        }
        
        // First try to load enhanced flow
        if let enhancedFlow = loadEnhancedFlowFromJSON(flowID: flowID) {
            // Replace the template if specified
            let updatedFlow = EnhancedOnboardingFlow(
                flowID: enhancedFlow.flowID,
                appID: enhancedFlow.appID,
                version: enhancedFlow.version,
                globalTemplate: getTemplate(templateID: templateID) ?? enhancedFlow.globalTemplate,
                pages: enhancedFlow.pages
            )
            return updatedFlow
        }
        
        return nil
    }
    
    // MARK: - Enhanced JSON Loading
    
    private func loadEnhancedFlowFromJSON(flowID: String) -> EnhancedOnboardingFlow? {
        let bundle = Bundle.module
        
        // Try enhanced flow first (with _enhanced suffix)
        let enhancedFlowID = "\(flowID)_enhanced_v1"
        let possibleURLs = [
            bundle.url(forResource: enhancedFlowID, withExtension: "json", subdirectory: "Resources"),
            bundle.url(forResource: enhancedFlowID, withExtension: "json"), // Root level
        ]
        
        print("OnboardingSDK: 🔍 Searching for enhanced JSON file: \(enhancedFlowID).json")
        
        guard let url = possibleURLs.compactMap({ $0 }).first else {
            print("OnboardingSDK: ❌ No enhanced JSON file found for flowID: \(enhancedFlowID)")
            return createFallbackEnhancedFlow(flowID: flowID)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let enhancedFlow = try JSONDecoder().decode(EnhancedOnboardingFlow.self, from: data)
            print("OnboardingSDK: ✅ Successfully loaded enhanced flow '\(flowID)' from JSON file")
            print("OnboardingSDK: Enhanced JSON path: \(url.path)")
            
            // Preload images for better performance
            preloadImagesForEnhancedFlow(enhancedFlow)
            
            return enhancedFlow
        } catch {
            print("OnboardingSDK: ❌ Failed to decode enhanced JSON for flowID: \(enhancedFlowID)")
            print("OnboardingSDK: Error: \(error)")
            print("OnboardingSDK: 🔄 Using fallback enhanced flow instead")
            return createFallbackEnhancedFlow(flowID: flowID)
        }
    }
    
    // MARK: - Simple Fallback Flow
    
    private func createFallbackEnhancedFlow(flowID: String) -> EnhancedOnboardingFlow {
        print("OnboardingSDK: 🔄 Creating simple fallback flow for: \(flowID)")
        
        // Simple one-screen fallback
        return EnhancedOnboardingFlow(
            flowID: flowID,
            appID: appID ?? "fallback_app",
            version: "1.0-fallback",
            globalTemplate: PredefinedTemplates.modern,
            pages: [
                EnhancedOnboardingPage(
                    id: "fallback_error",
                    pageType: .content,
                    contentType: .textImage,
                    title: "Oops! Something went wrong 😅",
                    subtitle: "Please check your internet connection and try again"
                )
            ]
        )
    }
    
    // MARK: - Remote Database Simulation
    
    /// Simulates fetching onboarding flow from remote database/API
    public func fetchFlowFromRemote(flowID: String, completion: @escaping (EnhancedOnboardingFlow?) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let flow = self.loadEnhancedFlowFromJSON(flowID: flowID)
            
            // Preload images if flow loaded successfully
            if let flow = flow {
                self.preloadImagesForEnhancedFlow(flow)
            }
            
            DispatchQueue.main.async {
                completion(flow)
            }
        }
    }
    
    /// Load flow from custom JSON data (for remote API responses)
    public func loadFlowFromData(_ jsonData: Data) -> EnhancedOnboardingFlow? {
        do {
            let flow = try JSONDecoder().decode(EnhancedOnboardingFlow.self, from: jsonData)
            print("OnboardingSDK: ✅ Loaded enhanced flow from custom JSON data")
            
            // Preload images for better performance
            preloadImagesForEnhancedFlow(flow)
            
            return flow
        } catch {
            print("OnboardingSDK: ❌ Failed to decode enhanced JSON data: \(error)")
            return nil
        }
    }
    
    // MARK: - Onboarding Management
    
    /// Start enhanced onboarding
    public func startOnboarding(flowID: String, completion: @escaping (EnhancedOnboardingFlow?) -> Void) {
        if let flow = loadFlow(flowID: flowID) {
            currentFlow = flow
            userInputs.removeAll()
            completion(flow)
        } else {
            completion(nil)
        }
    }
    
    /// Start onboarding with specific template applied
    public func startOnboardingWithTemplate(flowID: String, templateID: String, completion: @escaping (EnhancedOnboardingFlow?) -> Void) {
        if let enhancedFlow = loadFlowWithTemplate(flowID: flowID, templateID: templateID) {
            currentFlow = enhancedFlow
            userInputs.removeAll()
            completion(enhancedFlow)
        } else {
            completion(nil)
        }
    }
    
    /// Create enhanced ViewModel for SwiftUI integration
    @MainActor
    public func createViewModel(
        flowID: String,
        templateID: String? = nil,
        onCompletion: @escaping ([String: Any]) -> Void
    ) -> EnhancedOnboardingViewModel? {
        
        let enhancedFlow: EnhancedOnboardingFlow?
        
        if let templateID = templateID {
            enhancedFlow = loadFlowWithTemplate(flowID: flowID, templateID: templateID)
        } else {
            enhancedFlow = loadFlow(flowID: flowID)
        }
        
        guard let flow = enhancedFlow else { return nil }
        
        currentFlow = flow
        return EnhancedOnboardingViewModel(flow: flow, onCompletion: onCompletion)
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
    
    // MARK: - Utility Methods
    
    public func getAvailableFlows() -> [String] {
        // In production, this would query your database/API for available flows
        return ["bubulab_onboarding_v1"]
    }
    
    public func getFlowInfo(flowID: String) -> EnhancedOnboardingFlow? {
        return loadEnhancedFlowFromJSON(flowID: flowID)
    }
    
    // MARK: - Template Management
    
    /// Get all available predefined templates
    public func getAvailableTemplates() -> [GlobalTemplate] {
        return PredefinedTemplates.allTemplates
    }
    
    /// Get specific template by ID
    public func getTemplate(templateID: String) -> GlobalTemplate? {
        return PredefinedTemplates.allTemplates.first { $0.templateID == templateID }
    }
    
    /// Preview how a flow would look with different templates
    public func previewFlowWithTemplate(flowID: String, templateID: String) -> EnhancedOnboardingFlow? {
        return loadFlowWithTemplate(flowID: flowID, templateID: templateID)
    }
    
    // MARK: - Cache Management
    
    /// Clear image cache to free up storage space
    public func clearImageCache() {
        ImageCache.shared.clearCache()
    }
    
    // MARK: - Private Methods
    
    private func preloadImagesForEnhancedFlow(_ flow: EnhancedOnboardingFlow) {
        let imageURLs = flow.pages.compactMap { $0.imageURL }
        if !imageURLs.isEmpty {
            print("OnboardingSDK: 🔄 Preloading \(imageURLs.count) images for enhanced flow...")
            for imageURL in imageURLs {
                ImageCache.shared.preloadImage(from: imageURL)
            }
        }
    }
    
    // MARK: - Analytics
    
    private func trackUserInput(_ input: OnboardingUserInput) {
        // In production, send to analytics service
        print("OnboardingSDK: User input tracked - Key: \(input.key), Page: \(input.pageID)")
    }
}

// MARK: - Supporting Models

/// User input collection for analytics
public struct OnboardingUserInput {
    public let key: String
    public let value: Any
    public let pageID: String
    public let timestamp: Date
    
    public init(key: String, value: Any, pageID: String, timestamp: Date = Date()) {
        self.key = key
        self.value = value
        self.pageID = pageID
        self.timestamp = timestamp
    }
}

