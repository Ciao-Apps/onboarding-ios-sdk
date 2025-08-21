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
    public let navigationLayout: NavigationLayoutConfig?
    
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
        spacing: SpacingConfig? = nil,
        navigationLayout: NavigationLayoutConfig? = nil
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
        self.navigationLayout = navigationLayout
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

// MARK: - Enhanced Navigation System

/// Progress indicator configuration
public struct ProgressIndicatorConfig: Codable {
    public let type: ProgressType
    public let position: ProgressPosition
    public let height: Double?
    public let size: Double?
    public let spacing: Double?
    public let showStepCounter: Bool?
    public let animation: ProgressAnimation?
    
    public init(
        type: ProgressType,
        position: ProgressPosition = .top,
        height: Double? = nil,
        size: Double? = nil,
        spacing: Double? = nil,
        showStepCounter: Bool? = nil,
        animation: ProgressAnimation? = nil
    ) {
        self.type = type
        self.position = position
        self.height = height
        self.size = size
        self.spacing = spacing
        self.showStepCounter = showStepCounter
        self.animation = animation
    }
}

/// Progress indicator types
public enum ProgressType: String, Codable, CaseIterable {
    case line = "line"                 // Horizontal progress line
    case dots = "dots"                 // Circular dots
    case bubbles = "bubbles"           // Animated bubbles
    case stepCounter = "step_counter"  // "2 of 5" text
    case gradient = "gradient"         // Gradient progress bar
    case none = "none"                 // No progress indicator
}

/// Progress indicator positions
public enum ProgressPosition: String, Codable, CaseIterable {
    case top = "top"
    case bottom = "bottom"
    case topSafe = "top_safe"         // Below safe area
    case bottomSafe = "bottom_safe"   // Above safe area
}

/// Progress animations
public enum ProgressAnimation: String, Codable, CaseIterable {
    case none = "none"
    case bounce = "bounce"
    case pulse = "pulse"
    case slide = "slide"
    case scale = "scale"
}

/// Navigation button configuration
public struct NavigationButtonConfig: Codable {
    public let type: ButtonType
    public let position: ButtonPosition
    public let text: String?
    public let icon: String?
    public let size: Double?
    public let cornerRadius: Double?
    public let elevation: Double?
    public let animation: ButtonAnimation?
    
    public init(
        type: ButtonType,
        position: ButtonPosition,
        text: String? = nil,
        icon: String? = nil,
        size: Double? = nil,
        cornerRadius: Double? = nil,
        elevation: Double? = nil,
        animation: ButtonAnimation? = nil
    ) {
        self.type = type
        self.position = position
        self.text = text
        self.icon = icon
        self.size = size
        self.cornerRadius = cornerRadius
        self.elevation = elevation
        self.animation = animation
    }
}

/// Navigation button types
public enum ButtonType: String, Codable, CaseIterable {
    case circle = "circle"             // Circular icon button
    case pill = "pill"                 // Rounded rectangle
    case text = "text"                 // Text-only button
    case rectangle = "rectangle"       // Standard rectangle
    case fab = "fab"                   // Floating action button
    case invisible = "invisible"       // No visual button (swipe only)
}

/// Button positions
public enum ButtonPosition: String, Codable, CaseIterable {
    case bottomLeading = "bottom_leading"
    case bottomTrailing = "bottom_trailing"
    case bottomCenter = "bottom_center"
    case topLeading = "top_leading"
    case topTrailing = "top_trailing"
    case floatingLeft = "floating_left"
    case floatingRight = "floating_right"
    case centerLeading = "center_leading"
    case centerTrailing = "center_trailing"
}

/// Button animations
public enum ButtonAnimation: String, Codable, CaseIterable {
    case none = "none"
    case pulse = "pulse"
    case bounce = "bounce"
    case scale = "scale"
    case glow = "glow"
}

