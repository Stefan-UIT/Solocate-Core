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
  @IBOutlet weak var vNoImage: UIView?


  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    upateUI()
  }
    
    func upateUI() {
        if let _orderDetail = orderDetail {
            actionButton.isHidden = _orderDetail.pictures.count > 0
            if _orderDetail.pictures.count > 0 {
                headerView.removeFromSuperview()
            }
        }
        
        vNoImage?.isHidden = (selectedPictures.count > 0)
    }
  
  @IBAction func takePicture(_ sender: UIButton) {
    ImagePickerView.shared().showImageGallarySinglePick(atVC: self) { [weak self] (success, data) in
        if success{
            
            guard let img = data as? UIImage else {
                return
            }
            self?.inputTitleFor(img)
        }
    }
  }
  
  @IBAction func clearPhotos(_ sender: UIButton) {
    selectedPictures.removeAll()
    tableView.reloadData()
  }
  
  @IBAction func uploadPhotos(_ sender: UIButton) {
    //
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
      self.upateUI();
    }
    let cancelAction = UIAlertAction(title: "cancel".localized, style: .default) { [unowned self] (action) in
      alert.dismiss(animated: true, completion: nil)
      let pic = PictureObject(name: "", image: image)
      self.selectedPictures.insert(pic, at: 0)
      self.tableView.reloadData()
      self.upateUI();
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
    return  60
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let cell = tableView.cellForRow(at: indexPath) as? PictureTableViewCell {
     showImage(cell.imgView.image ?? UIImage(named: "place_holder")!)
    }
  }
}


struct PictureObject {
  var name: String
  var image: UIImage
  
  mutating func changeName(_ newName: String)  {
    self.name = newName
  }
}
