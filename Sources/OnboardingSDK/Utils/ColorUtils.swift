import SwiftUI
import Foundation

// MARK: - Color Utilities

@available(iOS 15.0, *)
public extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#FF0000", "FF0000", "#RGB", "RGB")
    /// - Returns: Color instance or nil if invalid hex
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove # if present
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // Handle different hex lengths
        let length = hexString.count
        var rgbValue: UInt64 = 0
        
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else {
            return nil
        }
        
        switch length {
        case 3: // RGB (12-bit)
            let r = Double((rgbValue & 0xF00) >> 8) / 15.0
            let g = Double((rgbValue & 0x0F0) >> 4) / 15.0
            let b = Double(rgbValue & 0x00F) / 15.0
            self.init(red: r, green: g, blue: b)
            
        case 6: // RGB (24-bit)
            let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = Double(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
            
        case 8: // ARGB (32-bit)
            let a = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            let r = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            let g = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            let b = Double(rgbValue & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, opacity: a)
            
        default:
            return nil
        }
    }
}

// MARK: - Color Convenience Methods

@available(iOS 15.0, *)
public extension Color {
    /// Creates a Color from hex string with fallback
    /// - Parameters:
    ///   - hex: Hex color string
    ///   - fallback: Fallback color if hex parsing fails
    /// - Returns: Color from hex or fallback color
    static func hex(_ hex: String, fallback: Color = .black) -> Color {
        return Color(hex: hex) ?? fallback
    }
    
    /// Common iOS system colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
    
    static let label = Color(UIColor.label)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)
    
    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
    
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
}

// MARK: - Color Accessibility Helpers

@available(iOS 15.0, *)
public extension Color {
    /// Returns true if the color is considered "light" (good for dark text)
    var isLight: Bool {
        guard let components = UIColor(self).cgColor.components else { return false }
        
        let red = components[0]
        let green = components[1]  
        let blue = components[2]
        
        // Calculate luminance using standard formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5
    }
    
    /// Returns appropriate text color (black or white) for this background color
    var contrastingTextColor: Color {
        return isLight ? .black : .white
    }
    
    /// Returns a color with specified opacity
    func opacity(_ value: Double) -> Color {
        return self.opacity(value)
    }
}