/// Complete navigation layout configuration
public struct NavigationLayoutConfig: Codable {
    public let layoutID: String
    public let name: String
    public let style: NavigationStyle
    public let progressIndicator: ProgressIndicatorConfig
    public let backButton: NavigationButtonConfig
    public let nextButton: NavigationButtonConfig
    public let finishButton: NavigationButtonConfig?
    public let swipeGestures: Bool?
    public let hapticFeedback: Bool?
    public let contentPadding: EdgePaddingConfig?
    
    public init(
        layoutID: String,
        name: String,
        style: NavigationStyle,
        progressIndicator: ProgressIndicatorConfig,
        backButton: NavigationButtonConfig,
        nextButton: NavigationButtonConfig,
        finishButton: NavigationButtonConfig? = nil,
        swipeGestures: Bool? = nil,
        hapticFeedback: Bool? = nil,
        contentPadding: EdgePaddingConfig? = nil
    ) {
        self.layoutID = layoutID
        self.name = name
        self.style = style
        self.progressIndicator = progressIndicator
        self.backButton = backButton
        self.nextButton = nextButton
        self.finishButton = finishButton
        self.swipeGestures = swipeGestures
        self.hapticFeedback = hapticFeedback
        self.contentPadding = contentPadding
    }
}

/// Edge padding configuration
public struct EdgePaddingConfig: Codable {
    public let top: Double?
    public let bottom: Double?
    public let leading: Double?
    public let trailing: Double?
    
    public init(top: Double? = nil, bottom: Double? = nil, leading: Double? = nil, trailing: Double? = nil) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
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

// MARK: - Predefined Navigation Layouts

@available(iOS 15.0, *)
public enum PredefinedNavigationLayouts {
    
    /// Vibrant template navigation - immersive with dots progress
    public static let vibrant = NavigationLayoutConfig(
        layoutID: "vibrant_nav",
        name: "Vibrant Immersive",
        style: .immersive,
        progressIndicator: ProgressIndicatorConfig(
            type: .dots,
            position: .topSafe,
            size: 8,
            spacing: 12,
            animation: .scale
        ),
        backButton: NavigationButtonConfig(
            type: .circle,
            position: .topLeading,
            icon: "chevron.left",
            size: 44,
            cornerRadius: 22,
            elevation: 4
        ),
        nextButton: NavigationButtonConfig(
            type: .fab,
            position: .bottomCenter,
            text: "Continue",
            icon: "arrow.right",
            size: 56,
            cornerRadius: 28,
            elevation: 8,
            animation: .pulse
        ),
        swipeGestures: true,
        hapticFeedback: true,
        contentPadding: EdgePaddingConfig(top: 60, bottom: 120, leading: 20, trailing: 20)
    )
    
    /// Modern template navigation - floating buttons
    public static let modern = NavigationLayoutConfig(
        layoutID: "modern_nav",
        name: "Modern Floating",
        style: .floating,
        progressIndicator: ProgressIndicatorConfig(
            type: .line,
            position: .top,
            height: 3
        ),
        backButton: NavigationButtonConfig(
            type: .circle,
            position: .floatingLeft,
            icon: "chevron.left",
            size: 48,
            cornerRadius: 24,
            elevation: 6
        ),
        nextButton: NavigationButtonConfig(
            type: .circle,
            position: .floatingRight,
            icon: "chevron.right",
            size: 52,
            cornerRadius: 26,
            elevation: 6,
            animation: .scale
        ),
        finishButton: NavigationButtonConfig(
            type: .pill,
            position: .bottomCenter,
            text: "Get Started",
            size: 52,
            cornerRadius: 26
        ),
        swipeGestures: true,
        hapticFeedback: true,
        contentPadding: EdgePaddingConfig(top: 20, bottom: 100, leading: 24, trailing: 24)
    )
    
