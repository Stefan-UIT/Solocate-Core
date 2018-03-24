//
//  OrderPictureViewController.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import Photos
import XLPagerTabStrip
import TLPhotoPicker
import SDWebImage

class OrderPictureViewController: BaseOrderDetailViewController {
  
  fileprivate var selectedAssets: [TLPHAsset]!
  fileprivate let cellIdentifier = "PictureTableViewCell"
  fileprivate var imgTitle = ""
  fileprivate let cellHeight: CGFloat = 90.0
  fileprivate let headerHeight: CGFloat = 40.0
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var actionButton: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _orderDetail = orderDetail {
      actionButton.isHidden = _orderDetail.pictures.count > 0
    }
  }
  
  @IBAction func takePicture(_ sender: UIButton) {
    guard selectedAssets != nil && selectedAssets.count > 0 else {
      let picker = TLPhotosPickerViewController()
      picker.delegate = self
      present(picker, animated: true, completion: nil)
      return
    }
    // upload photos
    guard let order = orderDetail else {
      return
    }
    var imgData = [Data]()
    for item in selectedAssets {
      let data = UIImageJPEGRepresentation(item.fullResolutionImage ?? UIImage(), 0.5)
      imgData.append(data ?? Data())
    }
    showLoadingIndicator()
    APIs.uploadFiles(selectedAssets, name: imgTitle, orderID: "\(order.id)") { [unowned self] (errMsg) in
      self.dismissLoadingIndicator()
      if let msg = errMsg {
        self.showAlertView(msg)
      }
      else {
        self.showAlertView("Add image successfully")
      }
    }
  }
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "Picture")
  }
}

extension OrderPictureViewController {
  func showInputImageTitleWindow() {
    let alert = UIAlertController(title: "SRS Driver", message: "Plz input your image title", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (okAction) in
      alert.dismiss(animated: true, completion: nil)
      guard let textField = alert.textFields?.first,
        textField.hasText,
        let text = textField.text else {
          return
      }
      self.imgTitle = text
      self.tableView.reloadData()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [unowned self] (action) in
      alert.dismiss(animated: true, completion: nil)
      self.tableView.reloadData()
    }
    alert.addAction(cancelAction)
    alert.addAction(okAction)
    alert.addTextField { (textField) in
      textField.placeholder = "Input image title"
    }
    present(alert, animated: true, completion: nil)
  }
  
  @objc func didClearSelectedPhotot(_ sender: Any) {
    selectedAssets.removeAll()
    actionButton.setImage(UIImage(named: "plus_white"), for: .normal)
    tableView.reloadData()
    imgTitle = "" // clear title
  }
}


extension OrderPictureViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _orderDetail = orderDetail, _orderDetail.pictures.count > 0 {
      return _orderDetail.pictures.count
    }
    return selectedAssets != nil ? selectedAssets.count : 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PictureTableViewCell {
      if let _orderDetail = orderDetail, _orderDetail.pictures.count > 0 {
        let picture =  _orderDetail.pictures[indexPath.row]
        cell.nameLabel.text = picture.name
        cell.imgView.sd_setImage(with: URL(string: picture.link),
                                 placeholderImage: UIImage(named: "place_holder"),
                                 options: .refreshCached, completed: nil)
      }
      else {
        let asset = selectedAssets[indexPath.row]
        let imgName = imgTitle.length > 0 ? "\(imgTitle)" + "_\(indexPath.row)" : asset.originalFileName
        cell.nameLabel.text = imgName
        cell.imgView.image = asset.fullResolutionImage
      }
      
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard selectedAssets != nil && selectedAssets.count > 0 else {
      return nil
    }
    let padding: CGFloat = 10.0
    let clearButton = UIButton(frame: CGRect(x: padding, y: padding, width: view.frame.width - 2*padding , height: 40))
    clearButton.addTarget(self, action: #selector(self.didClearSelectedPhotot(_:)), for: .touchUpInside)
    clearButton.setTitle("Clear", for: .normal)
    clearButton.setTitleColor(AppColor.mainColor, for: .normal)
    clearButton.titleLabel?.textAlignment = .right
    return clearButton
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return selectedAssets != nil && selectedAssets.count > 0 ? headerHeight.scaleHeight() : 0.0000000001
  }
  
}

extension OrderPictureViewController: TLPhotosPickerViewControllerDelegate {
  func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
    let iconName = withTLPHAssets.count > 0 ? "upload" : "plus_white"
    actionButton.setImage(UIImage(named: iconName), for: .normal)
    selectedAssets = withTLPHAssets
  }
  
  func dismissComplete() {
    if selectedAssets.count > 0 {
      showInputImageTitleWindow()
    }
  }
  
  func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
    showAlertView("Your selection did exceed maximum number")    
  }
  
}
