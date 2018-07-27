
import Foundation
import UIKit

struct Font {
    static func helveticaRegular(with size: Int) -> UIFont {
        let font = UIFont(name: "Helvetica", size: CGFloat(size))
        
        return font!
    }
    
    static func helveticaBold(with size: Int) -> UIFont {
        let font = UIFont(name: "Helvetica-Bold", size: CGFloat(size))
        
        return font!
    }
    
    static func gothamBook(with size: Int) -> UIFont {
        let font = UIFont(name: "Gotham-Book", size: CGFloat(size))
        
        return font!
    }
    
    static func gothamMedium(with size: Int) -> UIFont {
        let font = UIFont(name: "Gotham-Medium", size: CGFloat(size))
        
        return font!
    }
    
    static func gothamBold(with size: Int) -> UIFont {
        let font = UIFont(name: "Gotham-Bold", size: CGFloat(size))
        
        return font!
    }
    
    static func belindaRegular(with size: Int) -> UIFont {
        let font = UIFont(name: "BelindaW00-Regular", size: CGFloat(size))
        
        return font!
    }
}
