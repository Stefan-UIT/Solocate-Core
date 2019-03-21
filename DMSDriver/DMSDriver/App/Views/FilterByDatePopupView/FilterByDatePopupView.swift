//
//  FilterByDatePopupView.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/4/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

typealias FilterByDatePopupViewCallback = (Bool,TimeDataItem) ->Void

class FilterByDatePopupView: UIViewController {
    @IBOutlet weak var tbvFilter:UITableView?
    @IBOutlet weak var btnFilterDate:UIButton?
    @IBOutlet weak var btnFilterContent:UIButton?
    @IBOutlet weak var vBackground:UIView?

    private let identifierPopupCell = "FilterByDatePopupCell"
    private let identifierPopupCustomCell = "FilterByDatePopupCustomCell"

    private var popoverDelegate:PopoverDelegate?
    
    var timeData:TimeDataItem?
    var callback:FilterByDatePopupViewCallback?
    var arrNeedHide:[NSNumber]?

    var arrTimeData:[TimeDataItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        initUI()
    }
    
    func initVar()  {
        setupTableView()
        self.view.layer.cornerRadius = 5.0;
        self.view.clipsToBounds = true;
        
        arrTimeData = TimeData.arrTimeDataItem()
        if (timeData == nil) {
            timeData = TimeData.getTimeDataItemType(type: .TimeItemTypeThisWeek)
        }
    }
    
    func initUI()  {
        vBackground?.backgroundColor = UIColor.white
        //cornerRadius
        self.view.layer.cornerRadius = 5.0
        self.view.layer.masksToBounds = true
        self.view.clipsToBounds = true
    }
    
    func setupTableView()  {
        tbvFilter?.delegate = self
        tbvFilter?.dataSource = self
        tbvFilter?.register(UINib.init(nibName: ClassName(FilterByDatePopupCell()),
                                       bundle: nil),
                            forCellReuseIdentifier:identifierPopupCell)
        
        tbvFilter?.register(UINib.init(nibName: ClassName(FilterByDatePopupCustomCell()),
                                       bundle: nil),
                            forCellReuseIdentifier:identifierPopupCustomCell)
        tbvFilter?.rowHeight = UITableViewAutomaticDimension;

    }

    
    class func showFilterListTimeAtView(view:UIView,
                                  atViewContrller viewContrller:UIViewController,
                                  timeData:TimeDataItem?,
                                  needHides:[NSNumber], callback:@escaping FilterByDatePopupViewCallback)  {
        let vc:FilterByDatePopupView = FilterByDatePopupView.load()
        vc.timeData = timeData;
        vc.arrNeedHide = needHides;
        
        vc.modalPresentationStyle = .popover;
        vc.popoverDelegate = PopoverDelegate()
        vc.popoverPresentationController?.delegate = vc.popoverDelegate
        vc.popoverPresentationController?.sourceView = view;
        vc.popoverPresentationController?.sourceRect = view.bounds;
        //vc.popoverPresentationController.preferredContentSize = CGSizeMake(MAX(200, view.bounds.size.width), 200);
        vc.callback = callback;
        
        viewContrller.present(vc, animated: false, completion: nil)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

    }
}


//MARK: - UItableView
extension FilterByDatePopupView:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTimeData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = arrNeedHide?.count ?? 0
        if count > 0 {
            for i in 0..<count {
                let object = arrNeedHide?[i]
                if (indexPath.row == object?.intValue) {
                    return 0;
                }
            }
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard let type = TimeItemType(rawValue: row) else {
            return UITableViewCell()
        }
        
        if  type == .TimeItemTypeCustom {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierPopupCustomCell, for: indexPath) as! FilterByDatePopupCustomCell
            cell.selectionStyle = .none
            
            if timeData?.type == TimeItemType.TimeItemTypeCustom{
                cell.lblDay?.text = timeData?.subtitle
                cell.btnCheck?.isSelected = true
            }else {
                cell.btnCheck?.isSelected = false
                var text = ""
                
                let customTime = TimeData.getTimeDataItemCustom()
                if customTime != nil {
                    text = customTime?.subtitle ?? ""
                }else if (timeData != nil){
                    text = timeData?.subtitle ?? ""
                }
                
                if (text.length > 5) {
                    cell.lblDay?.text = text
                    
                } else {
                    cell.lblDay?.text = "Select Start - End Day"
                }
            }
            
            cell.btnCustom?.setStyleBlueSquare(title: "Custom")
            cell.delegate = self;
            
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifierPopupCell, for: indexPath) as! FilterByDatePopupCell
            cell.selectionStyle = .none
            
            cell.lblName?.text = arrTimeData[indexPath.row].title
            cell.lblDay?.text = arrTimeData[indexPath.row].subtitle;

            if (indexPath.row == timeData?.type?.rawValue) {
                cell.btnCheck?.isSelected = true;
            } else {
                cell.btnCheck?.isSelected = false;
            }
            
            cell.delegate = self;
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        timeData = arrTimeData[row]
        if timeData?.type == TimeItemType.TimeItemTypeCustom {
            var start:Date?
            var end:Date?
            let custom = TimeData.getTimeDataItemCustom()
            
            if (custom != nil) {
                start = custom?.startDate;
                end = custom?.endDate;
                
            }else if (timeData != nil){
                start = timeData?.startDate;
                end = timeData?.endDate;
                
            }else{
                start = Date().getTodayStartEndDates().0
                end = Date().getTodayStartEndDates().1
            }
            
        }else {
            guard let data = timeData else {return}
            TimeData.setTimeDataItemDefault(item: data)
            callback?(true,data)
            self.dismiss(animated: false, completion: nil)
        }
    }
}


//MARK: - FilterByDatePopupCellDelegate,FilterByDatePopupCustomCellDelegate
extension FilterByDatePopupView:FilterByDatePopupCellDelegate,FilterByDatePopupCustomCellDelegate{
    func filterByDatePopupCell(cell: FilterByDatePopupCell, didSelectChecked btn: UIButton) {
        //
    }
    
    func filterByDatePopupCustomCell(cell: FilterByDatePopupCustomCell, didSelectCheckCustom btn: UIButton) {
        //
    }
}
