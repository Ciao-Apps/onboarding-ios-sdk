import Foundation
import SwiftUI

// MARK: - Global Template System

/// Simplified global template for Craft.js-based onboarding
@available(iOS 15.0, *)
public struct GlobalTemplate: Codable {
    public let templateID: String
    public let name: String
    public let primaryColor: String?
    public let secondaryColor: String?
    public let backgroundColor: String?
    public let textColor: String?
    public let cornerRadius: Double?
    public let buttonStyle: ButtonStyleConfig?
    public let spacing: IOSSpacingConfig?
    
    public init(
        templateID: String,
        name: String,
        primaryColor: String? = nil,
        secondaryColor: String? = nil,
        backgroundColor: String? = nil,
        textColor: String? = nil,
        cornerRadius: Double? = nil,
        buttonStyle: ButtonStyleConfig? = nil,
        spacing: IOSSpacingConfig? = nil
    ) {
        self.templateID = templateID
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.buttonStyle = buttonStyle
        self.spacing = spacing
    }
}

/// Simplified spacing configuration for iOS
public struct IOSSpacingConfig: Codable {
    public let small: Double
    public let medium: Double
    public let large: Double
    public let extraLarge: Double
    
    public init(small: Double, medium: Double, large: Double, extraLarge: Double) {
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }
}

// MARK: - Button Configuration

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
    public let backgroundImage: String?  // New: Support for background images
    public let backgroundSize: String?   // New: Background sizing (cover, contain, etc.)
    public let backgroundPosition: String? // New: Background positioning
    public let craftContent: String?     // New: Serialized Craft.js content for advanced layouts
    
    public init(
        backgroundColor: String? = nil,
        textColor: String? = nil,
        primaryColor: String? = nil,
        spacing: Double? = nil,
        buttonColor: String? = nil,
        backgroundImage: String? = nil,
        backgroundSize: String? = nil,
        backgroundPosition: String? = nil,
        craftContent: String? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.primaryColor = primaryColor
        self.spacing = spacing
        self.buttonColor = buttonColor
        self.backgroundImage = backgroundImage
        self.backgroundSize = backgroundSize
        self.backgroundPosition = backgroundPosition
        self.craftContent = craftContent
    }
}

// MARK: - Simple Default Template

@available(iOS 15.0, *)
public enum DefaultTemplate {
    public static let basic = GlobalTemplate(
        templateID: "basic",
        name: "Basic",
        primaryColor: "#007AFF",
        secondaryColor: "#5856D6",
        backgroundColor: "#FFFFFF",
        textColor: "#1D1D1F",
        cornerRadius: 16,
        buttonStyle: ButtonStyleConfig(
            primaryBackgroundColor: "#007AFF",
            primaryTextColor: "#FFFFFF",
            borderRadius: 16,
            height: 44
        ),
        spacing: IOSSpacingConfig(small: 8, medium: 16, large: 24, extraLarge: 32)
    )
}

// MARK: - Missing Types for Compatibility

/// Button configuration
public struct ButtonConfig: Codable {
    public let title: String
    public let action: String
    public let style: OnboardingButtonStyle?
    
    public init(title: String, action: String, style: OnboardingButtonStyle? = nil) {
        self.title = title
        self.action = action
        self.style = style
    }
}

/// Button styling
public struct OnboardingButtonStyle: Codable {
    public let backgroundColor: String?
    public let textColor: String?
    public let cornerRadius: Double?
    
    public init(backgroundColor: String? = nil, textColor: String? = nil, cornerRadius: Double? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
    }
}

/// Content types (for backward compatibility in JSON)
public enum OnboardingPageType: String, Codable, CaseIterable {
    case textImage = "text_image"
    case input = "input"
    case selector = "selector"
    case slider = "slider"
}

/// Input types
public enum InputType: String, Codable {
    case text = "text"
    case number = "number"
    case email = "email"
    case password = "password"
}

// MARK: - Color Extension for Hex Support