    /// Minimal template navigation - clean text-based
    public static let minimal = NavigationLayoutConfig(
        layoutID: "minimal_nav", 
        name: "Minimal Clean",
        style: .minimal,
        progressIndicator: ProgressIndicatorConfig(
            type: .stepCounter,
            position: .top,
            showStepCounter: true
        ),
        backButton: NavigationButtonConfig(
            type: .text,
            position: .bottomLeading,
            text: "← Back",
            size: 16
        ),
        nextButton: NavigationButtonConfig(
            type: .text,
            position: .bottomTrailing,
            text: "Next →",
            size: 16
        ),
        finishButton: NavigationButtonConfig(
            type: .rectangle,
            position: .bottomCenter,
            text: "Finish",
            size: 48,
            cornerRadius: 8
        ),
        swipeGestures: false,
        hapticFeedback: false,
        contentPadding: EdgePaddingConfig(top: 24, bottom: 80, leading: 24, trailing: 24)
    )
    
    /// Corporate template navigation - professional bottom bar
    public static let corporate = NavigationLayoutConfig(
        layoutID: "corporate_nav",
        name: "Corporate Professional", 
        style: .classic,
        progressIndicator: ProgressIndicatorConfig(
            type: .gradient,
            position: .top,
            height: 4
        ),
        backButton: NavigationButtonConfig(
            type: .text,
            position: .bottomLeading,
            text: "Back",
            size: 16
        ),
        nextButton: NavigationButtonConfig(
            type: .rectangle,
            position: .bottomTrailing,
            text: "Next",
            size: 50,
            cornerRadius: 12
        ),
        finishButton: NavigationButtonConfig(
            type: .rectangle,
            position: .bottomCenter,
            text: "Complete Setup",
            size: 50,
            cornerRadius: 12
        ),
        swipeGestures: false,
        hapticFeedback: true,
        contentPadding: EdgePaddingConfig(top: 16, bottom: 100, leading: 20, trailing: 20)
    )
    
    /// Playful template navigation - bouncy bubbles
    public static let playful = NavigationLayoutConfig(
        layoutID: "playful_nav",
        name: "Playful Bouncy",
        style: .floating,
        progressIndicator: ProgressIndicatorConfig(
            type: .bubbles,
            position: .topSafe,
            size: 12,
            spacing: 8,
            animation: .bounce
        ),
        backButton: NavigationButtonConfig(
            type: .circle,
            position: .floatingLeft,
            icon: "chevron.left",
            size: 48,
            cornerRadius: 24,
            elevation: 6,
            animation: .bounce
        ),
        nextButton: NavigationButtonConfig(
            type: .circle,
            position: .floatingRight,
            icon: "chevron.right", 
            size: 56,
            cornerRadius: 28,
            elevation: 8,
            animation: .pulse
        ),
        finishButton: NavigationButtonConfig(
            type: .pill,
            position: .bottomCenter,
            text: "Let's Go! 🎉",
            size: 54,
            cornerRadius: 27,
            animation: .glow
        ),
        swipeGestures: true,
        hapticFeedback: true,
        contentPadding: EdgePaddingConfig(top: 60, bottom: 120, leading: 16, trailing: 16)
    )
    
    public static let allLayouts: [NavigationLayoutConfig] = [
        vibrant, modern, minimal, corporate, playful
    ]
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
        spacing: SpacingConfig(small: 8, medium: 16, large: 24, extraLarge: 32),
        navigationLayout: PredefinedNavigationLayouts.modern
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
        spacing: SpacingConfig(small: 12, medium: 20, large: 32, extraLarge: 48),
        navigationLayout: PredefinedNavigationLayouts.minimal
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
        spacing: SpacingConfig(small: 10, medium: 18, large: 28, extraLarge: 40),
        navigationLayout: PredefinedNavigationLayouts.vibrant
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
        spacing: SpacingConfig(small: 8, medium: 16, large: 24, extraLarge: 36),
        navigationLayout: PredefinedNavigationLayouts.corporate
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
        spacing: SpacingConfig(small: 12, medium: 20, large: 30, extraLarge: 44),
        navigationLayout: PredefinedNavigationLayouts.playful
    )
    
    public static let allTemplates: [GlobalTemplate] = [
        modern, minimal, vibrant, corporate, playful
    ]
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


