import Foundation
import SwiftUI

// MARK: - Main Flow Model
public struct OnboardingFlow: Codable {
    public let flowID: String
    public let appID: String
    public let version: String
    public let pages: [OnboardingPage]
    
    public init(flowID: String, appID: String, version: String, pages: [OnboardingPage]) {
        self.flowID = flowID
        self.appID = appID
        self.version = version
        self.pages = pages
    }
}

// MARK: - Page Model
public struct OnboardingPage: Codable, Identifiable {
    public let id: String
    public let type: OnboardingPageType
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
    public let style: PageStyle?
    public let button: ButtonConfig?
    
    public init(
        id: String,
        type: OnboardingPageType,
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
        style: PageStyle? = nil,
        button: ButtonConfig? = nil
    ) {
        self.id = id
        self.type = type
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
        self.style = style
        self.button = button
    }
}

// MARK: - Enums
public enum OnboardingPageType: String, Codable, CaseIterable {
    case textImage = "text_image"
    case input = "input"
    case selector = "selector"
    case slider = "slider"
    case template = "template"  // For custom templates
}

public enum InputType: String, Codable {
    case text = "text"
    case number = "number"
    case email = "email"
    case password = "password"
}

// MARK: - Style Configuration
public struct PageStyle: Codable {
    // Text Colors & Fonts
    public let titleColor: String?
    public let subtitleColor: String?
    public let titleFont: String?
    public let subtitleFont: String?
    public let titleFontSize: Double?
    public let subtitleFontSize: Double?
    
    // Layout & Positioning
    public let backgroundColor: String?
    public let contentAlignment: ContentAlignment?
    public let imagePosition: ImagePosition?
    public let imageSize: ImageSize?
    public let spacing: Double?
    public let padding: EdgePadding?
    
    // Template Override
    public let template: String?
    
    public init(
        titleColor: String? = nil,
        subtitleColor: String? = nil,
        titleFont: String? = nil,
        subtitleFont: String? = nil,
        titleFontSize: Double? = nil,
        subtitleFontSize: Double? = nil,
        backgroundColor: String? = nil,
        contentAlignment: ContentAlignment? = nil,
        imagePosition: ImagePosition? = nil,
        imageSize: ImageSize? = nil,
        spacing: Double? = nil,
        padding: EdgePadding? = nil,
        template: String? = nil
    ) {
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.titleFontSize = titleFontSize
        self.subtitleFontSize = subtitleFontSize
        self.backgroundColor = backgroundColor
        self.contentAlignment = contentAlignment
        self.imagePosition = imagePosition
        self.imageSize = imageSize
        self.spacing = spacing
        self.padding = padding
        self.template = template
    }
}

// MARK: - Layout Enums
public enum ContentAlignment: String, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
}

public enum ImagePosition: String, Codable {
    case top = "top"
    case bottom = "bottom"
    case leading = "leading"
    case trailing = "trailing"
    case background = "background"
}

public struct ImageSize: Codable {
    public let width: Double?
    public let height: Double?
    public let aspectRatio: Double?
    
    public init(width: Double? = nil, height: Double? = nil, aspectRatio: Double? = nil) {
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
    }
}

public struct EdgePadding: Codable {
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

// MARK: - Button Configuration
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

// MARK: - User Input Collection
public struct OnboardingUserInput: Codable {
    public let key: String
    public let value: Any
    public let pageID: String
    public let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case key, pageID, timestamp
    }
    
    public init(key: String, value: Any, pageID: String, timestamp: Date = Date()) {
        self.key = key
        self.value = value
        self.pageID = pageID
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        pageID = try container.decode(String.self, forKey: .pageID)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        // Note: value needs special handling based on type
        value = ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(pageID, forKey: .pageID)
        try container.encode(timestamp, forKey: .timestamp)
        // Note: value encoding needs special handling based on type
    }
}
