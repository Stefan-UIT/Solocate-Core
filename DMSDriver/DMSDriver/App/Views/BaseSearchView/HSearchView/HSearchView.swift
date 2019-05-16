//
//  HSearchView.swift
//
//  Created by machnguyen_uit on 11/21/18.
//  Copyright © 2018 horical. All rights reserved.
//

import UIKit


protocol HSearchViewDelegate:AnyObject {
    func tfSearchShouldChangeCharactersInRangeWithString(view:HSearchView,searchText:String)
    func tfSearchDidEndEditing(view:HSearchView,textField:UITextField)
    func tfSearchShouldBeginEditing(view:HSearchView,textField:UITextField)

}

class HSearchView: UIView {
    
    @IBOutlet weak var tfSearch:UITextField?
    @IBOutlet weak var vContent:UITextField?
    
    var delegate:HSearchViewDelegate?
    


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        super.awakeFromNib()
        tfSearch?.delegate = self
    }
}


extension HSearchView:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.tfSearchShouldBeginEditing(view: self, textField: textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("textField:\(String(describing: textField.text))")
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            print("text:\(text)")
            
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            delegate?.tfSearchShouldChangeCharactersInRangeWithString(view: self, searchText: updatedText)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.tfSearchDidEndEditing(view: self, textField: textField)
    }
}
