import Foundation
import SwiftUI

// MARK: - Global Template System

/// Global template configuration that applies to the entire onboarding flow
@available(iOS 15.0, *)
public struct GlobalTemplate: Codable {
    public let templateID: String
    public let name: String
    public let primaryColor: String?
    public let secondaryColor: String?
    public let backgroundColor: String?
    public let textColor: String?
    public let fontFamily: String?
    public let cornerRadius: Double?
    public let navigationStyle: NavigationStyle?
    public let buttonStyle: ButtonStyleConfig?
    public let spacing: SpacingConfig?
    
    public init(
        templateID: String,
        name: String,
        primaryColor: String? = nil,
        secondaryColor: String? = nil,
        backgroundColor: String? = nil,
        textColor: String? = nil,
        fontFamily: String? = nil,
        cornerRadius: Double? = nil,
        navigationStyle: NavigationStyle? = nil,
        buttonStyle: ButtonStyleConfig? = nil,
        spacing: SpacingConfig? = nil
    ) {
        self.templateID = templateID
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.fontFamily = fontFamily
        self.cornerRadius = cornerRadius
        self.navigationStyle = navigationStyle
        self.buttonStyle = buttonStyle
        self.spacing = spacing
    }
}

/// Navigation style configuration
public enum NavigationStyle: String, Codable, CaseIterable {
    case classic = "classic"           // Bottom buttons with progress bar
    case floating = "floating"         // Floating action buttons
    case minimal = "minimal"           // Subtle text-based navigation
    case immersive = "immersive"       // Overlay navigation on content
    case sidebar = "sidebar"           // Side navigation panel
    
    public var displayName: String {
        switch self {
        case .classic: return "Classic Bottom"
        case .floating: return "Floating Buttons"
        case .minimal: return "Minimal Text"
        case .immersive: return "Immersive Overlay"
        case .sidebar: return "Sidebar"
        }
    }
}

/// Button styling configuration
public struct ButtonStyleConfig: Codable {
    public let primaryBackgroundColor: String?
    public let primaryTextColor: String?
    public let secondaryBackgroundColor: String?
    public let secondaryTextColor: String?
    public let borderRadius: Double?
    public let height: Double?
    
    public init(
        primaryBackgroundColor: String? = nil,
        primaryTextColor: String? = nil,
        secondaryBackgroundColor: String? = nil,
        secondaryTextColor: String? = nil,
        borderRadius: Double? = nil,
        height: Double? = nil
    ) {
        self.primaryBackgroundColor = primaryBackgroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.secondaryTextColor = secondaryTextColor
        self.borderRadius = borderRadius
        self.height = height
    }
}

/// Spacing configuration
public struct SpacingConfig: Codable {
    public let small: Double?
    public let medium: Double?
    public let large: Double?
    public let extraLarge: Double?
    
    public init(small: Double? = nil, medium: Double? = nil, large: Double? = nil, extraLarge: Double? = nil) {
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }
}

// MARK: - Page Types

/// Page type defines the content structure and layout
public enum PageType: String, Codable, CaseIterable {
    case hero = "hero"                 // Full-screen hero with image/video
    case content = "content"           // Standard content page
    case form = "form"                 // Form-focused page
    case feature = "feature"           // Feature highlight page
    case completion = "completion"     // Final completion page
    
    public var displayName: String {
        switch self {
        case .hero: return "Hero Page"
        case .content: return "Content Page"
        case .form: return "Form Page"
        case .feature: return "Feature Page"
        case .completion: return "Completion Page"
        }
    }
    
    public var description: String {
        switch self {
        case .hero: return "Full-screen with background image/video"
        case .content: return "Standard content with text and images"
        case .form: return "Input-focused with form elements"
        case .feature: return "Highlight key features or benefits"
        case .completion: return "Final success/completion page"
        }
    }
}

// MARK: - Enhanced Flow Model

/// Enhanced onboarding flow with global template
public struct EnhancedOnboardingFlow: Codable {
    public let flowID: String
    public let appID: String
    public let version: String
    public let globalTemplate: GlobalTemplate
    public let pages: [EnhancedOnboardingPage]
    
    public init(flowID: String, appID: String, version: String, globalTemplate: GlobalTemplate, pages: [EnhancedOnboardingPage]) {
        self.flowID = flowID
        self.appID = appID
        self.version = version
        self.globalTemplate = globalTemplate
        self.pages = pages
    }
}

