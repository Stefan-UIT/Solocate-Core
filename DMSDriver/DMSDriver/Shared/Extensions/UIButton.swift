

import UIKit

extension UIButton {

    // scale font
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let fontName = self.titleLabel!.font.fontName
        let fontSize = self.titleLabel!.font.pointSize
        self.titleLabel!.font = UIFont(name: fontName, size: fontSize * CGFloat(Constants.FONT_SCALE_VALUE))
    }

    @IBInspectable var localizeKey: String {
        get {
            return ""
        } set {
            self.setTitle(NSLocalizedString(newValue, comment: ""), for: .normal)
        }
    }
  
  @IBInspectable var style: String {
    get{
      return ""
    }
    set {
      
      if newValue == "roundedButton" {
        roundedButton()
      }else{
        
      }
    }
  }
    
   func roundedButton() {
      self.layer.cornerRadius = self.frame.height/2
      self.clipsToBounds = true;
      self.layer.masksToBounds = true;
    }
}
