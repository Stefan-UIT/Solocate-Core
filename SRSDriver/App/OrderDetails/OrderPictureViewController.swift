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
import SDWebImage

class OrderPictureViewController: BaseOrderDetailViewController, UINavigationControllerDelegate {
  
  fileprivate let cellIdentifier = "PictureTableViewCell"
  fileprivate var imgTitle = ""
  fileprivate let cellHeight: CGFloat = 90.0
  fileprivate let headerHeight: CGFloat = 40.0
  
  fileprivate var selectedPictures = Array<PictureObject>()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var actionButton: UIButton!
  @IBOutlet weak var takePictureButton: UIButton!
  @IBOutlet weak var headerView: UIView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let _orderDetail = orderDetail {
      actionButton.isHidden = _orderDetail.pictures.count > 0
      if _orderDetail.pictures.count > 0 {
        headerView.removeFromSuperview()
      }
    }
  }
  
  @IBAction func takePicture(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .camera
    present(picker, animated: true, completion: nil)
  }
  
  @IBAction func clearPhotos(_ sender: UIButton) {
    selectedPictures.removeAll()
    tableView.reloadData()
  }
  
  @IBAction func uploadPhotos(_ sender: UIButton) {
//     upload photos
      guard let order = orderDetail, selectedPictures.count > 0 else {
        return
      }
      showLoadingIndicator()
      APIs.uploadFiles(selectedPictures, orderID: "\(order.id)") { [weak self] (errMsg) in
        self?.dismissLoadingIndicator()
        if let msg = errMsg {
          self?.showAlertView(msg)
        }
        else {
          self?.showAlertView("order_detail_add_image_successfully".localized, completionHandler: { (action) in
            self?.navigationController?.popToRootViewController(animated: true)
          })
        }
      }
  }
  
  override func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return IndicatorInfo(title: "order_detail_picture".localized)
  }
}

extension OrderPictureViewController {
  func inputTitleFor(_ image: UIImage) {
    let alert = UIAlertController(title: "order_detail_input_img_title".localized, message: nil, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "ok".localized, style: .default) { [unowned self] (okAction) in
      alert.dismiss(animated: true, completion: nil)
      guard let textField = alert.textFields?.first,
        textField.hasText,
        let text = textField.text else {
          return
      }
      self.imgTitle = text
      let pic = PictureObject(name: text, image: image)
      self.selectedPictures.insert(pic, at: 0)
      self.tableView.reloadData()
    }
    let cancelAction = UIAlertAction(title: "cancel".localized, style: .default) { [unowned self] (action) in
      alert.dismiss(animated: true, completion: nil)
      let pic = PictureObject(name: "", image: image)
      self.selectedPictures.insert(pic, at: 0)
      self.tableView.reloadData()
    }
    alert.addAction(cancelAction)
    alert.addAction(okAction)
    alert.addTextField { (textField) in
      textField.placeholder = "order_detail_input_img_title_hint".localized
    }
    present(alert, animated: true, completion: nil)
  }
  
  @objc func didClearSelectedPhotot(_ sender: Any) {
    tableView.reloadData()
    imgTitle = "" // clear title
  }
}


extension OrderPictureViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _orderDetail = orderDetail, _orderDetail.pictures.count > 0 {
      return _orderDetail.pictures.count
    }
    return selectedPictures.count
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
        let asset = selectedPictures[indexPath.row]
        cell.nameLabel.text = asset.name.length > 0 ? asset.name : "Untitle_\(indexPath.row)"
        cell.imgView.image = asset.image
      }
      
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight.scaleHeight()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let cell = tableView.cellForRow(at: indexPath) as? PictureTableViewCell {
     showImage(cell.imgView.image ?? UIImage(named: "place_holder")!)
    }
  }
  
}

extension OrderPictureViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }
    picker.dismiss(animated: true, completion: nil)
    inputTitleFor(img)
  }
}


struct PictureObject {
  var name: String
  var image: UIImage
  
  mutating func changeName(_ newName: String)  {
    self.name = newName
  }
}
