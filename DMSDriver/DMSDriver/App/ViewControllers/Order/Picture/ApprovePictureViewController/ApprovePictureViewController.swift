//
//  ApprovePictureViewController.swift
//  SRSDriver
//
//  Created by MrJ on 2/12/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class ApprovePictureViewController: BaseViewController {

    // MARK: IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Variables
    var imageToApprove: UIImage?
    var navigationService = DMSNavigationService()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = imageToApprove
    }

    override func updateNavigationBar() {
        super.updateNavigationBar()
        App().statusBarView?.backgroundColor = AppColor.background
        navigationService.navigationItem = self.navigationItem
        navigationService.navigationBar = self.navigationController?.navigationBar
        navigationService.delegate = self
        navigationService.updateNavigationBar(.Menu,nil,AppColor.background)
    }
    
    // MARK: Action
    @IBAction func retryButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okButtonAction(_ sender: UIButton) {
        let viewController = SignatureViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}


//MARK: - DMSNavigationServiceDelegate
extension ApprovePictureViewController:DMSNavigationServiceDelegate{
    func didSelectedBackOrMenu() {
        showSideMenu()
    }
}
