//
//  Order.swift
//  SRSDriver
//
//  Created by phunguyen on 3/15/18.
//  Copyright © 2018 SeldatInc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation


enum PackageE: String {
    case Pallet = "PLT"
    case Carton = "CTN"
    
    var name:String {
        switch self {
        case .Pallet:
            return "pallet".localized
        case .Carton:
            return "carton".localized
        }
    }
}

enum OrderGroup: String {
    case Terminal = "TERMINAL"
    case Bonded = "BONDED"
    case Free = "FREE"
    case Logistic = "LOGISTIC"
    
    var name: String {
        switch self {
        case .Terminal:
            return "terminal".localized
        case .Bonded:
            return "bonded".localized
        case .Free:
            return "free".localized
        case .Logistic:
            return "logistic".localized
        }
    }
}

enum StatusOrder: String {
    case newStatus = "OP"
    case InTransit = "IT"
    case deliveryStatus = "DV"
    case CancelStatus = "CC"
    case UnableToFinish = "UF"
    case PickupStatus = "PU"
    case Loaded = "LD"
    case WarehouseClarification = "WC"
    case PartialLoaded = "PL"
    case PartialDelivered = "PD"

    var statusName: String {
        switch self {
        case .newStatus:
            return "New".localized
        case .InTransit:
            return "in-transit".localized
        case .PickupStatus:
            return "picked-up".localized
        case .deliveryStatus:
            return "Finished".localized
        case .CancelStatus,
             .UnableToFinish:
            return "Cancelled".localized
        case .Loaded:
            return "loaded".localized
        case .PartialLoaded:
            return "partial-loaded".localized
        case .PartialDelivered:
            return "partial-delivered".localized
        case .WarehouseClarification:
            return "warehouse-clarification".localized
        }
    }
    
    var color:UIColor {
        get {
            switch self {
            case .newStatus, .Loaded, .PartialLoaded:
                return AppColor.newStatus;
            case .InTransit:
                return AppColor.InTransit;
            case .deliveryStatus, .PartialDelivered:
                return AppColor.deliveryStatus;
            case .CancelStatus,
                 .UnableToFinish:
                return AppColor.redColor;
            default:
                return AppColor.newStatus;
            }
        }
    }
}

enum OrderType:Int {
    case delivery = 1
    case pickup
    
    var name:String {
        switch self {
        case .pickup:
            return "Pickup".localized
        default:
            return "Delivery".localized
        }
    }
}


class Address: BaseModel {
    var address:String?
    var lattd:String?
    var lngtd:String?
    var name:String?
    var phone:String?
    var start_time:String?
    var end_time:String?
    var ctt_name:String?
    var ctt_phone:String?
    var seq = 1
    var loc_name:String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        address <- map["address"]
        lattd <- map["lattd"]
        lngtd <- map["lngtd"]
        name <- map["ctt_name"]
        phone <- map["ctt_phone"]
        start_time <- map["start_time"]
        end_time <- map["end_time"]
        ctt_name <- map["ctt_name"]
        ctt_phone <- map["ctt_phone"]
        seq <- map["seq"]
        loc_name <- map["loc_name"]
    }
}


//MARK: -Order
class Order: BaseModel {

    class Detail: BaseModel {
        
//        enum DetailStatus {
//            case NotLoad
//            case Loaded
//            case Unload
//
//            var name:String{
//                get{
//                    switch self {
//                    case .NotLoad:
//                        return "not-load".localized
//                    case .Loaded:
//                        return "loaded".localized
//                    case .Unload:
//                        return "unloaded".localized
//                    }
//                }
//            }
//        }
        
