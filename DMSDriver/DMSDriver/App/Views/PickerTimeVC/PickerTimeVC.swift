//
//  PickerTimeVC.swift
//  DMSDriver
//
//  Created by Mach Van  Nguyen on 4/5/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

typealias PickerTimeVCCallback = (Bool, Date,Date) -> Void
typealias PickerTimeVCOneCallback = (Bool,Date) -> Void
typealias PickerTimeVCContenttCallback = (Bool, Date,String) -> Void

class PickerTimeVC: BaseViewController {
    
    enum PickerTimeMode:Int {
        case PickerModeFromTo = 0
        case PickerModeSingle
        case PickerModeContent
    }
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var tbvPicker:UITableView?
    @IBOutlet weak var vBackground:UIView?

    
    // MARK: - VARIALE
    var pickerMode:PickerTimeMode = .PickerModeSingle
    var callback:PickerTimeVCCallback?
    var callbackOne:PickerTimeVCOneCallback?
    var callbackContent:PickerTimeVCContenttCallback?

    private var dateIn:Date?
    private var dateOut:Date?
    private var datePickerMode:UIDatePicker.Mode?
    private var strTitle:String?
    private var strContent:String?
    private var content:String?
    private var useOriginTime:Bool?
    private var mustBeforeDate:Date?
    private var mustAfterDate:Date?
    private var showPickerIn:Bool?
    private var strHeaderFrom:String?
    private var strHeaderTo:String?
    private var dateFormat:DateFormatter?
    private var timeZoneCompany:TimeZone?
    private var identifierHeaderSectionCell = "HeaderSectionCell"
    private var identifierFooterCell = "FooterCell"
    private var identifierPickerTimeCell = "PickerTimeCell"
    private var identifierContentCell = "ContentCell"


    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initVar()
    }
    
    func initUI() {
        vBackground?.layer.cornerRadius = 5.0;
        tbvPicker?.layer.cornerRadius = 5.0;
        tbvPicker?.clipsToBounds = true;
        tbvPicker?.separatorStyle = .none
        tbvPicker?.delegate = self
        tbvPicker?.dataSource = self
        tbvPicker?.register(UINib.init(nibName: ClassName(HeaderSectionCell()), bundle: nil),
                            forCellReuseIdentifier: identifierHeaderSectionCell)
        tbvPicker?.register(UINib.init(nibName: ClassName(PickerTimeCell()), bundle: nil),
                            forCellReuseIdentifier: identifierPickerTimeCell)
        tbvPicker?.register(UINib.init(nibName: ClassName(FooterCell()), bundle: nil),
                            forCellReuseIdentifier: identifierFooterCell)
        tbvPicker?.register(UINib.init(nibName: ClassName(ContentCell()), bundle: nil),
                            forCellReuseIdentifier: identifierContentCell)
    }
    
    func initVar()  {
        showPickerIn = true;
        timeZoneCompany = TimeZone.company
        dateFormat = DateFormatter()
        dateFormat?.timeZone = timeZoneCompany
        guard let mode = datePickerMode else {
            return
        }
        switch mode {
        case .time:
            dateFormat?.dateFormat = "HH':'mm' 'a"
        case .date:
            dateFormat?.dateFormat = "MM'/'dd'/'yyyy"
        case .dateAndTime:
            dateFormat?.dateFormat = "MM'/'dd'/'yyyy' 'hh':'mm' 'a"

        default:
            break
        }
        strHeaderFrom = dateFormat?.string(from: dateIn ?? Date())
        strHeaderTo = dateFormat?.string(from: dateOut ?? Date())
    }
}


