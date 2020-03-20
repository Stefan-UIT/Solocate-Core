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
    case SelecteText
    case Option
    case Time
    case Calendar
}

protocol DropDownViewControllerDelegate: NSObjectProtocol {
    func didSelectItem(item:String)
    func didDoneEditText(item:String)
    func didSelectTime(item:String)
    func didSelectDate(date:Date)
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
    
    let cellIndentifier = "DropDownTableViewCell"
    let SPACING_HEIGHT:CGFloat = 15
    let CELL_HEIGHT:CGFloat = 40
    let TABLEVIEW_HEIGHT:CGFloat = 180
    let TEXT_FIELD_HEIGHT:CGFloat = 80
    let CONTENT_VIEW_HEIGHT:CGFloat = 300
    var itemsOrigin:[String]?
    var itemsDisplay:[String]?
    weak var delegate:DropDownViewControllerDelegate?
    var dropDownStyle: DropDownType = .InputText
    var editString:String?
    var time:[String] = []
    var titleContent:String?
    
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
        switch dropDownStyle {
        case .InputText:
            tbvContent?.isHidden = true
            tbvContentHeightConstraint.constant = 0
            contentViewHeightConstraint.constant = CONTENT_VIEW_HEIGHT - TABLEVIEW_HEIGHT
        case .SelecteText:
            break
        case .Option:
            textFieldView.isHidden = true
            textFieldViewHeightConstraint.constant = 0
            contentViewHeightConstraint.constant = CONTENT_VIEW_HEIGHT - TEXT_FIELD_HEIGHT
        case .Time:
            timePickerView.isHidden = false
            contentView.isHidden = true
        case .Calendar:
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
        datePickerView.datePickerMode = .date
        let date = Date()
        datePickerView.minimumDate = date
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
        itemsDisplay = itemsOrigin
        setupTimeData()
    }
    
    func setupTimeData() {
        var hour:Int = 0
        var min:Int = 0
        for hourIndex in 0..<25 {
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
        delegate?.didDoneEditText(item: editString ?? "")
        self.dismiss()
    }
    
    @IBAction func tapCancelTextFieldBtn(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        self.delegate?.didSelectDate(date: sender.date)
    }
    
    
    
    
}

extension DropDownViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            itemsDisplay = itemsOrigin?.filter{ $0.contains(updatedText) }
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsDisplay?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! DropDownTableViewCell
        cell.configureCell(itemsDisplay?[indexPath.row] ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectItem(item: itemsDisplay?[indexPath.row] ?? "")
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
        delegate?.didSelectTime(item: time[row])
    }
    
}
