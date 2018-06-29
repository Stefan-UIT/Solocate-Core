//
//  ItemsSectionView.swift
//  DMSDriver
//
//  Created by MrJ on 5/22/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ItemsSectionView: BaseView {

    @IBOutlet weak var scanBarcodeButton: UIButton!
    var didClickScanButton:(() -> Void)?
    
    func config(_ isHiddenScanBarCodeButton: Bool? = false) {
        super.config()
        scanBarcodeButton.isHidden = isHiddenScanBarCodeButton ?? false
    }
    
    @IBAction func tapScanBarcodeButtonAction(_ sender: UIButton) {
        didClickScanButton?()
    }
}
