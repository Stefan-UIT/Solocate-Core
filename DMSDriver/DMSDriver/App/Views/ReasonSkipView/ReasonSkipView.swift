//
//  ReasonSkipView.swift
//  SRSDriver
//
//  Created by MrJ on 2/13/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

typealias ReasonSkipViewCallback = (Bool,Reason?)-> Void

class ReasonSkipView: BaseView {
    @IBOutlet weak var tableView: UITableView!
    
    
    private var listReason = [Reason]()
    private var callback:ReasonSkipViewCallback?
    private var reasonSelect:Reason?
    private var selectedIndex: Int = -1

    override init() {
        super.init()
        tableView.register(UINib(nibName: "ReasonSkipTableViewCell", bundle: nil), forCellReuseIdentifier: "ReasonSkipTableViewCell")
        
        tableView.backgroundColor = .clear
        
        getReasonList()
        /*
        listReason = ["CUSTOMER NOT AVAILABLE",
                      "CUSTOMER IS NOT IN A DEFINED LOCATION",
                      "CUSTOMER CANCELED DELIVERY",
                      "CUSTOMER HAS DECLINED THE ITEM",
                      "THE CAR BROKE DOWN",
                      "OTHER"]
         */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - ACTION
    @IBAction func onbtnClickDismissView(btn:UIButton){
        removeFromSuperview()
    }
    
    @IBAction func onbtnClickOK(btn:UIButton){
        guard selectedIndex >= 0 else {
            return
        }
        reasonSelect = listReason[selectedIndex]
        callback?(true,reasonSelect)
        removeFromSuperview()
    }
}

extension ReasonSkipView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listReason.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReasonSkipTableViewCell") as? ReasonSkipTableViewCell {
            cell.selectionStyle = .none
            cell.loadData(listReason[indexPath.row].name.uppercased())
            if indexPath.row == selectedIndex {
                cell.handleSelectedCell()
            }else {
                cell.handleNoSelectCell()
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension ReasonSkipView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0 * Constants.SCALE_VALUE_HEIGHT_DEVICE
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
}

extension ReasonSkipView {
    func getReasonList() {
        self.showLoadingIndicator()
        SERVICES().API.getReasonList {[weak self] (result) in
            self?.dismissLoadingIndicator()
            switch result{
            case .object(let obj):
                guard let list = obj.data else {return}
                self?.listReason = list
                self?.tableView.reloadData()
                
            case .error(let error):
                //self?.showAlertView(error.getMessage())
                break
            }
        }
    }
}

extension ReasonSkipView{
    class func show(inView:UIView,callback:@escaping ReasonSkipViewCallback)  {
        let reasonSkipView = ReasonSkipView()
        reasonSkipView.callback = callback
        reasonSkipView.showViewInWindow()
    }
}

