//
//  ProfileVC.swift
//  DMSDriver
//
//  Created by phunguyen on 7/4/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit

class ProfileVC: BaseViewController {
  
  enum ProfileSection:Int {
    case sectionPublic = 0
    case sectionPrivate = 1
    
    static var count: Int {
      var max = 0
      while let _ = ProfileSection(rawValue: max){max = max + 1}
      return max
    }
    
    var title:String {
      switch self {
      case .sectionPublic:
        return "Public"
      case .sectionPrivate:
        return "Private"
      }
    }
  }
  
  
   @IBOutlet weak var tbvContent:UITableView?
  
    var user:UserModel?
  
    var publicInforDatas:[[String]] = []
    var privateInforDatas:[[String]] = []
  

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func setupTableView() {
      //
    }
  
    func initData() {
      publicInforDatas = [["Name",E(user?.userName)],
                        ["UserName","nguyenmach"],
                        ["Gender","Male"],
                        ["Title","Picker"],
                        ["Birth Date","05/03/2000"],]
    
      privateInforDatas = [["Phone","0978227588"],
                         ["Email","ksmmachnguyen.uit@gmail.com"]]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ProfileVC:UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return ProfileSection.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let profileSection = ProfileSection(rawValue: section)!
    switch profileSection {
    case .sectionPublic:
      return publicInforDatas[section].count
    case .sectionPrivate:
      return privateInforDatas[section].count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:ProfileCell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! ProfileCell
    
    
    return cell
  }
}
