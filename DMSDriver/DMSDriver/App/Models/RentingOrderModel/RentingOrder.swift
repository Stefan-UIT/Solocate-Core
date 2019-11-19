//
//  RentingOrder.swift
//  DMSDriver
//
//  Created by Phong Nguyen on 9/24/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData

enum RentingOrderStatusCode: String {
    case NewStatus = "OP"
    case PartlyAssigned = "PA"
    case FullyAssigned = "FA"
    case InProgress = "IP"
    case Finished = "FH"
    case Cancelled = "CC"
    
    var statusName: String {
        switch self {
        case .NewStatus:
            return "New".localized
        case .PartlyAssigned:
            return "partly-assigned".localized
        case .FullyAssigned:
            return "fully-assigned".localized
        case .InProgress:
            return "in-progress".localized
        case .Finished:
            return "Finished".localized
        case .Cancelled:
            return "Cancelled".localized
        }
    }
    
    var color:UIColor {
        get {
            switch self {
            case .NewStatus, .PartlyAssigned:
                return AppColor.newStatus;
            case .InProgress:
                return AppColor.InTransit;
            case .FullyAssigned:
                return AppColor.mainColor
            case .Finished:
                return AppColor.deliveryStatus;
            case .Cancelled:
                return AppColor.redColor;
            }
        }
    }
    
    var code:Int {
        get {
            switch self {
            case .NewStatus:
                return 1
            case .PartlyAssigned:
                return 2
            case .FullyAssigned:
                return 3
            case .InProgress:
                return 4
            case .Finished:
                return 5
            case .Cancelled:
                return 6
            }
        }
    }
}
//MARK: RENTING
class RentingOrderCompany: BasicModel { }
class RentingOrderStatus: BasicModel { }

class RentingOrder: BaseModel {
    
    class RentingOrderSKU: BaseModel {
        var id:Int?
        var name:String?
        var referenceCode:String?
        var materialId:String?
        var unitTypeId:String?
        var ac:String?
        var companyId:Int?
        var barcode:Int?
        var packageId:Int?
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            referenceCode <- map["ref_cd"]
            materialId <- map["material_id"]
            unitTypeId <- map["unit_type_id"]
            ac <- map["ac"]
            companyId <- map["company_id"]
            barcode <- map["barcode"]
            packageId <- map["package_id"]
        }
    }
    
    class RentingOrderDetail: BaseModel {
        struct RentingTruckType:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            var fuelType:String?
            var numberOfCompartments:Int?
            var maxVol:String?
            var tachograph:Int?
            var companyId:Int?
            var manufacturer:String?
            var createdAt:String?
            var createdBy:Int?
            var updatedAt:String?
            var updatedBy:Int?
            var vol:String?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["code"]
                fuelType <- map["fuel_type"]
                numberOfCompartments <- map["num_of_compartments"]
                maxVol <- map["max_vol"]
                tachograph <- map["tachograph"]
                vol <- map["vol"]
                manufacturer <- map["manufacturer"]
                companyId <- map["company_id"]
                createdAt <- map["created_at"]
                createdBy <- map["created_by"]
                updatedAt <- map["updated_at"]
                updatedBy <- map["updated_by"]
            }
            
            func toCoreTruckType(context:NSManagedObjectContext) -> CoreTruckType {
                var result : [NSManagedObject] = []
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreTruckType")
                fetchRequest.predicate = NSPredicate(format: "id = \(id ?? 0)")
                do {
                    result = try context.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                guard let coreTruckType = result.first else {
                    let userInfoDB = NSEntityDescription.entity(forEntityName: "CoreTruckType", in: context)
                    let _coreTruckType:CoreTruckType = CoreTruckType(entity: userInfoDB!,
                                                         insertInto: context)
                    _coreTruckType.id = Int16(id ?? 0)
                    _coreTruckType.name = name
                    _coreTruckType.code = cd
                    _coreTruckType.fuelType = fuelType
                    _coreTruckType.manufacturer = manufacturer
                    _coreTruckType.vol = vol
                    _coreTruckType.createdAt = createdAt
                    _coreTruckType.createdBy = Int16(createdBy ?? 0)
                    _coreTruckType.updatedAt = updatedAt
                    _coreTruckType.updatedBy = Int16(updatedBy ?? 0)
                    
                    print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).last ?? "Not Found!")
                    do {
                        try context.save()
                    } catch {
                        //  let nserror = error as NSError
                        //  print("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    return _coreTruckType
                }
                return coreTruckType as! CoreTruckType
            }
            
