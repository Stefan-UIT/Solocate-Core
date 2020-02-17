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
import CoreData

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
    case InProgress = "IP"
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
        case .InProgress:
            return "in-progress".localized
        case .PickupStatus:
            return "picked-up".localized
        case .deliveryStatus:
            return "Delivered".localized
        case .CancelStatus:
            return "Cancelled".localized
        case .UnableToFinish:
            return "unable-to-finish".localized
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
            case .InTransit, .InProgress:
                return AppColor.InTransit;
            case .deliveryStatus, .PartialDelivered:
                return AppColor.deliveryStatus;
            case .CancelStatus,
                 .UnableToFinish:
                return AppColor.redColor;
            case .WarehouseClarification:
                return AppColor.orangeColor
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
    var id:Int = -1
    var address:String?
    var lattd:String?
    var lngtd:String?
    var name:String?
    var phone:String?
    var start_time:String?
    var end_time:String?
    var srvc_time:Int?
    var serviceTime:String {
        guard let minutes = srvc_time else { return "" }
        let string = (minutes > 1) ? ("\(minutes) " + "mins".localized.lowercased()) : ("\(minutes)" + "min".localized.lowercased())
        return string
    }
    var ctt_name:String?
    var ctt_phone:String?
    var seq = 1
    var loc_name:String?
    var floor:String?
    var apartment:String?
    var number:String?
    var actualTime:String?
    var openTime:String?
    var closeTime: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        address <- map["address"]
        lattd <- map["lattd"]
        lngtd <- map["lngtd"]
        name <- map["ctt_name"]
        phone <- map["ctt_phone"]
        start_time <- map["start_time"]
        end_time <- map["end_time"]
        srvc_time <- map["srvc_time"]
        ctt_name <- map["consignee_name"]
        ctt_phone <- map["consignee_phone"]
        seq <- map["seq"]
        loc_name <- map["loc_name"]
        floor <- map["floor"]
        apartment <- map["apt"]
        number <- map["number"]
        actualTime <- map["act_time"]
        openTime <- map["open_time"]
        closeTime <- map["close_time"]
    }
    
    func toCoreLocation(context:NSManagedObjectContext) -> CoreLocation {
        var result : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreLocation")
        fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        do {
            result = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        guard let coreLocation = result.first else {
            let locationDB = NSEntityDescription.entity(forEntityName: "CoreLocation", in: context)
            let _coreLocation:CoreLocation = CoreLocation(entity: locationDB!,
                                                          insertInto: context)
            _coreLocation.address = address ?? ""
            _coreLocation.apartment = apartment
            _coreLocation.cttName = ctt_name
            _coreLocation.cttPhone = ctt_phone ?? ""
            _coreLocation.endTime = end_time
            _coreLocation.startTime = start_time
            _coreLocation.floor = floor
            _coreLocation.id = Int16(id )
            _coreLocation.lattd = lattd
            _coreLocation.lngtd = lngtd
            _coreLocation.locName = loc_name
            _coreLocation.name =  name
            _coreLocation.number = number
            _coreLocation.phone = phone
            _coreLocation.seq = Int16(seq)
            _coreLocation.srvcTime = Int64(srvc_time ?? 0)
            
            print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
                                                           in: .userDomainMask).last ?? "Not Found!")
            do {
                try context.save()
            } catch {
                //  let nserror = error as NSError
                //  print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            return _coreLocation
        }
        return coreLocation as! CoreLocation
    }
}


//MARK: -Order
class Order: BaseModel {

    class Detail: BaseModel {
        
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
        
        struct Pivot:Mappable {
            var id:Int?
            var sku_id:Int?
            var shipping_order_id:Int?
            var unit_id:Int?
            var bcd:String?
            var batch_id:String?
            var qty:Int?
            var deliveredQty:Int?
            var loadedQty:Int?
            var returnedQty:Int?
            
            // Purchase Order
            var deliveringQty:Int?
            var remainingQty:Int?
            var uom:BasicModel?
            
            init?(map: Map) {
                //
            }
            
            mutating func mapping(map: Map) {
                id <- map["id"]
                sku_id <- map["sku_id"]
                shipping_order_id <- map["shipping_order_id"]
                unit_id <- map["unit_id"]
                bcd <- map["bcd"]
                batch_id <- map["batch_id"]
                qty <- map["qty"]
                
                loadedQty <- map["loaded_qty"]
//                if loadedQty != nil && loadedQty == 0 {
//                    loadedQty = nil // trick , cause server return 0 at the first time
//                }
//
                deliveredQty <- map["delivered_qty"]
//                if deliveredQty == nil {
//                    deliveredQty = qty // trick for default delivered qty
//                }
                
                returnedQty <- map["returned_qty"]
                
                deliveringQty <- map["delivering_qty"]
                remainingQty <- map["remaining_qty"]
                uom <- map["uom"]
            }
        }
        
