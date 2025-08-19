import Foundation
import SwiftUI

/// ViewModel for managing onboarding flow state and navigation
@available(iOS 15.0, *)
@MainActor
public class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentPageIndex = 0
    @Published public var userInputs: [String: Any] = [:]
    @Published public var isNavigating = false
    @Published public var isLoading = false
    
    // MARK: - Public Properties
    public let flow: OnboardingFlow
    
    // MARK: - Private Properties
    private let onCompletion: ([String: Any]) -> Void
    private let sdk = OnboardingSDK.shared
    
    // MARK: - Computed Properties
    public var currentPage: OnboardingPage? {
        guard currentPageIndex >= 0 && currentPageIndex < flow.pages.count else { return nil }
        return flow.pages[currentPageIndex]
    }
    
    public var selectedTemplate: LayoutTemplate {
        guard let templateName = currentPage?.style?.template else { return .classic }
        return LayoutTemplate(rawValue: templateName) ?? .classic
    }
    
    public var isFirstPage: Bool {
        currentPageIndex == 0
    }
    
    public var isLastPage: Bool {
        guard !flow.pages.isEmpty else { return true }
        return currentPageIndex == flow.pages.count - 1
    }
    
    public var canGoBack: Bool {
        currentPageIndex > 0 && !flow.pages.isEmpty && !isNavigating
    }
    
    public var canGoForward: Bool {
        currentPageIndex < flow.pages.count - 1 && !flow.pages.isEmpty && !isNavigating && canProceed
    }
    
    public var canProceed: Bool {
        guard let page = currentPage else { return false }
        
        // Check if required input is filled
        if let key = page.key, page.type != .textImage {
            return userInputs[key] != nil
        }
        
        return true
    }
    
    public var progress: Double {
        guard !flow.pages.isEmpty else { return 0 }
        return Double(currentPageIndex + 1) / Double(flow.pages.count)
    }
    
    public var currentPageBackgroundColor: Color {
        guard let page = currentPage,
              let bgColor = page.style?.backgroundColor else {
            return Color(.systemBackground)
        }
        return Color(hex: bgColor) ?? Color(.systemBackground)
    }
    
    // MARK: - Initialization
    public init(flow: OnboardingFlow, onCompletion: @escaping ([String: Any]) -> Void) {
        self.flow = flow
        self.onCompletion = onCompletion
    }
    
    // MARK: - Navigation Methods
    public func goBack() {
        guard canGoBack else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isNavigating = true
            currentPageIndex = max(0, currentPageIndex - 1)
        }
        
        resetNavigationLock()
    }
    
    public func goForward() {
        guard canGoForward else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isNavigating = true
            currentPageIndex = min(flow.pages.count - 1, currentPageIndex + 1)
        }
        
        resetNavigationLock()
    }
    
    public func goToPage(_ index: Int) {
        guard index >= 0 && index < flow.pages.count && !isNavigating else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isNavigating = true
            currentPageIndex = index
        }
        
        resetNavigationLock()
    }
    
    public func finishOnboarding() {
        isLoading = true
        
        sdk.finishOnboarding { [weak self] finalInputs in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                self.onCompletion(finalInputs.isEmpty ? self.userInputs : finalInputs)
            }
        }
    }
    
    // MARK: - Input Management
    public func updateUserInput(key: String, value: Any) {
        guard let page = currentPage else { return }
        
        userInputs[key] = value
        sdk.updateUserInput(key: key, value: value, pageID: page.id)
    }
    
    // MARK: - Private Methods
    private func resetNavigationLock() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isNavigating = false
        }
    }
}

// MARK: - Layout Template Enum
public enum LayoutTemplate: String, CaseIterable {
    case classic = "classic"
    case modern = "modern"
    case minimal = "minimal"
    case cardStack = "card_stack"
    case fullScreen = "full_screen"
    case floating = "floating"
    case sidebar = "sidebar"
    case wizard = "wizard"
    case magazine = "magazine"
    case mobile = "mobile"
    
    public var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .modern: return "Modern"
        case .minimal: return "Minimal"
        case .cardStack: return "Card Stack"
        case .fullScreen: return "Full Screen"
        case .floating: return "Floating"
        case .sidebar: return "Sidebar"
        case .wizard: return "Wizard"
        case .magazine: return "Magazine"
        case .mobile: return "Mobile"
        }
    }
    
    public var description: String {
        switch self {
        case .classic: return "Traditional navigation at bottom"
        case .modern: return "Floating buttons with smooth animations"
        case .minimal: return "Clean design with subtle navigation"
        case .cardStack: return "Card-based layout with stack transitions"
        case .fullScreen: return "Immersive full-screen with overlay navigation"
        case .floating: return "Floating action buttons"
        case .sidebar: return "Side navigation with progress"
        case .wizard: return "Step-by-step wizard style"
        case .magazine: return "Magazine-style layout"
        case .mobile: return "Mobile-first responsive design"
        }
    }
}