/// Enhanced page with page type instead of individual template
public struct EnhancedOnboardingPage: Codable, Identifiable {
    public let id: String
    public let pageType: PageType
    public let contentType: OnboardingPageType  // What content to show (text, input, selector, etc.)
    public let title: String
    public let subtitle: String?
    public let imageURL: String?
    public let placeholder: String?
    public let inputType: InputType?
    public let key: String?
    public let options: [String]?
    public let min: Double?
    public let max: Double?
    public let step: Double?
    public let button: ButtonConfig?
    public let overrides: PageOverrides?  // Override global template settings
    
    public init(
        id: String,
        pageType: PageType,
        contentType: OnboardingPageType,
        title: String,
        subtitle: String? = nil,
        imageURL: String? = nil,
        placeholder: String? = nil,
        inputType: InputType? = nil,
        key: String? = nil,
        options: [String]? = nil,
        min: Double? = nil,
        max: Double? = nil,
        step: Double? = nil,
        button: ButtonConfig? = nil,
        overrides: PageOverrides? = nil
    ) {
        self.id = id
        self.pageType = pageType
        self.contentType = contentType
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.inputType = inputType
        self.key = key
        self.options = options
        self.min = min
        self.max = max
        self.step = step
        self.button = button
        self.overrides = overrides
    }
}

/// Page-specific overrides for global template
public struct PageOverrides: Codable {
    public let backgroundColor: String?
    public let textColor: String?
    public let primaryColor: String?
    public let spacing: Double?
    public let buttonColor: String?
    
    public init(
        backgroundColor: String? = nil,
        textColor: String? = nil,
        primaryColor: String? = nil,
        spacing: Double? = nil,
        buttonColor: String? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.primaryColor = primaryColor
        self.spacing = spacing
        self.buttonColor = buttonColor
    }
}

// MARK: - Predefined Templates

@available(iOS 15.0, *)
public enum PredefinedTemplates {
    public static let modern = GlobalTemplate(
        templateID: "modern",
        name: "Modern",
        primaryColor: "#007AFF",
        secondaryColor: "#5856D6",
        backgroundColor: "#FFFFFF",
        textColor: "#1D1D1F",
        cornerRadius: 16,
        navigationStyle: .floating,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#007AFF",
            primaryTextColor: "#FFFFFF",
            borderRadius: 25,
            height: 52
        ),
        spacing: SpacingConfig(small: 8, medium: 16, large: 24, extraLarge: 32)
    )
    
    public static let minimal = GlobalTemplate(
        templateID: "minimal",
        name: "Minimal",
        primaryColor: "#000000",
        secondaryColor: "#6B6B6B",
        backgroundColor: "#FFFFFF",
        textColor: "#1D1D1F",
        cornerRadius: 8,
        navigationStyle: .minimal,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#000000",
            primaryTextColor: "#FFFFFF",
            borderRadius: 8,
            height: 48
        ),
        spacing: SpacingConfig(small: 12, medium: 20, large: 32, extraLarge: 48)
    )
    
    public static let vibrant = GlobalTemplate(
        templateID: "vibrant",
        name: "Vibrant",
        primaryColor: "#FF3B30",
        secondaryColor: "#FF9500",
        backgroundColor: "#F2F2F7",
        textColor: "#1D1D1F",
        cornerRadius: 20,
        navigationStyle: .immersive,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#FF3B30",
            primaryTextColor: "#FFFFFF",
            borderRadius: 30,
            height: 56
        ),
        spacing: SpacingConfig(small: 10, medium: 18, large: 28, extraLarge: 40)
    )
    
    public static let corporate = GlobalTemplate(
        templateID: "corporate",
        name: "Corporate",
        primaryColor: "#0066CC",
        secondaryColor: "#6B73FF",
        backgroundColor: "#F8F9FA",
        textColor: "#2E3A59",
        cornerRadius: 12,
        navigationStyle: .classic,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#0066CC",
            primaryTextColor: "#FFFFFF",
            borderRadius: 12,
            height: 50
        ),
        spacing: SpacingConfig(small: 8, medium: 16, large: 24, extraLarge: 36)
    )
    
    public static let playful = GlobalTemplate(
        templateID: "playful",
        name: "Playful",
        primaryColor: "#FF6B9D",
        secondaryColor: "#FFD93D",
        backgroundColor: "#FFF5F8",
        textColor: "#2D1B4E",
        cornerRadius: 24,
        navigationStyle: .floating,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#FF6B9D",
            primaryTextColor: "#FFFFFF",
            borderRadius: 30,
            height: 54
        ),
        spacing: SpacingConfig(small: 12, medium: 20, large: 30, extraLarge: 44)
    )
    
    public static let allTemplates: [GlobalTemplate] = [
        modern, minimal, vibrant, corporate, playful
    ]
}
