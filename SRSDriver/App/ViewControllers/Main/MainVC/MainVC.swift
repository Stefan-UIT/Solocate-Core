//
//  MainVC.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 6/26/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class MainVC: BaseViewController {

    var rootNV:BaseNV?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pushRouteListVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Main_NV" {
            rootNV = segue.destination as? BaseNV
        }
    }
    
    func pushRouteListVC() {
        let vc:RouteListVC = .loadSB(SB: .Route)
        rootNV?.pushViewController(vc, animated: false)
    }
}
