
import Foundation

import UIKit

/// Convenience methods for creating NSAttributedStrings.
extension NSAttributedString {
    class func attributesDictionary(with color: UIColor, font: UIFont, alignment: NSTextAlignment? = nil, kerning: Float? = nil) -> [NSAttributedString.Key: Any] {
        
        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font,
                                                         NSAttributedString.Key.foregroundColor: color]
        
        if let alignment = alignment {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            paragraphStyle.lineBreakMode = .byTruncatingTail
            
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }
        
        if let kerning = kerning {
            attributes[NSAttributedString.Key.kern] = NSNumber(value: kerning)
        }
        
        return attributes
    }
    
    class func attributedString(with text: String, color: UIColor, font: UIFont, alignment: NSTextAlignment? = nil, kerning: Float? = nil) -> NSAttributedString {
        let attributes = attributesDictionary(with: color, font: font, alignment: alignment, kerning: kerning)
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
