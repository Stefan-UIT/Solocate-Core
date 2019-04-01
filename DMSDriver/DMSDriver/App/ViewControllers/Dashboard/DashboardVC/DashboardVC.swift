//
//  DashboardVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/1/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import Charts

enum DashboardDisplayCellType:Int {
    case NEW_ROUTE
    case INPROGESS_ROUTE
    case MY_TASK
    case NEW_ALERT
    case LATE_ROUTE
    case LATE_ORDER
}


class DashboardVC: BaseViewController {
    
    @IBOutlet weak var pieChartView:PieChartView?
    @IBOutlet weak var clvContent:UICollectionView?
    @IBOutlet weak var btnFilter:UIButton?
    @IBOutlet weak var lblFilter:UILabel?
    @IBOutlet weak var lblFilterValue:UILabel?

    var surveyData = ["New": 20, "In-progess": 30, "Finished": 5, "Cancelled": 45]
    var arrListPage:[Array<Any>] = []
    var timeData:TimeDataItem?
    var dataDashboard:ResponseDataDashboard?
    
    fileprivate let identifierTitleCell  =  "TileClc"
    fileprivate let identifierHeaderCell  =  "TileHeaderClc"

    fileprivate let MP_POS_IMAGE  =  0
    fileprivate let MP_POS_TITLE  =  1
    fileprivate let MP_POS_SUBTITLE = 2
    fileprivate let MP_POS_PLURAL  = 3
    fileprivate let MP_POS_INDEX   = 4
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        updateUI()
        setupCollectionView()
        setup(pieChartView: pieChartView!)
        reloadDataDisplay()
        guard let time = timeData else {
            return
        }
        getDataDashboard(timeDataItem: time)
    }
    
    
    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().navigationService.delegate = self
        App().navigationService.updateNavigationBar(.Menu, "Dashboard".localized, AppColor.white, true)
    }
    
    func initVar()  {
        timeData = TimeData.getTimeDataItemType(type: .TimeItemTypeThisWeek)
        TimeData.setTimeDataItemDefault(item: timeData!)
    }
    
    override func updateUI()  {
        super.updateUI()
        lblFilter?.text = timeData?.title
        setup(pieChartView: pieChartView!)
        fillChart()
        clvContent?.reloadData()
    }

    func setupCollectionView()  {
        clvContent?.delegate = self
        clvContent?.dataSource = self
    }
    
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = true // note pie Entry
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        chartView.drawCenterTextEnabled = true
        chartView.drawEntryLabelsEnabled = false
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let newRoutes = dataDashboard?.filterBy(status: .New) ?? []
        let inprogessRoutes = dataDashboard?.filterBy(status: .InProgess) ?? []
        let finishedRoutes = dataDashboard?.filterBy(status: .Finished) ?? []
        let cacelledRoutes = dataDashboard?.filterBy(status: .InProgess) ?? []
        let total = newRoutes.count + inprogessRoutes.count + finishedRoutes.count + cacelledRoutes.count
        let centerText = NSMutableAttributedString(string: total == 0 ? "Data unavailable.".localized : "Route status".localized)
        centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 13)!,
                                  NSAttributedString.Key.strokeColor : total == 0 ? UIColor.red : UIColor.black,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText;
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .center
        l.orientation = .vertical
        l.drawInside = false
        l.xEntrySpace = 3
        l.yEntrySpace = 20
        l.yOffset = 0
        l.direction = .leftToRight
        l.form = .line
        l.formSize = 30
        l.formLineWidth = 12
    }

    
    func fillChart() {
        var dataEntries = [PieChartDataEntry]()
        let newRoutes = dataDashboard?.filterBy(status: .New) ?? []
        let inprogessRoutes = dataDashboard?.filterBy(status: .InProgess) ?? []
        let finishedRoutes = dataDashboard?.filterBy(status: .Finished) ?? []
        let cacelledRoutes = dataDashboard?.filterBy(status: .InProgess) ?? []
        let total = newRoutes.count + inprogessRoutes.count + finishedRoutes.count + cacelledRoutes.count
        surveyData =  ["New".localized: newRoutes.count,
                       "In-progess".localized: inprogessRoutes.count,
                       "Finished".localized: finishedRoutes.count,
                       "Cancelled".localized: cacelledRoutes.count]
        for (text , val) in surveyData {
            let percent = Double(val) / Double(total)
            let entry = PieChartDataEntry(value: percent, label: text)
            dataEntries.append(entry)
        }
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 5
        
        let chartData = PieChartData(dataSet: chartDataSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        chartData.setValueFont(.systemFont(ofSize: 11, weight: .light))
        chartData.setValueTextColor(.white)
        
        pieChartView?.data = chartData
        
        pieChartView?.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    func reloadDataDisplay()  {
        arrListPage = []
        arrListPage.append(["ic-newRoute","New Routes","item","",DashboardDisplayCellType.NEW_ROUTE])
        arrListPage.append(["ic-inprogessRoute","In-progess Routes","item","",DashboardDisplayCellType.INPROGESS_ROUTE])
        arrListPage.append(["ic-mytask","My Tasks","tasks","",DashboardDisplayCellType.MY_TASK])
        arrListPage.append(["ic-newAlert","New Alerts","item","",DashboardDisplayCellType.NEW_ALERT])
        arrListPage.append(["ic-lateRoute","Late Routes ","route","",DashboardDisplayCellType.LATE_ROUTE])
        arrListPage.append(["ic-lateOrders","Late Orders  ","order","",DashboardDisplayCellType.LATE_ORDER])
        
        clvContent?.reloadData()
    }
    
    //MARK: - ACTION
    @IBAction func onbtnClickFilterByDate(btn:UIButton) {
        let arrHide = [TimeItemType.TimeItemTypeLastYear.rawValue,
                       TimeItemType.TimeItemTypeThisYear.rawValue,
                       TimeItemType.TimeItemTypeNextYear.rawValue]
        FilterByDatePopupView.showFilterListTimeAtView(view: btn,
                                                       atViewContrller: self,
                                                       timeData: timeData,
                                                       needHides: arrHide as [NSNumber]) {[weak self] (success, timeData) in
                                                        self?.timeData = timeData
                                                        self?.getDataDashboard(timeDataItem: timeData)
        }
    }
}

//MARK : - UICollectionViewDataSource
extension DashboardVC:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrListPage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = floor((collectionView.frame.size.width) / 3.0);
        let cellHeight = floor(collectionView.frame.size.height / 2);

        let size = CGSize(width:cellWidth,height: cellHeight);
        return size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row;
        let arr = arrListPage[row];
        let cellType = arr[MP_POS_INDEX] as? DashboardDisplayCellType
        
        var cell:DashboardClvCell?
        var shouldGrey = false;
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierTitleCell, for: indexPath) as? DashboardClvCell
        
        let title = arr[MP_POS_TITLE] as? String
        cell?.imvIcon?.image = nil
        
        let imgName = arr[MP_POS_IMAGE] as? String
        var number = -1;
        
        switch cellType! {
        case .NEW_ROUTE:
            number = dataDashboard?.filterBy(status: .New).count ?? 0
        case .INPROGESS_ROUTE:
            number = dataDashboard?.filterBy(status: .InProgess).count ?? 0
            break
        case .MY_TASK:
            number = dataDashboard?.newTasks.count ?? 0
        case .NEW_ALERT:
            number = dataDashboard?.newAlerts.count ?? 0
            break
        case .LATE_ROUTE:
            number = dataDashboard?.lateRoutes.count ?? 0
            break
        case .LATE_ORDER:
            number = dataDashboard?.lateOrders.count ?? 0
            break
        }
        
        shouldGrey = number <= 0
        cell?.imvIcon?.isHidden = false;
        //if(number >= 0) {
        cell?.btnNoti?.setTitle("\(number)", for: .normal)
        cell?.btnNoti?.backgroundColor = (number > 0 ? AppColor.redColor : AppColor.grayColor);
        cell?.btnNoti?.isHidden = (number <= 0);
        
        cell?.lblTitle?.text = title
        //cell.lblNumberShow.text = SF(@"%lu %@%@", number, _arrListPage[row][2], number == 1 ? @"" : @"s");
        //cell.lblNumberShow.hidden = YES:// isEmpty(title);
        cell?.imvIcon?.image = UIImage(named: E(imgName))
        
        if row % 2 == 0 {
            cell?.conRightViewContent?.constant = 5
            cell?.conLeftViewContent?.constant = 20
            
        }else {
            cell?.conRightViewContent?.constant = 20
            cell?.conLeftViewContent?.constant = 5
        }
        
        if(shouldGrey) {
            cell?.imvIcon?.image = UIImage(named: "\(E(imgName))_Gray");
        }
        
        return cell!
    }
    
    
}