        var id:Int = -1
        var name:String?
        var order_id:Int?
        var package_id:Int?
        var package:Package?
        var unit:Unit?
        var barCode:String?
        var packageRefId:Int?
        var wmsOrderCode:String?
        // NEW
        var pivot:Pivot?
        var isPallet:Bool {
            get {
                return package?.cd == PackageE.Pallet.rawValue
            }
        }
        var refCode:String?
        
        var nameReferenceCode: String? {
            var result:String?
            if name == nil && refCode == nil {
                return result
            } else if refCode == nil {
                result = name
                return result
            } else if name == nil {
                result = refCode
                return result
            } else {
                result = name! + " - " + refCode!
            }
            return result
        }
        
        override init() {
            super.init()
        }
        
        required init?(map: Map) {
            super.init()
        }
        
        override func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
            order_id <- map["order_id"]
            package_id <- map["package_id"]
            package <- map["package"]
            barCode <- map["barcode"]
            packageRefId <- map["pkg_ref_id"]
            unit <- map["unit"]
            pivot <- map["pivot"]
            refCode <- map["ref_cd"]
        }
        
        enum DetailUpdateType {
            case Load
            case Deliver
        }
        
        func jsonDetailUpdateORderStatus(updateType:DetailUpdateType = .Deliver, orderStatus:StatusOrder) -> [String:Any] {
            return self.pivot!.toJSON()
            
        }
        
        func getLoadedStatusWithLoadingQuantity() -> StatusOrder {
            if let loadedQty = pivot?.loadedQty, let qty = pivot?.qty {
                if loadedQty != qty {
                    return StatusOrder.PartialLoaded
                }
            }
            
            return StatusOrder.Loaded
        }
        
        func getFinishedStatusWithInputQuantity() -> StatusOrder {
            if let actualQty = pivot?.deliveredQty , let qty = pivot?.qty {
                if actualQty != qty {
                    return StatusOrder.PartialDelivered
                }
            }
            
            return StatusOrder.deliveryStatus
        }
        
        var isLoadedQtyEqualQty:Bool {
            get {
                if let _loadedQty = pivot?.loadedQty, let _qty = pivot?.qty {
                    return _loadedQty == _qty
                }
                return false
            }
        }
        
        var isValidLoadedQty:Bool {
            get {
                if let _loadedQty = pivot?.loadedQty, let _qty = pivot?.qty {
                    return (_loadedQty <= _qty && _loadedQty > 0)
                }
                return false
            }
        }
        
        var isDeliveredQtyEqualQty:Bool {
            get {
                if let _actualQty = pivot?.deliveredQty, let _qty = pivot?.qty {
                    return _actualQty == _qty
                }
                return false
            }
        }
        
        var isValidDeliveredQty:Bool {
            get {
                if let _deliveredQty = pivot?.deliveredQty, let _loadedQty = pivot?.loadedQty {
                    return _deliveredQty <= _loadedQty
                }
                return false
            }
        }
        
    }
    
    var isValidAllLoadedQty:Bool {
        get {
            guard let _details = details else { return false }
            let array = _details.filter({$0.isValidLoadedQty})
            let isAllValid = array.count == _details.count
            return isAllValid
        }
    }
    
    var isValidAllDeliveredQty:Bool {
        get {
            guard let _details = details else { return false }
            let array = _details.filter({$0.isValidDeliveredQty})
            let isAllValid = array.count == _details.count
            return isAllValid
        }
    }
    
    func getLoadedStatusWithLoadingQuantity() -> StatusOrder {
        guard let _details = details else { return .newStatus}
        let array = _details.filter({$0.isLoadedQtyEqualQty})
        let isAllEqual = array.count == _details.count
        return (isAllEqual) ? StatusOrder.Loaded : StatusOrder.PartialLoaded
    }
    
    func getDeliveredStatusWithDeliveredQuantity() -> StatusOrder {
        guard let _details = details else { return .newStatus}
        let array = _details.filter({$0.isDeliveredQtyEqualQty})
        let isAllEqual = array.count == _details.count
        return (isAllEqual) ? StatusOrder.deliveryStatus : StatusOrder.PartialDelivered
    }
    