        struct Package:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["cd"]
            }
        }
        
        struct Unit:Mappable {
            var id:Int?
            var name:String?
            var cd:String?
            
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                name <- map["name"]
                cd <- map["cd"]
            }
        }
        
        var id:Int?
        var order_id:Int?
        var package_id:Int?
        var package:Package?
        var unit:Unit?
        var barCode:String?
        var packageRefId:Int?
        // NEW
        var qty:Int?
        var actualQty:Int?
        var cartonsInPallet:Int?
        var actualCartonsInPallet:Int?
        var loadedQty:Int?
        var loadedCartonsInPallet:Int?
        var returnedPalletQty:Int?
        var wmsOrderCode:String?
        var isPallet:Bool {
            get {
                return package?.cd == PackageE.Pallet.rawValue
            }
        }
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            order_id <- map["order_id"]
            package_id <- map["package_id"]
            qty <- map["qty"]
            actualQty <- map["dlvd_qty"]
            if actualQty == nil {
                actualQty = qty
            }
            cartonsInPallet <- map["ctn_in_plt"]
            actualCartonsInPallet <- map["ctn_dlvd"]
            if actualCartonsInPallet == nil {
                actualCartonsInPallet = cartonsInPallet
            }
//            remain_qty <- map["remain_qty"]
            package <- map["package"]
            barCode <- map["barcode"]
            packageRefId <- map["pkg_ref_id"]
            unit <- map["unit"]
            loadedQty <- map["load_qty"]
            loadedCartonsInPallet <- map["ctn_loaded"]
            returnedPalletQty <- map["plt_return"]
        }
        
        enum DetailUpdateType {
            case Load
            case Deliver
            case ReturnedPallet
        }
        
        func jsonDetailUpdateORderStatus(updateType:DetailUpdateType = .Deliver, orderStatus:StatusOrder) -> [String:Any] {
            var params:[String:Any] = [
                "id" : id ?? 0
            ]
            switch updateType {
            case .Load:
                if orderStatus == StatusOrder.Loaded || orderStatus == StatusOrder.PartialLoaded || orderStatus == StatusOrder.WarehouseClarification {
                    params["load_qty"] = loadedQty ?? 0
                    if isPallet {
                        params["ctn_loaded"] = loadedCartonsInPallet ?? 0
                    }
                }
                break
            case .ReturnedPallet:
                if orderStatus == StatusOrder.deliveryStatus || orderStatus == StatusOrder.PartialDelivered {
                    params["plt_return"] = returnedPalletQty ?? 0
                }
                break
            default:
                if orderStatus == StatusOrder.deliveryStatus || orderStatus == StatusOrder.PartialDelivered {
                    params["dlvd_qty"] = actualQty ?? 0
                    if isPallet {
                        params["ctn_dlvd"] = actualCartonsInPallet ?? 0
                    }
                }
                break
            }
            
            return params
        }
        
        func getLoadedStatusWithLoadingQuantity() -> StatusOrder {
            if let loadedQty = self.loadedQty, let qty = self.qty {
                if loadedQty != qty {
                    return StatusOrder.WarehouseClarification
                }
                
                if (self.isPallet) {
                    if let loadedCartons = self.loadedCartonsInPallet, let cartons = self.cartonsInPallet {
                        if loadedCartons != cartons {
                            return StatusOrder.WarehouseClarification
                        }
                    }
                }
            }
            
            return StatusOrder.Loaded
        }
    }

    class Nature: BaseModel {
        var id:Int?
        var name:String?
        var cd:String?
        var hazardous_mtrl:String?
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            cd <- map["cd"]
            hazardous_mtrl <- map["hazardous_mtrl"]
        }
    }
    
    class OrderGroupModel:BasicModel {}
    class OrderTypeModel:BasicModel {}

    var id = -1
    var from:Address?
    var to:Address?
    var route_id:Int = 0
    var status_id:Int?
    var seq:Int = 0
    var pod_req:Int?
    var sig_req:Int?
    var note:String?
    var notes:[Note] = []
    var details:[Detail]?
    var reason:Reason?
    var startTime = ""
    var endTime = ""
    var urgent_type_name_hb = ""
    var urgent_type_name_en = ""
    var driver_id:Int = 0
    var driver_name = ""
    var client_name = ""
    var order_type_name_hb = ""
    var order_type_name = ""
    var reason_msg:String?
    var custumer_name = ""
    var doubleType = -1
    var orderReference = ""
    var packages = 0
    var cartons = 0
    var truck_name = ""
    var collectionCall = ""
    var coordinationPhone = ""
    var standby = ""
    var receiveName = ""
    var apartment = ""
    var floor = ""
    var entrance = ""
    var full_addr = ""
    var receiverPhone = ""
    
    
    var urgent_type_id:Int = 0
    //var url:UrlFileMoldel?
    var files:[AttachFileModel]?

    var isSelect = false
    var directionRoute:[DirectionRoute]? // use for save DirectionRoute
    var route:Route?
    
    var status:Status?
    
    lazy var totalEstDuration:Int = {
        var total = 0
        directionRoute?.forEach({ (directionRoute) in
            directionRoute.legs.forEach({ (leg) in
                total += Int(leg.duration.value)
            })
        })
        
        return total
    }()
    
    lazy var totalEstDistance:Double = {
        var total:Double = 0
        directionRoute?.forEach({ (directionRoute) in
            directionRoute.legs.forEach({ (leg) in
                total += leg.distance.value
            })
        })
        
        return Double(total)
    }()
    
    // NEW
    var customer:UserModel?
    var typeID:Int = 0
    var group:String = ""
    var codComment:String?
    var cash_on_dlvy:String?
    var cod_rcvd:String?
    var wmsOrderCode:String?
    
    lazy var orderGroup:OrderGroup = {
        return OrderGroup.init(rawValue: group) ?? OrderGroup.Logistic
    }()
    
    lazy var orderType:OrderType = {
        return OrderType.init(rawValue: typeID) ?? OrderType.delivery
    }()
    
    var codAmount:Double? {
        get {
            return Double(cash_on_dlvy ?? "")
        }
    }
    var codReceived:Double? {
        get {
            return Double(cod_rcvd ?? "")
        }
    }
    
    var isHasCOD:Bool {
        get {
            guard let amount = codAmount else { return false }
            return amount > 0.0
        }
    }
    
    var isUpdatedCODReceived:Bool {
        get {
            guard let amount = codReceived else { return false }
            return amount > 0.0
        }
    }

    convenience required init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id    <- map["id"]
        route_id <- map["route_id"]
        status_id <- map["status_id"]
        seq <- map["seq"]
        pod_req <- map["pod_req"]
        sig_req <- map["sig_req"]
        note <- map["note"]
        notes <- map["notes"]
        details <- map["details"]
        files <- map["files"]
        urgent_type_id <- map["urgent_type_id"]
        status <- map["status"]
        driver_id <- map["driver_id"]
        route <- map["route"]
        
        if  let dataFrom = map["from"].currentValue as? String{
            from    = Address(JSON: dataFrom.parseToJSON() ?? [:])
        }else{
            from    <- map["from"]
        }
        
        if  let dataTo = map["to"].currentValue as? String{
            to    = Address(JSON: dataTo.parseToJSON() ?? [:])
        }else{
            to    <- map["to"]
        }
        
        //NEW
        customer    <- map["customer"]
        typeID    <- map["type_id"]
        group    <- map["group"]
        cash_on_dlvy    <- map["cash_on_dlvy"]
        cod_rcvd    <- map["cod_rcvd"]
        codComment    <- map["cash_on_dlvy_cmnt"]
        wmsOrderCode    <- map["wms_order_cd"]
        if let detail = details?.first { // cause Order & Detail is 1 to 1 relationship
            detail.wmsOrderCode = wmsOrderCode
        }
    }
    
    