//            func toCoreTankerType(context:NSManagedObjectContext) -> CoreTankerType {
//                var result : [NSManagedObject] = []
//                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreTankerType")
//                fetchRequest.predicate = NSPredicate(format: "id = \(id ?? 0)")
//                do {
//                    result = try context.fetch(fetchRequest)
//                } catch let error as NSError {
//                    print("Could not fetch. \(error), \(error.userInfo)")
//                }
//
//                guard let coreTankerType = result.first else {
//                    let userInfoDB = NSEntityDescription.entity(forEntityName: "CoreTankerType", in: context)
//                    let _coreTankerType:CoreTankerType = CoreTankerType(entity: userInfoDB!,
//                                                                     insertInto: context)
//                    _coreTankerType.id = Int16(id ?? 0)
//                    _coreTankerType.name = name
//                    _coreTankerType.maxVol = maxVol
//                    _coreTankerType.numOfCompartments = Int32(numberOfCompartments ?? 0)
//                    _coreTankerType.companyId = Int16(companyId ?? 0)
//                    _coreTankerType.tachograph = Int32(tachograph ?? 0)
//                    _coreTankerType.createdAt = createdAt
//                    _coreTankerType.createdBy = Int16(createdBy ?? 0)
//                    _coreTankerType.updatedAt = updatedAt
//                    _coreTankerType.updatedBy = Int16(updatedBy ?? 0)
//
//                    print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
//                                                                   in: .userDomainMask).last ?? "Not Found!")
//                    do {
//                        try context.save()
//                    } catch {
//                        //  let nserror = error as NSError
//                        //  print("Unresolved error \(nserror), \(nserror.userInfo)")
//                    }
//                    return _coreTankerType
//                }
//                return coreTankerType as! CoreTankerType
//            }
        }
        
        struct RentingTruck:Mappable {
            var id:Int?
            var typeId:Int?
            var driverId:Int?
            var maxWeight:Int?
            var selfWeight:Int?
            var maxVol:Int?
            var plateNum:String?
            var companyId:Int?
            var createdAt:String?
            var updatedAt:String?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                typeId <- map["type_id"]
                driverId <- map["driver_id"]
                maxWeight <- map["max_weight"]
                selfWeight <- map["self_weight"]
                maxVol <- map["max_vol"]
                plateNum <- map["plate_num"]
                if plateNum == nil {
                    plateNum <- map["plate_number"]
                }
                companyId <- map["company_id"]
                createdAt <- map["created_at"]
                updatedAt <- map["updated_at"]
            }
            
//            func toCoreTanker(context:NSManagedObjectContext) -> CoreTanker {
//                var result : [NSManagedObject] = []
//                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreTanker")
//                fetchRequest.predicate = NSPredicate(format: "id = \(id ?? 0)")
//                do {
//                    result = try context.fetch(fetchRequest)
//                } catch let error as NSError {
//                    print("Could not fetch. \(error), \(error.userInfo)")
//                }
//
//                guard let coreTanker = result.first else {
//                    let userInfoDB = NSEntityDescription.entity(forEntityName: "CoreTanker", in: context)
//                    let _coreTanker:CoreTanker = CoreTanker(entity: userInfoDB!,
//                                                         insertInto: context)
//                    _coreTanker.id = Int16(id ?? 0)
//                    _coreTanker.typeId = Int16(typeId ?? 0)
//                    _coreTanker.driverId = Int16(driverId ?? 0)
//                    _coreTanker.maxWeight = Int32(maxWeight ?? 0)
//                    _coreTanker.selfWeight = Int32(selfWeight ?? 0)
//                    _coreTanker.maxVol = Int32(maxVol ?? 0)
//                    _coreTanker.plateNum = plateNum
//                    _coreTanker.companyId = Int16(companyId ?? 0)
//                    _coreTanker.createdAt = createdAt
//                    _coreTanker.updatedAt = updatedAt
//
//                    print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
//                                                                   in: .userDomainMask).last ?? "Not Found!")
//                    do {
//                        try context.save()
//                    } catch {
//                        //  let nserror = error as NSError
//                        //  print("Unresolved error \(nserror), \(nserror.userInfo)")
//                    }
//                    return _coreTanker
//                }
//                return coreTanker as! CoreTanker
//            }
            
            func toCoreTruck(context:NSManagedObjectContext) -> CoreTruck {
                var result : [NSManagedObject] = []
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreTruck")
                fetchRequest.predicate = NSPredicate(format: "id = \(id ?? 0)")
                do {
                    result = try context.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                guard let coreTruck = result.first else {
                    let userInfoDB = NSEntityDescription.entity(forEntityName: "CoreTruck", in: context)
                    let _coreTruck:CoreTruck = CoreTruck(entity: userInfoDB!,
                                                                  insertInto: context)
                    _coreTruck.id = Int16(id ?? 0)
                    _coreTruck.typeId = Int16(typeId ?? 0)
                    _coreTruck.driverId = Int16(driverId ?? 0)
                    _coreTruck.maxWeight = Int32(maxWeight ?? 0)
                    _coreTruck.selfWeight = Int32(selfWeight ?? 0)
                    _coreTruck.maxVol = Int32(maxVol ?? 0)
                    _coreTruck.plateNum = plateNum
                    _coreTruck.companyId = Int16(companyId ?? 0)
                    _coreTruck.createdAt = createdAt
                    _coreTruck.updatedAt = updatedAt
                    
                    print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask).last ?? "Not Found!")
                    do {
                        try context.save()
                    } catch {
                        //  let nserror = error as NSError
                        //  print("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    return _coreTruck
                }
                return coreTruck as! CoreTruck
            }
        }
        
        struct RentingTanker:Mappable {
            var tankers:[RentingTruck]?
            var tankerType:[RentingTruckType]?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                tankers <- map["tankers"]
                tankerType <- map["tanker_type"]
            }
        }
        
        var id = -1
        var rentingOrderID = -1
        var truckTypeId = -1
        var truckId = -1
        var truckType:RentingTruckType?
        var truck:RentingTruck?
        var driver:UserModel.UserInfo?
        var sku:[RentingOrderSKU]?
        var tanker:RentingTanker?
        var driverId = -1
        // NEW
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            rentingOrderID <- map["renting_order_id"]
            truckTypeId <- map["truck_type_id"]
            truckId <- map["truck_id"]
            truckType <- map["truck_type"]
            truck <- map["truck"]
            driver <- map["driver"]
            sku <- map["sku"]
            tanker <- map["tanker"]
            driverId <- map["driver_id"]
        }
        
        var skulist: String {
            get {
                var _skuList = ""
                for each in 0..<(sku?.count ?? 0){
                    _skuList = _skuList == "" ? (sku?[each].name ?? "") : _skuList + ", " + (sku?[each].name ?? "")
                }
                return _skuList
            }
        }
        
    }
    
    var id = -1
    var referenceCode = ""
    var customerId = -1
    var startDate:String?
    var endDate:String?
    var truckTypeId = -1
    var truckQty:Int?
    var rentingOrderStatusId = -1
    var companyId = -1
    var createdBy = -1
    var updatedBy = -1
    var createdAt:String?
    var updatedAt:String?
    var rentingOrderTrucks:[Truck?] = []
    var rentingOrderDrivers:[UserModel.UserInfo?] = []
    var rentingOrderTankers:[Tanker?] = []
    var rentingOrderStatus:RentingOrderStatus?
    var rentingOrderCustomer:UserModel.UserInfo?
    var rentingOrderTruckType:TruckType?
    var rentingOrderSKUs:[RentingOrderSKU]?
    var rentingOrderCompany:RentingOrderCompany?
    var rentingOrderDetails:[RentingOrderDetail]?