//MARK : - UICollectionViewDelegate
extension DashboardVC:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        guard let typeCell = DashboardDisplayCellType(rawValue: row) else {
            return
        }
        switch typeCell {
        case .NEW_ROUTE:
            let newRoutes = dataDashboard?.filterBy(status: .New)
            if newRoutes?.count ?? 0 <= 0 {
                return
            }
            let vc:RouteListVC = RouteListVC.loadSB(SB: .Route)
            vc.routes = newRoutes ?? []
            vc.timeData = timeData
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .INPROGESS_ROUTE:
            let inprogessRoutes = dataDashboard?.filterBy(status: .InProgess)
            if inprogessRoutes?.count ?? 0 <= 0 {
                return
            }
            let vc:RouteListVC = RouteListVC.loadSB(SB: .Route)
            vc.routes = inprogessRoutes ?? []
            vc.timeData = timeData
            self.navigationController?.pushViewController(vc, animated: true)

        case .MY_TASK:
            let myTasks = dataDashboard?.newTasks
            if myTasks?.count ?? 0 <= 0 {
                return
            }
            let vc:TaskListVC = TaskListVC.loadSB(SB: .Task)
            self.navigationController?.pushViewController(vc, animated: true)

        case .NEW_ALERT:
            let newAlerts = dataDashboard?.newAlerts
            if newAlerts?.count ?? 0 <= 0 {
                return
            }
            let vc:HistoryNotifyVC = HistoryNotifyVC.loadSB(SB: .Notification)
            vc.isFromDashboard = true
            vc.arrContent = newAlerts ?? []
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .LATE_ROUTE:
            let lateRoutes = dataDashboard?.lateRoutes
            if lateRoutes?.count ?? 0 <= 0 {
                return
            }
            let vc:RouteListVC = RouteListVC.loadSB(SB: .Route)
            vc.routes = lateRoutes ?? []
            vc.timeData = timeData
            self.navigationController?.pushViewController(vc, animated: true)

        case .LATE_ORDER:
            let lateOrders = dataDashboard?.lateOrders
//            if lateOrders?.count ?? 0 <= 0 {
//                return
//            }
            let vc:OrderListViewController = OrderListViewController.loadSB(SB: .Order)
            vc.orderList = lateOrders ?? []
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension DashboardVC{
    func getDataDashboard(timeDataItem:TimeDataItem)  {
        self.showLoadingIndicator()
        SERVICES().API.getDataDashboard(timeData: timeDataItem) {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                self?.dataDashboard = obj.data
                self?.updateUI()

            case .error(let error):
                self?.showAlertView(error.getMessage())
            }
        }
    }
}


//MARK: - DMSNavigationServiceDelegate
extension DashboardVC:DMSNavigationServiceDelegate {
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}

