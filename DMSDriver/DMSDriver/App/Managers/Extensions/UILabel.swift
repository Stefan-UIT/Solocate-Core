

import UIKit

extension UILabel {
  
    // scale font
    override open func awakeFromNib() {
    super.awakeFromNib()
        //     Initialization code
        let fontName = self.font.fontName
        let fontSize = self.font.pointSize
        self.font = UIFont(name: fontName, size: fontSize * CGFloat(Constants.FONT_SCALE_VALUE))
    }
  
    @IBInspectable var localizeKey: String {
        get {
          return ""
        } set {
            let localBundle = Bundle(url: App().bundlePath)!
            let text = NSLocalizedString(newValue, tableName: nil, bundle: localBundle, value: "", comment: "")
          self.text = text
        }
    }
    
    func requiredHeight() -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y:  0,width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text

        label.sizeToFit()

        return label.frame.height
    }
    
    
    func setStyleCircleWhiteTextBlueBackground()  {
        self.layer.cornerRadius = self.bounds.size.width/2.0;
        self.layer.masksToBounds = true;
        self.layer.borderWidth = 0;
        self.clipsToBounds = true;
        self.backgroundColor = AppColor.mainColor;
        self.textColor = UIColor.white
        self.font = Font.helveticaRegular(with: 14)
    }
  
    func from(html: String) {
        if let htmlData = html.data(using: String.Encoding.unicode) {
          do {
            self.attributedText = try NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
          } catch let e as NSError {
            print("Couldn't parse \(html): \(e.localizedDescription)")
          }
        }
    }
}