//    var renting_order_creator:UserModel.UserInfo?
    
    var trailerTankers: String {
        get {
            var _trailerTankers = ""
            for trailerTanker in rentingOrderTankers {
                _trailerTankers = _trailerTankers == "" ? (trailerTanker?.name ?? "") : _trailerTankers + ", " + (trailerTanker?.name ?? "")
            }
            return _trailerTankers
        }
    }
    
    var rentingOrderStatusColor: UIColor {
        get {
            let _rentingOrderStatus = RentingOrderStatusCode(rawValue: rentingOrderStatus?.code ?? "")
            return _rentingOrderStatus?.color ?? AppColor.mainColor
        }
    }
    
    var skusName: String {
        get {
            var _skusName = ""
            for skuName in rentingOrderSKUs ?? [] {
                _skusName = _skusName == "" ? (skuName.name ?? "") : _skusName + ", " + (skuName.name ?? "")
            }
            return _skusName
        }
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        referenceCode <- map["ref_cd"]
        customerId <- map["cus_id"]
        startDate <- map["from_dt"]
        endDate <- map["to_dt"]
        truckTypeId <- map["truck_type_id"]
        truckQty <- map["truck_qty"]
        rentingOrderStatusId <- map["renting_order_status_id"]
        companyId <- map["company_id"]
        createdBy <- map["created_by"]
        updatedBy <- map["updated_by"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
//        rentingOrderTrucks <- map["renting_order_trucks"]
//        rentingOrderDrivers <- map["renting_order_drivers"]
//        rentingOrderTankers <- map["renting_order_tankers"]
        rentingOrderStatus <- map["renting_order_status"]
        rentingOrderCustomer <- map["renting_order_customer"]
//        rentingOrderTruckType <- map["renting_order_truck_type"]
//        rentingOrderSKUs <- map["renting_order_skus"]
        rentingOrderCompany <- map["renting_order_company"]
//        renting_order_creator <- map["renting_order_creator"]
        rentingOrderDetails <- map["renting_order_details"]
    }
    
    var startByDate: Date {
        get {
            guard let _startDate = startDate?.date else { return Date() }
            return _startDate
        }
    }
    
    var endByDate: Date {
        get {
            guard let _endDate = endDate?.date else { return Date() }
            return _endDate
        }
    }
}

