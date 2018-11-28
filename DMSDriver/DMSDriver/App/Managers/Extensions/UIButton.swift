

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
    
    func setStyleStartTimer()  {
        self.roundedButton()
        self.backgroundColor = AppColor.mainColor
        self.setTitleColor(AppColor.white, for: .normal)
        self.setTitle("Start".localized, for: .normal)

    }
    
    func setStylePauseTimer()  {
        self.roundedButton()
        self.backgroundColor = UIColor.gray
        self.setTitleColor(AppColor.white, for: .normal)
        self.setTitle("Pause".localized, for: .normal)

    }
    
    func setStyleResumeTimer()  {
        self.roundedButton()
        self.backgroundColor = AppColor.grayColor
        self.setTitleColor(AppColor.white, for: .normal)
        self.setTitle("Resume".localized, for: .normal)
        
    }
    
    func setStyleCancelTimer()  {
        self.roundedButton()
        self.backgroundColor = UIColor.white
        self.setTitleColor(AppColor.redColor, for: .normal)
        self.layer.borderWidth = 1
        self.layer.borderColor = AppColor.redColor.cgColor
        self.setTitle("Cancel".localized, for: .normal)
    }
}