//MARK:  METHOR
extension PickerTimeVC{
    fileprivate class func showPickerModeDisplay(modeDisplay:PickerTimeMode,
                                           timeDisplay:UIDatePicker.Mode,
                                           timeIn:Date,
                                           timeOut:Date,
                                           atVC:UIViewController? = nil,
                                           title:String? = nil,
                                           enterText:String? = nil,
                                           callback:@escaping PickerTimeVCCallback)  {
        DispatchQueue.main.async {
            let vc: PickerTimeVC = PickerTimeVC.load()
            vc.dateIn = timeIn
            vc.dateOut = timeOut
            vc.datePickerMode = timeDisplay
            vc.pickerMode = modeDisplay;
            vc.strTitle = title;
            vc.strContent = enterText;
            vc.setCallback(callBack: callback)
            if atVC == nil{
                App().mainVC?.present(vc, animated: false, completion: nil)
            }else {
                atVC?.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    fileprivate class func showPickerWithTitle(title:String,
                                               oldDate:Date,
                                               datePickerMode
        mode:UIDatePicker.Mode,
                                               fromVC:UIViewController?, callback:@escaping PickerTimeVCOneCallback) {
        let vc:PickerTimeVC = PickerTimeVC.load()
        
        vc.dateIn = oldDate;
        vc.datePickerMode = mode;
        vc.pickerMode = .PickerModeSingle;
        vc.strTitle = title;
        vc.setCallbackOne(callback: callback)
        
        if fromVC == nil{
            App().mainVC?.rootNV?.present(vc, animated: false, completion: nil)
        }else {
            fromVC?.present(vc, animated: false, completion: nil)
        }
    }
    
    class func showPickerTime(fromDate:Date,
                                toDate:Date,
                                datePickerMode
                                mode:UIDatePicker.Mode,
                                fromVC:UIViewController?,
                                callback:@escaping PickerTimeVCCallback) {
        PickerTimeVC.showPickerModeDisplay(modeDisplay: .PickerModeFromTo,
                                           timeDisplay: mode,
                                           timeIn: fromDate,
                                           timeOut: toDate,
                                           atVC:fromVC,
                                           title: nil,
                                           enterText: nil,
                                           callback: callback)
    }
    
    
    class func showOnePickerTimeWithTimeIn(oldDate:Date,
                             datePickerMode
                             mode:UIDatePicker.Mode,
                             fromVC:UIViewController?, callback:@escaping PickerTimeVCOneCallback) {
        PickerTimeVC.showPickerWithTitle(title: "",
                                         oldDate: oldDate,
                                         datePickerMode: mode,
                                         fromVC: fromVC, callback: callback)
        
    }
    
    class func showOnePickerBeforeDate(date:Date,
                                 oldDate:Date,
                                     datePickerMode
                                     mode:UIDatePicker.Mode,
                                     fromVC:UIViewController?, callback:@escaping PickerTimeVCOneCallback) {
        let vc:PickerTimeVC = PickerTimeVC.load()
        vc.dateIn = oldDate;
        vc.datePickerMode = mode;
        vc.pickerMode = .PickerModeSingle;
        vc.mustBeforeDate = date;
        vc.setCallbackOne(callback: callback)
        
        if fromVC == nil{
            App().mainVC?.present(vc, animated: false, completion: nil)
        }else {
            fromVC?.present(vc, animated: false, completion: nil)
        }
    }
    
    class func showOnePickerAfterDate(date:Date,
                                 oldDate:Date,
                                 useOriginTime:Bool? = nil,
                                 datePickerMode
                                 mode:UIDatePicker.Mode,
                                 fromVC:UIViewController?, callback:@escaping PickerTimeVCOneCallback) {
        let vc:PickerTimeVC = PickerTimeVC.load()
        vc.dateIn = oldDate;
        vc.datePickerMode = mode;
        vc.pickerMode = .PickerModeSingle;
        vc.mustAfterDate = date;
        vc.useOriginTime = useOriginTime;

        vc.setCallbackOne(callback: callback)
        
        if fromVC == nil{
            App().mainVC?.present(vc, animated: false, completion: nil)
        }else {
            fromVC?.present(vc, animated: false, completion: nil)
        }
    }
}

//MARK: - UITableView
extension PickerTimeVC:UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch pickerMode {
        case .PickerModeSingle,
             .PickerModeContent:
            return 3
        case .PickerModeFromTo:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (pickerMode) {
        case .PickerModeSingle:
            if (indexPath.section == 0) {
                return 40;
            }
            if (indexPath.section == 1) {
                return 130;
            }
            return 40;
            
        case .PickerModeFromTo:
            if (indexPath.section == 4) {
                return 40;
            }
            if (indexPath.section == 0 || indexPath.section == 2) {
                return 40;
            }
            return 130;
            
        case .PickerModeContent:
            if (indexPath.section == 0) {
                return 40;
            }
            if (indexPath.section == 1) {
                return 130;
            }
            return 40;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (pickerMode) {
        case .PickerModeSingle:
            if (indexPath.section == 0) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierHeaderSectionCell, for: indexPath) as! HeaderSectionCell
                cell.lblTitleHeader?.text = !(strTitle?.isEmpty ?? true)  ? strTitle! : "time".localized
                cell.lblTimePick?.text = strHeaderFrom;
                //cell.delegate = self;
                
                return cell
                
            } else if(indexPath.section == 2) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierFooterCell, for: indexPath) as! FooterCell
                //cell.delegate = self;
                
                cell.btnDone?.setTitle("done".localized, for: .normal)
                cell.btnCancel?.setTitle("cancel".localized, for: .normal)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierPickerTimeCell, for: indexPath) as! PickerTimeCell
                
                cell.datePicker?.datePickerMode = datePickerMode ?? UIDatePicker.Mode.date
                cell.datePicker?.date = dateIn ?? Date()
                
                cell.delegate = self;
                return cell
            }
            