//    func getFinishedStatusWithInputQuantity() -> StatusOrder {
//        if let actualQty = self.actualQty, let qty = self.qty {
//            if actualQty != qty {
//                return StatusOrder.PartialDelivered
//            }
//        }
//
//        return StatusOrder.deliveryStatus
//    }

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
    var purchaseOrderID = -1
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
    var totalQuantity:Int? {
        get {
            guard let _details = details else  {
                return nil
            }
            var total:Int = 0
            for item in _details {
                if let _qty = item.pivot?.qty {
                    total += _qty
                }
            }
            
            return total
        }
    }
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
    var customer_name:String {
        get {
            var fullname = ""
            fullname = (customer?.lastName ?? "") + " " + (customer?.firstName ?? "")
            return fullname
        }
    }
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
    
    var customer:UserModel.UserInfo?
    var typeID:Int = 0
    var group:String = ""
    var codComment:String?
    var cash_on_dlvy:String?
    var cod_rcvd:String?
    var wmsOrderCode:String?
    var wmsManifestNumber:String?
    var partialDeliveredReason:Reason?
    var remark:String?
    var remarkDriver:String?
    var remarkLocation:String?
    
    // NEW
    var division:BasicModel?
    var zone:BasicModel?
    
    var consigneeName:String? {
        get {
            let name = (isPickUpType) ? from?.ctt_name : to?.ctt_name
            return name
        }
    }
    
    var customerLocation:Address? {
        get {
            var address: Address?
            if isDeliveryType {
                address = to
            } else {
                if statusOrder == .newStatus {
                    address = from
                } else if statusOrder == .InProgress {
                    address = to
                } else {
                    address = to
                }
            }
            return address
        }
    }
    
    var skusName: String {
        get {
            var _skusName = ""
            for skuName in details ?? [] {
                _skusName = _skusName == "" ? (skuName.name ?? "") : _skusName + ", " + (skuName.name ?? "")
            }
            return _skusName
        }
    }
    
    lazy var orderGroup:OrderGroup = {
        return OrderGroup.init(rawValue: group) ?? OrderGroup.Logistic
    }()
    
    lazy var orderType:OrderType = {
        return OrderType.init(rawValue: typeID) ?? OrderType.delivery
    }()
    
    var isPickUpType:Bool {
        return orderType == OrderType.pickup
    }
    
    var isDeliveryType:Bool {
        return orderType == OrderType.delivery
    }
    
    var isNewStatus:Bool {
        return statusOrder == .newStatus
    }
    
    var isWarehouseClarification:Bool {
        return statusOrder == .WarehouseClarification
    }
    
    var isInTransit:Bool {
        return statusOrder == .InTransit
    }
    
    var isPartialDelivered:Bool {
        return statusOrder == .PartialDelivered
    }
    
    var isDelivery:Bool {
        return statusOrder == .deliveryStatus
    }
    
    var isLoaded:Bool {
        return statusOrder == .Loaded || statusOrder == .PartialLoaded
    }
    
    var isFinished:Bool {
        return statusOrder == .deliveryStatus || statusOrder == .PartialDelivered
    }
    
    var isCancelled:Bool {
        return statusOrder == .CancelStatus || statusOrder == .UnableToFinish
    }
    
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
        purchaseOrderID    <- map["purchase_order_id"]
        route_id <- map["route_id"]
        status_id <- map["shipping_status_id"]
        seq <- map["seq"]
        pod_req <- map["pod_req"]
        sig_req <- map["sig_req"]
        note <- map["note"]
        notes <- map["shipping_notes"]
        details <- map["shipping_details"]
        files <- map["shipping_files"]
        urgent_type_id <- map["urgent_type_id"]
        status <- map["shipping_status"]
        driver_id <- map["driver_id"]
        route <- map["route"]
        
        if  let dataFrom = map["shipping_from"].currentValue as? String{
            from    = Address(JSON: dataFrom.parseToJSON() ?? [:])
        }else{
            from    <- map["shipping_from"]
        }
        
        if  let dataTo = map["shipping_to"].currentValue as? String{
            to    = Address(JSON: dataTo.parseToJSON() ?? [:])
        }else{
            to    <- map["shipping_to"]
        }
        
        //NEW
        customer    <- map["shipping_customer"]
        typeID    <- map["shipping_type_id"]
        group    <- map["group"]
        cash_on_dlvy    <- map["cash_on_dlvy"]
        cod_rcvd    <- map["cod_rcvd"]
        codComment    <- map["cash_on_dlvy_cmnt"]
        wmsOrderCode    <- map["wms_order_cd"]
        wmsManifestNumber    <- map["wms_mnfst_no"]
        if let detail = details?.first { // cause Order & Detail is 1 to 1 relationship
            detail.wmsOrderCode = wmsOrderCode
//            detail.wmsManifestNumber = wmsManifestNumber
        }
        partialDeliveredReason    <- map["reason"]
        remark    <- map["remark"]
        remarkDriver <- map["remark_driver"]
        remarkLocation <- map["remark_location"]
        division <- map["shipping_division"]
        zone <- map["shipping_zone"]
    }
    
    
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
//        return false
        return sig_req == 1 && signature == nil
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


