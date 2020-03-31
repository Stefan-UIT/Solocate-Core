//
//  RouteDetailLoadPlanHeaderTbvCell.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 3/27/20.
//  Copyright © 2020 machnguyen_uit. All rights reserved.
//

import UIKit

class RouteDetailLoadPlanHeaderTbvCell: UITableViewCell {

    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var compartmentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureHeaderLiquidType(_ compartment: Compartment) {
        compartmentLabel.text = "compartment-id".localized + IntSlash(compartment.compartmentId)
        unitLabel.text = Slash(compartment.vol) + "L"
    }
    
    func configureHeaderPackedType(_ compartment: Compartment) {
        compartmentLabel.text = Slash(compartment.compartmentName)
        compartmentLabel.text = IntSlash(compartment.maxNumCompartment)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
