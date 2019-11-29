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
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    private var listReason = [Reason]()
    private var callback:ReasonSkipViewCallback?
    private var reasonSelect:Reason?
    private var selectedIndex: Int = -1
    var isCancelledReason:Bool = true
    override init() {
        super.init()
      
   }
   
   convenience init(isCancelledReason:Bool) {
      self.init()
      tableView.register(UINib(nibName: "ReasonSkipTableViewCell", bundle: nil), forCellReuseIdentifier: "ReasonSkipTableViewCell")
      
      tableView.backgroundColor = .clear
      okButton.isEnabled = !(selectedIndex >= 0) ? false : true
      if isCancelledReason {
         getReasonList()
      } else {
         getReturnReasonList()
      }
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func dismiss() {
      if let vc = self.parentViewController {
         vc.dismiss(animated: true, completion: nil)
      }
   }
   
    //MARK: - ACTION
   @IBAction func onbtnClickDismissView(btn:UIButton){
      self.dismiss()
   }

    @IBAction func onbtnClickOK(btn:UIButton){
      guard selectedIndex >= 0 else {
         return
      }
      reasonSelect = listReason[selectedIndex]
      if noteTextView.text.count > 0 {
         reasonSelect?.message = noteTextView.text
      }
      callback?(true,reasonSelect)
      self.dismiss()
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
        okButton.isEnabled = !(selectedIndex >= 0) ? false : true
        tableView.reloadData()
    }
}

extension ReasonSkipView {
    func getReasonList() {
      let list = CoreDataManager.getListReason()
      self.listReason = list
      self.tableView.reloadData()
    }
   
    func getReturnReasonList() {
      let list = CoreDataManager.getListReasonPartialDeliverd()
      self.listReason = list
      self.tableView.reloadData()
    }
}

extension ReasonSkipView{
   class func show(inView:UIView, isCancelledReason:Bool = true, callback:@escaping ReasonSkipViewCallback)  {
      let reasonSkipView = ReasonSkipView.init(isCancelledReason: isCancelledReason)
      reasonSkipView.callback = callback
      reasonSkipView.showViewInWindow()
   }
   
   class func present(inViewController controller :UIViewController, isCancelledReason:Bool = true, callback:@escaping ReasonSkipViewCallback)  {
      let reasonSkipView = ReasonSkipView.init(isCancelledReason: isCancelledReason)
      reasonSkipView.callback = callback
      
      let vc = UIViewController()
      vc.view = reasonSkipView
      
      let nv:BaseNV = BaseNV()
      nv.isNavigationBarHidden = true
      nv.setViewControllers([vc], animated: false)
      controller.present(nv, animated: false, completion: nil)
   }
}

