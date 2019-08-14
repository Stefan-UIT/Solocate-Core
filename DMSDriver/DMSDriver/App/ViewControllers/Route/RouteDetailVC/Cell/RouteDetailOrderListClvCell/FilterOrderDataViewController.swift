//
//  FilterOrderDataViewController.swift
//  DMSDriver
//
//  Created by Trung Vo on 8/14/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import DropDown

protocol FilterOrderDataViewControllerDelegate:class {
    func didFilterBy(_ filterDataModel:FilterOrderModel)
}

struct FilterOrderModel {
    var consigneeName:String?
    var customerName:String?
}

class FilterOrderDataViewController: UIViewController {

    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var consigneeNameLabel: UILabel!
    
    var route:Route!
    let dropDown = DropDown()
    var filterOrderModel = FilterOrderModel()
    
    weak var delegate:FilterOrderDataViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.direction = .bottom
        reloadUI()
    }
    
    func reloadUI(){
        consigneeNameLabel.text = Slash(filterOrderModel.consigneeName)
        customerNameLabel.text = Slash(filterOrderModel.customerName)
    }
    

    @IBAction func onConsigneeButtonTouchUp(_ sender: UIButton) {
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = route.consigneeNameArr
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.filterOrderModel.consigneeName = item
            self.consigneeNameLabel.text = item
        }
        dropDown.show()
    }
    
    
    @IBAction func onCustomerButtonTouchUp(_ sender: UIButton) {
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = route.customerNameArr
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.filterOrderModel.customerName = item
            self.customerNameLabel.text = item
        }
        dropDown.show()
    }
    
    
    @IBAction func onApplyButtonTouchUp(_ sender: UIButton) {
        self.delegate?.didFilterBy(filterOrderModel)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClearAllButtonTouchUp(_ sender: UIButton) {
        filterOrderModel.consigneeName = nil
        filterOrderModel.customerName = nil
        reloadUI()
        
    }
    
    @IBAction func onCloseButtonTouchUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