//    func updateStatusDetailOrder()  {
//        for item in details ?? [] {
//            if statusOrder == .newStatus ||
//                statusOrder == .InTransit {
//                item.status = .NotLoad
//
//            }else if (statusOrder == .PickupStatus) {
//                item.status = .Loaded
//            }else if (statusOrder == .deliveryStatus) {
//                item.status = .Unload
//
//            }
//        }
//    }
    
    func getChunkedListLocation() -> [[CLLocationCoordinate2D]] {
        let currentLocation = LocationManager.shared.currentLocation?.coordinate
        var listLocation:[CLLocationCoordinate2D] = (currentLocation != nil) ? [currentLocation!] : []
        listLocation.append(locations)
        
        var listChunked = listLocation.chunked(by: 22)
        if listChunked.count > 1 {
            for i in 1..<listChunked.count{
                if let first = listChunked[i].first {
                    listChunked[i - 1].append(first)
                }
            }
        }
        
        return listChunked
    }
    
    var signature:AttachFileModel?{
        get{
            for i in 0..<(files?.count ?? 0){
                if files?[i].typeFile == "SIG"{
                    return files?[i]
                }
            }
            
            return nil
        }
    }
    
    var signName:String?
    
    var pictures:[AttachFileModel]?{
        get{
            
            var arr:[AttachFileModel]?
            for i in 0..<(files?.count ?? 0){
                if files?[i].typeFile != "SIG"{
                    if arr == nil {
                        arr = []
                    }
                    if let file = files?[i] {
                        arr?.append(file)
                    }
                }
            }
            
            return arr
        }
    }
    
    var statusCode :String{
        set{
        }
        get{
            return E(status?.code)
            
        }
    }
    
    var statusName :String{
        set{
            
        }
        get{
            return E(status?.name).localized
        }
    }

    var colorUrgent:UIColor{
        get{
            switch urgent_type_id {
            case 2:
                return AppColor.medium
            case 3:
                return AppColor.high
            default:
                return AppColor.normal
            }
        }
    }
    
    var statusOrder:StatusOrder{
        get{
            return StatusOrder(rawValue: E(status?.code)) ?? .newStatus
        }
    }

    
    var locationFrom:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:from?.lattd?.doubleValue ?? 0, longitude: from?.lngtd?.doubleValue ?? 0)
        }
    }
    
    
    var locationTo:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude:to?.lattd?.doubleValue ?? 0, longitude: to?.lngtd?.doubleValue ?? 0)
        }
    }
    
    var locations:[CLLocationCoordinate2D] {
        get {
             var arr:[CLLocationCoordinate2D] = []
             if let fromlattd = from?.lattd?.doubleValue ,
                let fromLngtd = from?.lngtd?.doubleValue {
                arr.append(CLLocationCoordinate2D(latitude:fromlattd, longitude: fromLngtd))
             }
            
            if let tolattd = to?.lattd?.doubleValue ,
                let toLngtd = to?.lngtd?.doubleValue {
                arr.append(CLLocationCoordinate2D(latitude:tolattd, longitude: toLngtd))
            }
            return arr
        }
    }
    
    var colorStatus:UIColor {
        get{
            return statusOrder.color
        }
    }
    
    func isRequireSign() -> Bool  {
        return false  //sig_req == 1 && signature == nil
    }
    
    func isRequireImage() -> Bool  {
        return false //pod_req == 1 && pictures?.count ?? 0 <= 0
    }
    
//    func validUpdateStatusOrder() -> Bool {
//        var valid = true
//        for item in details ?? []  {
//            if statusOrder == StatusOrder.InTransit {
//                if item.status != .Loaded {
//                    valid = false
//                    break
//                }
//            }else if statusOrder == StatusOrder.PickupStatus {
//                if item.status != .Unload {
//                    valid = false
//                    break
//                }
//            }
//        }
//        
//        return valid
//    }
    
    /*
    func cloneObject() -> Order? {
        let json = getJSONString()
        let obj = Order(JSON: json)
        return obj
    }
     */
}

//MARK: -UrlFileMoldel
class UrlFileMoldel: BaseModel {
    var id = -1
    var sig: AttachFileModel?
    var doc: [AttachFileModel]?
    
    override init() {
        super.init()
        doc = []
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        sig <- map["sig"]
        doc <- map["doc"]
    }
}

class Picture: NSObject, Mappable {
      var link = ""
      var name = ""
    
      required convenience init?(map: Map) {
        self.init()
      }
    
      func mapping(map: Map) {
        link <- map["link"]
        name <- map["name"]
      }
}


