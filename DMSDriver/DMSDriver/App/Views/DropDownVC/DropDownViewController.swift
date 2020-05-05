//
//  DropDownViewController.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/19/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

enum DropDownType {
    case InputText
    case Time
    case CalendarStart
    case CalendarEnd
    case OrderType
    case Customer
    case COD
    case Address
    case SKU
    case UOM
    case Zone
    case Number
    case PlateNumber
}

protocol DropDownViewControllerDelegate: NSObjectProtocol {
    func didSelectItem(item:DropDownModel)
}

class DropDownModel: BasicModel {
    var result:String?
    var customers: [UserModel.UserInfo]?
    var locations: [Address]?
    var skus:[SKUModel]?
    var uoms:[UOMModel]?
    var zones:[Zone]?
    var dateStart:Date?
    var dateEnd:Date?
    var truck:[Truck]?
    
    func addCustomers(_ customers:[UserModel.UserInfo]) -> DropDownModel {
        self.customers = customers
        return self
    }
    
    func addLocations(_ locations:[Address]) -> DropDownModel {
        self.locations = locations
        return self
    }
    
    func addSKUs(_ skus:[SKUModel]) -> DropDownModel {
        self.skus = skus
        return self
    }
    
    func addUOMs(_ uoms:[UOMModel]) -> DropDownModel {
        self.uoms = uoms
        return self
    }
    
    func addZones(_ zones:[Zone]) -> DropDownModel {
        self.zones = zones
        return self
    }
    
    func addDateFrom(_ date:Date) -> DropDownModel {
        self.dateStart = date
        return self
    }
    
    func addDateTo(_ date:Date) -> DropDownModel {
        self.dateEnd = date
        return self
    }
    
    func addText(_ text:String) -> DropDownModel {
        self.result = text
        return self
    }
    
    func addTruck(_ truck:[Truck]) -> DropDownModel {
        self.truck = truck
        return self
    }
}

class DropDownViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tbvContent:UITableView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var searchTextField:UITextField!
    
    
    @IBOutlet weak var datePickerBGView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tbvContentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var pickerOKButton: UIButton!
    @IBOutlet weak var actionButtonsView: UIView!
    @IBOutlet weak var actionButtonsContraintHeight: NSLayoutConstraint!
    
    
    let cellIndentifier = "DropDownTableViewCell"
    let SPACING_HEIGHT:CGFloat = 15
    let CELL_HEIGHT:CGFloat = 40
    let TABLEVIEW_HEIGHT:CGFloat = 180
    let TEXT_FIELD_HEIGHT:CGFloat = 80
    let CONTENT_VIEW_HEIGHT:CGFloat = 300
    var itemsOrigin:[Any] = []
    var itemsDisplay:[Any] = []
    var itemDropDown:DropDownModel?
    
    
    weak var delegate:DropDownViewControllerDelegate?
    var dropDownType: DropDownType = .InputText
    var editString:String?
    var time:[String] = []
    var titleContent:String?
    var timePicker:String?
    var datePicker:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleContent
        setupTableView()
        searchTextField.delegate = self
        setupViewType()
        initVar()
        setupKeyboard()
        setupPickerTimeView()
        setupDatePickerView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupViewType() {
        timePickerView.isHidden = true
        datePickerView.isHidden = true
        datePickerBGView.isHidden = true
        pickerCancelButton.backgroundColor = AppColor.redColor
        pickerOKButton.backgroundColor = AppColor.buttonColor
        switch dropDownType {
        case .InputText:
            tbvContent?.isHidden = true
            tbvContentHeightConstraint.constant = 0
            contentViewHeightConstraint.constant = CONTENT_VIEW_HEIGHT - TABLEVIEW_HEIGHT
        case .Address, .UOM:
            actionButtonsView?.isHidden = true
            actionButtonsContraintHeight.constant = 0
            break
        case .Number:
            searchTextField.keyboardType = .numberPad
            tbvContent?.isHidden = true
            tbvContentHeightConstraint.constant = 0
            contentViewHeightConstraint.constant = CONTENT_VIEW_HEIGHT - TABLEVIEW_HEIGHT
        case .OrderType, .Customer, .SKU, .Zone, .COD, .PlateNumber:
            textFieldView.isHidden = true
            textFieldViewHeightConstraint.constant = 0
            contentViewHeightConstraint.constant = CONTENT_VIEW_HEIGHT - TEXT_FIELD_HEIGHT
        case .Time:
            datePickerBGView.isHidden = false
            timePickerView.isHidden = false
            contentView.isHidden = true
        case .CalendarStart, .CalendarEnd:
            datePickerBGView.isHidden = false
            datePickerView.isHidden = false
            contentView.isHidden = true
        }
    }
    
    func setupPickerTimeView() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
    }
    
    func setupDatePickerView() {
        switch dropDownType {
        case .CalendarStart:
            datePickerView.datePickerMode = .dateAndTime
            let date = Date()
            datePickerView.minimumDate = date
            if let dateTo = itemDropDown?.dateEnd {
                datePickerView.maximumDate = dateTo
            }
        case .CalendarEnd:
            datePickerView.datePickerMode = .dateAndTime
            let date = Date()
            datePickerView.minimumDate = date
            if let dateFrom = itemDropDown?.dateStart {
                datePickerView.minimumDate = dateFrom
            }
        @unknown default:
            break
        }
    }
    
    func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillDisappear() {
        animationViewCenter()
    }
    
    @objc func keyboardWillAppear() {
        animationViewGoUpKeyboard()
    }
    
    func initVar() {
        itemsOrigin = []
        switch dropDownType {
        case .OrderType:
            itemsOrigin = ["pick-up".localized, "Delivery".localized]
        case .Customer:
            guard let _customers = itemDropDown?.customers else { return }
            itemsOrigin = _customers
        case .COD:
            itemsOrigin = ["yes".localized, "no".localized]
        case .Address:
            guard let _locations = itemDropDown?.locations else { return }
            itemsOrigin = _locations
        case .SKU:
            guard let _skus = itemDropDown?.skus else { return }
            itemsOrigin = _skus
        case .UOM:
            guard let _uoms = itemDropDown?.uoms else { return }
            itemsOrigin = _uoms
        case .Zone:
            guard let _zone = itemDropDown?.zones else { return }
            itemsOrigin = _zone
        case .PlateNumber:
            guard let _truck = itemDropDown?.truck else { return }
            itemsOrigin = _truck
        @unknown default:
            break
        }
        itemsDisplay = itemsOrigin
        setupTimeData()
    }
    
    func setupTimeData() {
        var hour:Int = 0
        var min:Int = 0
        for hourIndex in 0..<24 {
            hour = hourIndex
            for minIndex in 0..<4 {
                min = minIndex == 0 ? minIndex : min+15
                let minute = min == 0 ? "00" : String(min)
                let timeString = String(format: "%d:%@",hour,minute)
                time.append(timeString)
            }
        }
    }
    
    func animationViewGoUpKeyboard() {
        let y = self.view.frame.minY + SPACING_HEIGHT
        contentView.transform = CGAffineTransform(translationX: 0, y: y)
    }
    
    func animationViewCenter() {
        contentView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    func setupTableView() {
        tbvContent.register(UINib(nibName: String(describing: DropDownTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tbvContent.separatorStyle = .none
        tbvContent.delegate = self
        tbvContent.dataSource = self
    }
    
    func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func tapBackGround(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func tapOKTextFieldBtn(_ sender: Any) {
        let item = DropDownModel().addText(editString ?? "")
        delegate?.didSelectItem(item: item)
        self.dismiss()
    }
    
    @IBAction func tapCancelTextFieldBtn(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        self.datePicker = sender.date
    }
    
    @IBAction func didTapPickerCancelBtn(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTapPickerOKBtn(_ sender: UIButton) {
        switch dropDownType {
        case .Time:
            let item = DropDownModel().addText(timePicker ?? "")
            delegate?.didSelectItem(item: item)
            self.dismiss()
        case .CalendarStart:
            let item = DropDownModel().addDateFrom(datePicker ?? Date())
            self.delegate?.didSelectItem(item: item)
            self.dismiss()
        case .CalendarEnd:
            let item = DropDownModel().addDateTo(datePicker ?? Date())
            self.delegate?.didSelectItem(item: item)
            self.dismiss()
        @unknown default:
            break
        }
    }
    
    
}

extension DropDownViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            switch dropDownType {
            case .Address:
                let item = itemsOrigin as? [Address]
                itemsDisplay = (item?.filter{ $0.address?.contains(updatedText) ?? false }) ?? []
            case .UOM:
                let item = itemsOrigin as? [UOMModel]
                itemsDisplay = (item?.filter{$0.name?.contains(updatedText) ?? false }) ?? []
            @unknown default:
                break
            }
            if updatedText == "" {
                itemsDisplay = itemsOrigin
            }
            editString = updatedText
            tbvContent.reloadData()
        }
        return true
    }
}

extension DropDownViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return (dropDownType != .Address) ? CELL_HEIGHT : CELL_HEIGHT*2
//    }
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (dropDownType == .Address) ? UITableView.automaticDimension : CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! DropDownTableViewCell
        switch dropDownType {
        case .OrderType:
            cell.configureCell(itemsDisplay[indexPath.row] as! String)
        case .Customer:
            let item = itemsDisplay as! [UserModel.UserInfo]
            cell.configureCell(item[indexPath.row].userName ?? "")
        case .COD:
            cell.configureCell(itemsDisplay[indexPath.row] as! String)
        case .Address:
            let item = itemsDisplay as! [Address]
            
            cell.configureCell(item[indexPath.row].fullAddress)
        case .SKU:
            let item = itemsDisplay as! [SKUModel]
            cell.configureCell(item[indexPath.row].skuName)
        case .UOM:
            let item = itemsDisplay as! [UOMModel]
            cell.configureCell(item[indexPath.row].name ?? "")
        case .Zone:
            let item = itemsDisplay as! [Zone]
            cell.configureCell(item[indexPath.row].name ?? "")
        case .PlateNumber:
            let item = itemsDisplay as! [Truck]
            cell.configureCell(item[indexPath.row].plateNumber)
        @unknown default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = DropDownModel()
        switch dropDownType {
        case .OrderType:
            let text = itemsDisplay[indexPath.row] as! String
            item.result = text
        case .Customer:
            let itemSelect = itemsDisplay[indexPath.row] as? UserModel.UserInfo
            item.customers = [itemSelect] as? [UserModel.UserInfo]
        case .COD:
            let text = itemsDisplay[indexPath.row] as! String
            item.result = text
        case .Address:
            let itemSelect = itemsDisplay[indexPath.row] as? Address
            item.locations = [itemSelect] as? [Address]
        case .SKU:
            let itemSelect = itemsDisplay[indexPath.row] as? SKUModel
            item.skus = [itemSelect] as? [SKUModel]
        case .UOM:
            let itemSelect = itemsDisplay[indexPath.row] as? UOMModel
            item.uoms = [itemSelect] as? [UOMModel]
        case .Zone:
            let itemSelect = itemsDisplay[indexPath.row] as? Zone
            item.zones = [itemSelect] as? [Zone]
        case .PlateNumber:
            let itemSelect = itemsDisplay[indexPath.row] as? Truck
            item.truck = [itemSelect] as? [Truck]
        @unknown default:
            break
        }
        self.delegate?.didSelectItem(item: item)
        self.dismiss()
    }
    
}

extension DropDownViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return time.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return time[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.timePicker = time[row]
    }
    
}
