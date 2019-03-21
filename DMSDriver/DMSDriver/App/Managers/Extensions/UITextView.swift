

import UIKit

extension UITextView {
  
  // scale font
  override open func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    guard let fontName = self.font?.fontName,
      let fontSize = self.font?.pointSize else { return }
    self.font = UIFont(name: fontName, size: fontSize * CGFloat(Constants.FONT_SCALE_VALUE))
  }
  
}
