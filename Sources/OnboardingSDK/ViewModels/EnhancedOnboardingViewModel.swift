import Foundation
import SwiftUI

/// Enhanced ViewModel with global template system
@available(iOS 15.0, *)
@MainActor
public class EnhancedOnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentPageIndex = 0
    @Published public var userInputs: [String: Any] = [:]
    @Published public var isNavigating = false
    @Published public var isLoading = false
    
    // MARK: - Public Properties
    public let flow: EnhancedOnboardingFlow
    public let template: GlobalTemplate
    
    // MARK: - Private Properties
    private let onCompletion: ([String: Any]) -> Void
    private let sdk = OnboardingSDK.shared
    
    // MARK: - Computed Properties
    public var currentPage: EnhancedOnboardingPage? {
        guard currentPageIndex >= 0 && currentPageIndex < flow.pages.count else { return nil }
        return flow.pages[currentPageIndex]
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
        if let key = page.key, page.contentType != .textImage {
            return userInputs[key] != nil
        }
        
        return true
    }
    
    public var progress: Double {
        guard !flow.pages.isEmpty else { return 0 }
        return Double(currentPageIndex + 1) / Double(flow.pages.count)
    }
    
    // MARK: - Template-based Styling
    
    public var currentPageBackgroundColor: Color {
        // Check for page-specific override first
        if let override = currentPage?.overrides?.backgroundColor {
            return Color(hex: override) ?? templateBackgroundColor
        }
        return templateBackgroundColor
    }
    
    public var templateBackgroundColor: Color {
        if let bgColor = template.backgroundColor {
            return Color(hex: bgColor) ?? Color(.systemBackground)
        }
        return Color(.systemBackground)
    }
    
    public var templatePrimaryColor: Color {
        if let primaryColor = template.primaryColor {
            return Color(hex: primaryColor) ?? Color.blue
        }
        return Color.blue
    }
    
    public var templateSecondaryColor: Color {
        if let secondaryColor = template.secondaryColor {
            return Color(hex: secondaryColor) ?? Color.gray
        }
        return Color.gray
    }
    
    public var templateTextColor: Color {
        // Check for page-specific override
        if let override = currentPage?.overrides?.textColor {
            return Color(hex: override) ?? defaultTemplateTextColor
        }
        return defaultTemplateTextColor
    }
    
    private var defaultTemplateTextColor: Color {
        if let textColor = template.textColor {
            return Color(hex: textColor) ?? Color.primary
        }
        return Color.primary
    }
    
    public var templateCornerRadius: CGFloat {
        CGFloat(template.cornerRadius ?? 12)
    }
    
    public var navigationStyle: NavigationStyle {
        template.navigationStyle ?? .classic
    }
    
    // MARK: - Spacing
    
    public var smallSpacing: CGFloat {
        CGFloat(template.spacing?.small ?? 8)
    }
    
    public var mediumSpacing: CGFloat {
        CGFloat(template.spacing?.medium ?? 16)
    }
    
    public var largeSpacing: CGFloat {
        CGFloat(template.spacing?.large ?? 24)
    }
    
    public var extraLargeSpacing: CGFloat {
        CGFloat(template.spacing?.extraLarge ?? 32)
    }
    
    // MARK: - Button Styling
    
    public var primaryButtonBackgroundColor: Color {
        if let override = currentPage?.overrides?.primaryColor {
            return Color(hex: override) ?? defaultPrimaryButtonColor
        }
        return defaultPrimaryButtonColor
    }
    
    private var defaultPrimaryButtonColor: Color {
        if let buttonBgColor = template.buttonStyle?.primaryBackgroundColor {
            return Color(hex: buttonBgColor) ?? templatePrimaryColor
        }
        return templatePrimaryColor
    }
    
    public var primaryButtonTextColor: Color {
        if let buttonTextColor = template.buttonStyle?.primaryTextColor {
            return Color(hex: buttonTextColor) ?? Color.white
        }
        return Color.white
    }
    
    public var buttonCornerRadius: CGFloat {
        CGFloat(template.buttonStyle?.borderRadius ?? template.cornerRadius ?? 12)
    }
    
    public var buttonHeight: CGFloat {
        CGFloat(template.buttonStyle?.height ?? 52)
    }
    
    // MARK: - Initialization
    public init(flow: EnhancedOnboardingFlow, onCompletion: @escaping ([String: Any]) -> Void) {
        self.flow = flow
        self.template = flow.globalTemplate
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