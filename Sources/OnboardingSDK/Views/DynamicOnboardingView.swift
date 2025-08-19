import SwiftUI

/// A lean, drop-in onboarding view that fetches flows from the SDK
/// Just add this to your existing app structure - no changes needed
@available(iOS 15.0, *)
public struct DynamicOnboardingView: View {
    let appID: String
    let flowID: String
    let onCompletion: ([String: Any]) -> Void
    
    @State private var currentFlow: OnboardingFlow?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    /// Simple drop-in onboarding view
    /// - Parameters:
    ///   - appID: Your app identifier
    ///   - flowID: The onboarding flow to load
    ///   - onCompletion: Called when user completes onboarding with their input data
    public init(
        appID: String,
        flowID: String,
        onCompletion: @escaping ([String: Any]) -> Void
    ) {
        self.appID = appID
        self.flowID = flowID
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if let errorMessage = errorMessage {
                ErrorView(message: errorMessage) {
                    loadOnboardingFlow()
                }
            } else if let flow = currentFlow {
                OnboardingView(flow: flow, onCompletion: onCompletion)
            } else {
                ErrorView(message: "Onboarding flow not available") {
                    loadOnboardingFlow()
                }
            }
        }
        .onAppear {
            loadOnboardingFlow()
        }
    }
    
    private func loadOnboardingFlow() {
        isLoading = true
        errorMessage = nil
        
        // Configure SDK
        OnboardingSDK.shared.configure(appID: appID)
        
        // 🎯 Try to fetch from "remote database" first (simulated)
        OnboardingSDK.shared.fetchFlowFromRemote(flowID: flowID) { flow in
            if let flow = flow {
                self.currentFlow = flow
                self.isLoading = false
                print("DynamicOnboardingView: ✅ Loaded from remote database simulation")
            } else {
                // Fallback to normal loading
                print("DynamicOnboardingView: Remote fetch failed, trying fallback...")
                self.loadFromFallback()
            }
        }
    }
    
    private func loadFromFallback() {
        OnboardingSDK.shared.startOnboarding(flowID: flowID) { flow in
            DispatchQueue.main.async {
                self.isLoading = false
                if let flow = flow {
                    self.currentFlow = flow
                    print("DynamicOnboardingView: ✅ Loaded from fallback (hardcoded flows)")
                } else {
                    self.errorMessage = "Failed to load onboarding flow from all sources"
                }
            }
        }
    }
}

// MARK: - Helper Views

@available(iOS 15.0, *)
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading onboarding...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

@available(iOS 15.0, *)
private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(RetryButtonStyle())
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

@available(iOS 15.0, *)
private struct RetryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 120, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

// MARK: - Alternative: Even Simpler Hook
/// Ultra-minimal onboarding hook - just returns the view when ready
@available(iOS 15.0, *)
public struct OnboardingHook {
    public static func loadOnboarding(
        appID: String,
        flowID: String,
        completion: @escaping (OnboardingView?) -> Void
    ) {
        OnboardingSDK.shared.configure(appID: appID)
        OnboardingSDK.shared.startOnboarding(flowID: flowID) { flow in
            DispatchQueue.main.async {
                if let flow = flow {
                    let onboardingView = OnboardingView(flow: flow) { results in
                        // Handle completion in the calling code
                    }
                    completion(onboardingView)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
