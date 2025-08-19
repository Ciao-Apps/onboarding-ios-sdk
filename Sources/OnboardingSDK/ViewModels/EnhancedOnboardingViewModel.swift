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
        Color(hex: template.backgroundColor) ?? Color(.systemBackground)
    }
    
    public var templatePrimaryColor: Color {
        Color(hex: template.primaryColor) ?? Color.blue
    }
    
    public var templateSecondaryColor: Color {
        Color(hex: template.secondaryColor) ?? Color.gray
    }
    
    public var templateTextColor: Color {
        // Check for page-specific override
        if let override = currentPage?.overrides?.textColor {
            return Color(hex: override) ?? defaultTemplateTextColor
        }
        return defaultTemplateTextColor
    }
    
    private var defaultTemplateTextColor: Color {
        Color(hex: template.textColor) ?? Color.primary
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
        Color(hex: template.buttonStyle?.primaryBackgroundColor) ?? templatePrimaryColor
    }
    
    public var primaryButtonTextColor: Color {
        Color(hex: template.buttonStyle?.primaryTextColor) ?? Color.white
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

// MARK: - Convenience Methods for Template Creation

@available(iOS 15.0, *)
extension EnhancedOnboardingViewModel {
    
    /// Create ViewModel with predefined template
    public static func withTemplate(
        _ templateID: String,
        flow: OnboardingFlow,
        onCompletion: @escaping ([String: Any]) -> Void
    ) -> EnhancedOnboardingViewModel? {
        
        guard let template = PredefinedTemplates.allTemplates.first(where: { $0.templateID == templateID }) else {
            return nil
        }
        
        // Convert old flow to enhanced flow
        let enhancedPages = flow.pages.map { page in
            let pageType: PageType = determinePageType(for: page)
            
            return EnhancedOnboardingPage(
                id: page.id,
                pageType: pageType,
                contentType: page.type,
                title: page.title,
                subtitle: page.subtitle,
                imageURL: page.imageURL,
                placeholder: page.placeholder,
                inputType: page.inputType,
                key: page.key,
                options: page.options,
                min: page.min,
                max: page.max,
                step: page.step,
                button: page.button,
                overrides: convertStyleToOverrides(page.style)
            )
        }
        
        let enhancedFlow = EnhancedOnboardingFlow(
            flowID: flow.flowID,
            appID: flow.appID,
            version: flow.version,
            globalTemplate: template,
            pages: enhancedPages
        )
        
        return EnhancedOnboardingViewModel(flow: enhancedFlow, onCompletion: onCompletion)
    }
    
    private static func determinePageType(for page: OnboardingPage) -> PageType {
        // Logic to determine page type based on content
        if page.imageURL != nil && (page.type == .textImage) {
            return .hero
        } else if page.type == .input || page.type == .slider {
            return .form
        } else if page.id.contains("completion") || page.id.contains("finish") {
            return .completion
        } else {
            return .content
        }
    }
    
    private static func convertStyleToOverrides(_ style: PageStyle?) -> PageOverrides? {
        guard let style = style else { return nil }
        
        return PageOverrides(
            backgroundColor: style.backgroundColor,
            textColor: style.titleColor,
            spacing: style.spacing
        )
    }
}
