//
//  BaseSearchView.swift
//
//  Created by machnguyen_uit on 11/21/18.
//  Copyright © 2018 horical. All rights reserved.
//

import UIKit

protocol BaseSearchViewDelegate:AnyObject {
    func tfSearchShouldChangeCharactersInRangeWithString(view: BaseSearchView , text:String);
    func tfSearchDidEndEditing(view: BaseSearchView, textField: UITextField);
    func tfSearchShouldBeginEditing(view: BaseSearchView, textField: UITextField)
}


extension BaseSearchViewDelegate{
    func tfSearchShouldChangeCharactersInRangeWithString(view: BaseSearchView , text:String){}
    func tfSearchDidEndEditing(view: BaseSearchView, textField: UITextField){}
    func tfSearchShouldBeginEditing(view: BaseSearchView, textField: UITextField){}
}

class BaseSearchView: UIView {
    
    var vSearch:HSearchView?
    var delegate:BaseSearchViewDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    
    func initialize() {
        if vSearch == nil {
            vSearch = .load(nib: "HSearchView", owner: nil)
            vSearch?.delegate = self
            vSearch?.translatesAutoresizingMaskIntoConstraints = false;
            if let _v = vSearch{
                self.addSubview(_v, edge: .zero)
                vSearch?.addConstaints(top: 0, right: 0, bottom: 0, left: 0)
            }
            self.layoutIfNeeded()
        }
    }
}


extension BaseSearchView:HSearchViewDelegate{
    
    func tfSearchShouldBeginEditing(view: HSearchView, textField: UITextField) {
        delegate?.tfSearchShouldBeginEditing(view: self, textField: textField)
    }
    
    func tfSearchShouldChangeCharactersInRangeWithString(view: HSearchView, searchText: String) {
        delegate?.tfSearchShouldChangeCharactersInRangeWithString(view: self, text: searchText)
    }
    
    func tfSearchDidEndEditing(view: HSearchView, textField: UITextField) {
        delegate?.tfSearchShouldBeginEditing(view: self, textField: textField)
    }
}