        case .PickerModeFromTo:
            if (indexPath.section == 0 || indexPath.section == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierHeaderSectionCell, for: indexPath) as! HeaderSectionCell
                if (indexPath.section == 0) {
                    cell.lblTitleHeader?.text = "from-time".localized
                } else {
                    cell.lblTitleHeader?.text = "to-time".localized

                }
                //cell.delegate = self;
                return cell
                
            } else if (indexPath.section == 4) {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierFooterCell, for: indexPath) as! FooterCell
                cell.delegate = self;
                
                cell.btnDone?.setTitle("done".localized, for: .normal)
                cell.btnCancel?.setTitle("cancel".localized, for: .normal)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierPickerTimeCell, for: indexPath) as! PickerTimeCell
                
                cell.datePicker?.datePickerMode = datePickerMode ?? UIDatePicker.Mode.date
                if (indexPath.section == 1) {
                    cell.datePicker?.date = dateIn ?? Date()
                    
                } else if (indexPath.section == 3){
                    cell.datePicker?.date = dateOut ?? Date()
                }
                cell.delegate = self;
                return cell
            }
            
        case .PickerModeContent:
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierContentCell, for: indexPath) as! ContentCell
                //cell.delegate = self;

                if !isEmpty(strContent) {
                    cell.tfContent?.text = strContent;
                    if (cell.tfContent?.becomeFirstResponder() == false) {
                        cell.tfContent?.becomeFirstResponder()
                    }
                }
                return cell
      
            } else if (indexPath.section == 1) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierPickerTimeCell, for: indexPath) as! PickerTimeCell
                
                cell.datePicker?.datePickerMode = datePickerMode ?? UIDatePicker.Mode.date
                cell.datePicker?.date = dateIn ?? Date()
                
                cell.delegate = self;
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifierFooterCell, for: indexPath) as! FooterCell
                cell.delegate = self;
                
                cell.btnDone?.setTitle("done".localized, for: .normal)
                cell.btnCancel?.setTitle("cancel".localized, for: .normal)
                
                return cell
            }
        }
    }
}


//MARK: - FooterCellDelegate
extension PickerTimeVC:FooterCellDelegate {
    func footerCell(footerCell: FooterCell, hasYes: Bool) {
        guard let _dateIn = dateIn?.startDay(timeZone: .current),
            let _dateOut = dateOut?.endDay(timeZone: .current) else {
            return
        }
        
        if (hasYes) {
            self.dismiss(animated: false) {[weak self] in
                if self?.callback != nil {
                    self?.callback?(hasYes,_dateIn,_dateOut)
                    self?.callback = nil
                    
                }else if (self?.callbackOne != nil){
                    self?.callbackOne?(hasYes,_dateIn);
                    self?.callbackOne = nil;
                    
                }else if (self?.callbackContent != nil){
                    self?.callbackContent?(hasYes, _dateIn, E(self?.strContent));
                    self?.callbackContent = nil;
                }
            }
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}


//MARK: - PickerTimeCellDelegate
extension PickerTimeVC:PickerTimeCellDelegate {
    func pickerTimeCell(pickerTimeCell: PickerTimeCell, changeValue date: Date) {
        if (pickerMode == .PickerModeSingle) {
            dateIn = date;
            
            if (mustAfterDate != nil) {
                if dateIn?.isComparedWithTime(date: mustAfterDate!) != DATE_IS_FUTURE {
                    dateIn = mustAfterDate;
                }
            }
            
            if (mustBeforeDate != nil) {
                if dateIn?.isComparedWithTime(date: mustBeforeDate!) != DATE_IS_FUTURE {
                    dateIn = mustBeforeDate;
                }
            }
            
            strHeaderFrom = dateFormat?.string(from: date)
            tbvPicker?.reloadData()
            
        }else {
            let indexPath = tbvPicker?.indexPath(for: pickerTimeCell)
            let section = indexPath?.section
            if (section == 1) {
            
                if (datePickerMode == UIDatePicker.Mode.dateAndTime) {
                    dateIn = date.toDateTime(timeZone: .current)
                    guard let _dateOut = dateOut else {return}
                    if dateIn?.isComparedWithTime(date:_dateOut) == DATE_IS_FUTURE {
                        dateOut = dateIn
                    }
                    
                } else {
                    dateIn = date.startDay(timeZone: .current)
                    guard let _dateOut = dateOut else {return}

                    if dateIn?.isComparedWithDay(date: _dateOut) == DATE_IS_FUTURE{
                        dateOut = dateIn?.endDay(timeZone: .current)
                    }
                }
                
                strHeaderFrom = dateFormat?.string(from: dateIn!)
                
            } else if(section == 3){
                
                if (datePickerMode == UIDatePicker.Mode.dateAndTime) {
                    dateOut = date;
                    
                    guard let _dateOut = dateOut else {return}
                    if dateIn?.isComparedWithTime(date:_dateOut) == DATE_IS_FUTURE {
                        dateOut = dateIn
                    }
                    
                } else {
                    dateOut = date.endDay(timeZone: .current)
                    guard let _dateOut = dateOut else {return}
                    if dateIn?.isComparedWithDay(date: _dateOut) == DATE_IS_FUTURE{
                        dateIn = dateOut?.startDay(timeZone: .current)
                    }

                }
                guard let _dateOut = dateOut else {return}
                strHeaderTo = dateFormat?.string(from: _dateOut)
                    
            }
            
            tbvPicker?.reloadData()
        }
    }
}

//MARK: - Utiliti method
extension PickerTimeVC {
    func setCallbackOne(callback:@escaping PickerTimeVCOneCallback) {
        callbackOne = callback
    }
    
    func setCallback(callBack:@escaping PickerTimeVCCallback) {
        callback = callBack
    }
    
    func setCallbackContent(callback:@escaping PickerTimeVCContenttCallback) {
        callbackContent = callback
    }
}
