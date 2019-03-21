//
//  StartRouteOrderVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 2/22/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit

class StartRouteOrderVC: BaseViewController {
    
    @IBOutlet weak var conBotActionView:NSLayoutConstraint?
    @IBOutlet weak var vAction :UIView?
    @IBOutlet weak var btnHidenViewAction :UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App().mainVC?.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        App().mainVC?.navigationController?.isNavigationBarHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }



    //MARK: - ACTION
    @IBAction func onbtnClickButtonRightHeader(btn:UIButton) {
        showSideMenu()
    }
    
    @IBAction func onbtnClickHidenActionView(btn:UIButton) {
        btnHidenViewAction?.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.conBotActionView?.constant = -200
            self.view.layoutSubviews()
            
        }) { (success) in
            //
        }
    }
    
    @IBAction func onbtnClickShowActionView(btn:UIButton) {
        btnHidenViewAction?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.conBotActionView?.constant = 0
            self.view.layoutSubviews()
            
        }) { (success) in
            //
        }
    }
    
    @IBAction func onbtnClickStart(btn:UIButton) {
        let viewController = PictureViewController()
        let navi = BaseNV(rootViewController: viewController)
        navi.statusBarStyle = .lightContent
        present(navi, animated: true, completion: nil)
    }
    
    @IBAction func onbtnClickSkip(btn:UIButton) {
        ReasonSkipView.show(inView: self.view) { (success, reaaon) in
            //
        }
    }
}
