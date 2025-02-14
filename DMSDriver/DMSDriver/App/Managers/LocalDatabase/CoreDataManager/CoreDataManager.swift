//
//  CoreDataManager.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 8/25/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let CoreDataManager =  _CoreDataManager.shared

enum Entity:String {
    case Route = "CoreRoute"
    case CoordinatorRoute = "CoreCoordinatorRoute"
    case Order = "CoreOrder"
    case Warehouse = "CoreWarehouse"
    case AttachFile = "CoreAttachFile"
    case UrlFile = "CoreUrlFile"
    case Reason = "CoreReason"
    case CoreStatus = "CoreStatus"
    case Request = "CoreRequest"
    case CoreRouteStatus = "CoreRouteStatus"
    case CoreRentingOrderStatus = "CoreRentingOrderStatus"
    case CoreSKU = "CoreSKU"
    case CoreLocation = "CoreLocation"
    case CoreNote = "CoreNote"
    case CoreUserInfo = "CoreUserInfo"
    case CoreRentingOrder = "CoreRentingOrder"
    case CoreTanker = "CoreTanker"
    case CoreTankerType = "CoreTankerType"
    case CoreTruck = "CoreTruck"
    case CoreTruckType = "CoreTruckType"
    case CoreRentingOrderDetail = "CoreRentingOrderDetail"
    case CorePurchaseOrderStatus = "CorePurchaseOrderStatus"
    case CoreRentingOrderDetailStatus = "CoreRentingOrderDetailStatus"

}

class _CoreDataManager {
    
    static let shared = _CoreDataManager()
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DMSDriver")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext (_ objectContext:NSManagedObjectContext? = nil) {
//        print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
//                                                       in: .userDomainMask).last ?? "Not Found!")
//    
        var context = persistentContainer.viewContext
        if let _objectContext = objectContext {
            context = _objectContext
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls)
        return urls[urls.count - 1] as NSURL
    }()
    
    //MARK: - CLEARE
    func clearAllDB()  {
        clearDatabase(entity: .Route)
        clearDatabase(entity: .CoordinatorRoute)
        clearDatabase(entity: .Reason)
        clearDatabase(entity: .Warehouse)
        clearDatabase(entity: .AttachFile)
        clearDatabase(entity: .UrlFile)
        clearDatabase(entity: .CoreNote)
        clearDatabase(entity: .CoreLocation)
        clearDatabase(entity: .Order)
        clearDatabase(entity: .CoreStatus)
        clearDatabase(entity: .Request)
        clearDatabase(entity: .CoreRouteStatus)
        clearDatabase(entity: .CoreRentingOrderStatus)
        clearDatabase(entity: .CoreSKU)
        clearDatabase(entity: .CoreUserInfo)
        clearDatabase(entity: .CoreTanker)
        clearDatabase(entity: .CoreTankerType)
        clearDatabase(entity: .CoreTruck)
        clearDatabase(entity: .CoreTruckType)
        clearDatabase(entity: .CoreRentingOrderDetail)
        clearDatabase(entity: .CoreRentingOrder)
        clearDatabase(entity: .CorePurchaseOrderStatus)
    }
    
    func clearDatabase(entity:Entity) {
        let context = self.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        let coredata = CoreDataManager.getListCoreData(entity.rawValue)
        print("Database \(entity.rawValue): \(coredata.count)")
    }

    
    
    //MARK: - REQUEST
    func saveRequest(_ request:RequestModel ) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let coreRequest = self?.createRecordForEntity(Entity.Request.rawValue ,
                                                    inManagedObjectContext: context) as? CoreRequest
            
            coreRequest?.server = request.server
            coreRequest?.path = request.path
            coreRequest?.method = request.method
            coreRequest?.body = request.body
            coreRequest?.header = request.header
            coreRequest?.timetamps = request.timetamps ?? Date().timeIntervalSince1970
            coreRequest?.userId = Int64(Caches().user?.userInfo?.id ?? 0)
            
            self?.saveContext(context)
        }
        
    }
    
    func getAllRequest(_ userId:Int, callback:@escaping (Bool,[RequestModel]) -> Void){
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "userId = \(userId)")
            let listCoreRequest = self?.fetchRecordsForEntity(Entity.Request.rawValue,
                                                        predicate: predicate,
                                                        inManagedObjectContext: context) as? [CoreRequest]
            
            let results = listCoreRequest?.sorted(by: { (item1, item2) -> Bool in
                return item2.timetamps > item1.timetamps
            })
            
            var arr:[RequestModel] = []
            results?.forEach({ (item) in
                arr.append(item.convertToRequestModel())
            })
            
            DispatchQueue.main.async {
                callback(true,arr)
            }
        }
    }
    
    func countRequest(_ userId:Int, callback:@escaping (Bool,Int) -> Void){
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "userId = \(userId)")
            let listCoreRequest = self?.fetchRecordsForEntity(Entity.Request.rawValue,
                                                             predicate: predicate,
                                                             inManagedObjectContext: context) as? [CoreRequest]
            DispatchQueue.main.async {
                callback(true,listCoreRequest?.count ?? 0)
            }
        }
    }
    
    func countRequestLocal() -> Int{
        let predicate = NSPredicate(format: "userId = \(Caches().user?.userInfo?.id ?? 0)")
        let listCoreRequest = self.fetchRecordsForEntity(Entity.Request.rawValue,
                                                         predicate: predicate,
                                                         inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreRequest]
        
        return listCoreRequest?.count ?? 0
    }
    
    //MARK: - RENTING ORDER
    func saveRentingOrder(_ rentingOrder:[RentingOrder], callback:((Bool,[RentingOrder]) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask { [weak self] (context) in
            rentingOrder.forEach({ (order) in
                let coreRentingOrder = self?.queryCoreRentingOrderById(order.id, context)
                if coreRentingOrder != nil {
                    rentingOrder.forEach({ (order) in
                        self?.updateRentingOrder(order)
                    })
                } else {
                    let _ = self?.insertRentingOrder(order, context)
                }
            })
            DispatchQueue.main.async {
                callback?(true,rentingOrder)
            }
        }
    }
    
    //MARK: - ROUTE
    func saveRoutes(_ routes:[Route], callback:((Bool,[Route]) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            routes.forEach { (route) in
                let coreRoute = self?.queryCoreRouteById(route.id,context)
                if coreRoute != nil{
                    //context.delete(coreRoute!)
                    //self.updateRouteOnCoreCooradinator(coreRoute!, route, context)
                    routes.forEach({ (route) in
                        self?.updateRoute(route)
                    })
                }else{
                    let _ = self?.insertRoute(route, context)
                }
            }
            DispatchQueue.main.async {
                callback?(true,routes)
            }
        }
    }
    
    func addRoutesToEntity(_ routes:[Route], _ entity:Entity)  {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            routes.forEach { (route) in
                let _ = self?.insertRoute(route, context)
            }
        }
    }
    
    func saveCoordinatorRoute(_ coordinatorRoute: CoordinatorRoute,
                              _ onConplate:@escaping (Bool)->Void)  {
        
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let coreCoordinatorRoutes = self?.fetchRecordsForEntity(Entity.CoordinatorRoute.rawValue,
                                                                   inManagedObjectContext: context) as? [CoreCoordinatorRoute]
            
            if coreCoordinatorRoutes?.count ?? 0 <= 0 { // new
                self?.insertCoordinatorRoute(coordinatorRoute, context: context)
                
            }else{
                
                let coreCoordinatorRoute:CoreCoordinatorRoute? =
                    coreCoordinatorRoutes?.filter({ (item) -> Bool in
                        return coordinatorRoute.date == item.date
                    }).last
                
                if coreCoordinatorRoute != nil{
//                    self.delete(object: coreCoordinatorRoute!,
//                                context: context,
//                                onCompletion: { (success) in
//                        self.insertCoordinatorRoute(coordinatorRoute, context: context)
//                    })
//
                    self?.updateCoreCoordinatorRoute(coreCoordinatorRoute!, coordinatorRoute, context)
                    
                }else{
                    self?.insertCoordinatorRoute(coordinatorRoute, context: context)
                    
                }
            }
            DispatchQueue.main.async {
                onConplate(true)
            }
        }
    }
    
    func insertCoordinatorRoute(_ coordinatorRoute: CoordinatorRoute,context:NSManagedObjectContext) {
        let desEntity = NSEntityDescription.entity(forEntityName:Entity.CoordinatorRoute.rawValue ,
                                                   in: context)
        let routeCoordinatorCore:CoreCoordinatorRoute = CoreCoordinatorRoute(entity: desEntity!,
                                                                             insertInto: context)
        
        routeCoordinatorCore.setAttributeFrom(coordinatorRoute)
        coordinatorRoute.drivers?.forEach { (route) in
            let coreRoute =  self.insertRoute(route, context)
            routeCoordinatorCore.addToDrivers(coreRoute)
        }
        
        coordinatorRoute.coordinator?.forEach { (route) in
            let coreRoute =  self.insertRoute(route, context)
            routeCoordinatorCore.addToCoordinator(coreRoute)
        }
        self.saveContext(context)
    }
    
    func updateCoreCoordinatorRoute(_ routeCoordinatorCore: CoreCoordinatorRoute,
                                    _ coordinatorRoute: CoordinatorRoute,
                                    _ context:NSManagedObjectContext) {
        routeCoordinatorCore.setAttributeFrom(coordinatorRoute)
        (routeCoordinatorCore.drivers?.allObjects as? [CoreRoute])?.forEach({ (core) in
            context.delete(core)
        })
        (routeCoordinatorCore.coordinator?.allObjects as? [CoreRoute])?.forEach({ (core) in
            context.delete(core)
        })
      
        coordinatorRoute.drivers?.forEach { (route) in
            let coreRoute =  self.insertRoute(route, context)
            routeCoordinatorCore.addToDrivers(coreRoute)
        }
        
        coordinatorRoute.coordinator?.forEach { (route) in
            let coreRoute =  self.insertRoute(route, context)
            routeCoordinatorCore.addToCoordinator(coreRoute)
        }
        self.saveContext(context)
    }
    
    func queryCoordinatorRoute(_ stringDate:String, callback:@escaping (Bool,CoordinatorRoute) -> Void){
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let coordinatorRoutes = self?.fetchRecordsForEntity(Entity.CoordinatorRoute.rawValue, inManagedObjectContext: context)
            let _result = (coordinatorRoutes as? [CoreCoordinatorRoute])?.filter({ (coordinatorRoute) -> Bool in
                return coordinatorRoute.date == stringDate
            }).last
            
            let result = _result?.convertToCoordinatorRoute() ?? CoordinatorRoute()
            DispatchQueue.main.async {
                callback(true,result)
            }
        }
    }
    
    func deleteCoordinatorRoute(_ stringDate:String){
        self.persistentContainer.performBackgroundTask({[weak self] (context) in
            let coordinatorRoutes = self?.fetchRecordsForEntity(Entity.CoordinatorRoute.rawValue, inManagedObjectContext: context)
            if let _result = (coordinatorRoutes as? [CoreCoordinatorRoute])?.filter({ (coordinatorRoute) -> Bool in
                return coordinatorRoute.date == stringDate
                
            }).last {
                self?.delete(object: _result, context: context, onCompletion: { (success) in
                    //
                })
            }
        })
    }
    
    //MARK : - RENTING ORDER
    func updateRentingOrder(_ rentingOrder:RentingOrder,_ callback:((Bool,RentingOrder) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "id = \(rentingOrder.id)")
            let results = self?.fetchRecordsForEntity(Entity.CoreRentingOrder.rawValue,
                                                      predicate:predicate,
                                                      inManagedObjectContext: context) as? [CoreRentingOrder]
            results?.forEach { (coreRentingOrder) in
                if coreRentingOrder.id == rentingOrder.id {
                    
                    coreRentingOrder.setAttribiteFrom(rentingOrder, context: context)
                }
            }
            self?.saveContext(context)
        }
        callback?(true,rentingOrder)
    }
    
    func insertRentingOrder(_ rentingOrder:RentingOrder,_ context:NSManagedObjectContext) -> CoreRentingOrder  {
        let rentingOrderDB = NSEntityDescription.entity(forEntityName:Entity.CoreRentingOrder.rawValue ,                                                                in: context)
        let rentingOrderDetailDB = NSEntityDescription.entity(forEntityName: Entity.CoreRentingOrderDetail.rawValue,
                                                    in: context)!
        let skuDB = NSEntityDescription.entity(forEntityName: Entity.CoreSKU.rawValue,
                                               in: context)
        let tankerDB = NSEntityDescription.entity(forEntityName: Entity.CoreTanker.rawValue, in: context)!
        let tankerTypeDB = NSEntityDescription.entity(forEntityName: Entity.CoreTankerType.rawValue, in: context)!
        let coreRentingOrder:CoreRentingOrder = CoreRentingOrder(entity: rentingOrderDB!,
                                                                 insertInto: context)
        rentingOrder.rentingOrderDetails?.forEach({ (detail) in
            let coreRentingOrderDetail:CoreRentingOrderDetail = CoreRentingOrderDetail(entity: rentingOrderDetailDB, insertInto: context)
            coreRentingOrderDetail.setAttributeFrom(detail, context: context)
            coreRentingOrder.addToDetails(coreRentingOrderDetail)
            
            detail.sku?.forEach({ (eachSKU) in
                let coreSKU:CoreSKU = CoreSKU(entity: skuDB!,insertInto: context)
                coreSKU.setAttributeFrom(eachSKU)
                coreSKU.id = Int16(eachSKU.id ?? 0)
                coreRentingOrderDetail.addToSku(coreSKU)
                coreSKU.addToSku(coreRentingOrderDetail)
            })
            
            detail.tanker?.tankers?.forEach({ (tanker) in
                let coreTanker:CoreTanker = CoreTanker(entity: tankerDB, insertInto: context)
                coreTanker.setAttribiteFrom(tanker: tanker)
                coreTanker.id = Int16(tanker.id ?? 0)
                coreRentingOrderDetail.addToTankers(coreTanker)
            })
            
            detail.tanker?.tankerType?.forEach({ (tankerType) in
                let coreTankerType:CoreTankerType = CoreTankerType(entity: tankerTypeDB, insertInto: context)
                coreTankerType.setAttribiteFrom(tankerType: tankerType)
                coreTankerType.id = Int16(tankerType.id ?? 0)
                coreRentingOrderDetail.addToTankerType(coreTankerType)
            })
            
        })
//        rentingOrder.rentingOrderDetails?.forEach({ (detail) in
//            let coreRentingOrderDetail:CoreRentingOrderDetail = CoreRentingOrderDetail(entity: rentingOrderDetailDB,
//                                                         insertInto: context)
//            coreRentingOrderDetail.setAttributeFrom(detail, context: context)
//            detail.sku?.forEach({ (eachSKU) in
//                let coreSKU:CoreSKU = CoreSKU(entity: skuDB!, insertInto: context)
//                coreSKU.setAttributeFrom(eachSKU)
//                coreSKU.id = Int16(eachSKU.id ?? 0)
//                coreRentingOrderDetail.addToSku(coreSKU)
//                coreSKU.addToSku(coreRentingOrderDetail)
//            })
//            coreRentingOrder.addToDetails(coreRentingOrderDetail)
//        })
        coreRentingOrder.setAttribiteFrom(rentingOrder, context: context)
        saveContext(context)
        return coreRentingOrder
    }
    
    
    //MARK : - ROUTE
    func updateRoute(_ route:Route,_ callback:((Bool,Route) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "id = \(route.id)")
            let results = self?.fetchRecordsForEntity(Entity.Route.rawValue,
                                                predicate:predicate,
                                                inManagedObjectContext: context) as? [CoreRoute]
            results?.forEach { (coreRoute) in
                if coreRoute.id == route.id {
                    coreRoute.setAttribiteFrom(route)
                    route.locationList.forEach({ (location) in
                        //LocationList
                        let predicateLocation = NSPredicate(format: "id = \(location.id)")
                        let coreLocation = (self?.fetchRecordsForEntity(Entity.CoreLocation.rawValue, predicate: predicateLocation, inManagedObjectContext: context) as? [CoreLocation])?.last
                        if let _coreLocation = coreLocation {
                            _coreLocation.setAttributeFrom(location)
                        } else {
                            let locationDB = NSEntityDescription.entity(forEntityName: Entity.CoreLocation.rawValue, in: context)
                            let coreLocation:CoreLocation = CoreLocation(entity: locationDB!, insertInto: context)
                            
                            // Set LocationList Attribute
                            coreLocation.setAttributeFrom(location)
                            coreRoute.addToLocationList(coreLocation)
                        }
                    })
                    route.orderList.forEach({ (order) in
                        order.driver_id = route.driverId
                        order.driver_name = route.driver_name
                        
                        let predicate = NSPredicate(format: "id = \(order.id)")
                        let coreOrder = (self?.fetchRecordsForEntity(Entity.Order.rawValue,
                                                               predicate: predicate ,
                                                               inManagedObjectContext: context) as? [CoreOrder])?.last
                        
                        if let _coreOrder = coreOrder{
                            _coreOrder.setAttribiteFrom(order, context: context)
                            
                        }else {
                            let orderDB = NSEntityDescription.entity(forEntityName:Entity.Order.rawValue,
                                                                     in: context)
                            let coreOdr:CoreOrder = CoreOrder(entity: orderDB!,
                                                              insertInto: context)
                            // Set List Attribute
                            coreOdr.setAttribiteFrom(order, context: context)
                            coreOdr.driver_id = Int16(route.driverId)
                            coreRoute.addToOrderList(coreOdr)
                        }
                        
                        // File
                        order.files?.forEach{ (file) in
                            let predicate = NSPredicate(format: "id = \(file.id)")
                            let coreAttachFile = (self?.fetchRecordsForEntity(Entity.AttachFile.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreAttachFile])?.last
                            if let _coreAttach = coreAttachFile {
                                _coreAttach.setAttributeFrom(file)
                            } else {
                                let fileDB = NSEntityDescription.entity(forEntityName: Entity.AttachFile.rawValue, in: context)
                                let _coreFile:CoreAttachFile = CoreAttachFile(entity: fileDB!, insertInto: context)
                                _coreFile.id = Int32(file.id )
                                _coreFile.setAttributeFrom(file)
                                coreOrder?.addToOrderFile(_coreFile)
                            }
                        }

                        // Order Note
                        order.notes.forEach({ (note) in
                            let predicate = NSPredicate(format: "id = \(note.id)")
                            let coreNote = (self?.fetchRecordsForEntity(Entity.CoreNote.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreNote])?.last
                            if let _coreNote = coreNote {
                                _coreNote.setAttributeFrom(note)
                            } else {
                                let noteDB = NSEntityDescription.entity(forEntityName: Entity.CoreNote.rawValue, in: context)
                                let _coreNote:CoreNote = CoreNote(entity: noteDB!, insertInto: context)
                                _coreNote.id = Int16(note.id)
                                _coreNote.setAttributeFrom(note)
                                coreOrder?.addToOrderNote(_coreNote)
                            }
                            note.files.forEach{ (file) in
                                let predicate = NSPredicate(format: "id = \(file.id)")
                                let coreAttachFile = (self?.fetchRecordsForEntity(Entity.AttachFile.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreAttachFile])?.last
                                if let _coreAttach = coreAttachFile {
                                    _coreAttach.setAttributeFrom(file)
                                } else {
                                    let fileDB = NSEntityDescription.entity(forEntityName: Entity.AttachFile.rawValue, in: context)
                                    let _coreFile:CoreAttachFile = CoreAttachFile(entity: fileDB!, insertInto: context)
                                    _coreFile.id = Int32(file.id )
                                    _coreFile.setAttributeFrom(file)
                                    coreNote?.addToNoteFile(_coreFile)
                                }
                            }
                        })

                        
                        // SKUs
                        order.details?.forEach{ (detail) in
                            let predicate = NSPredicate(format: "id = \(detail.pivot?.id ?? 0)")
                            let coreSKU = (self?.fetchRecordsForEntity(Entity.CoreSKU.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreSKU])?.last
                            if let _coreSKU = coreSKU {
                                _coreSKU.setAttributeFrom(detail)
                            } else {
                                let detailDB = NSEntityDescription.entity(forEntityName: Entity.CoreSKU.rawValue, in: context)
                                let coreSKU:CoreSKU = CoreSKU(entity: detailDB!, insertInto: context)
                                
                                coreSKU.id = Int16(detail.pivot?.id ?? 0)
                                // Set List Attribute
                                coreSKU.setAttributeFrom(detail)
                                coreOrder?.addToDetail(coreSKU)
                            }
                        }
                    })
                }
            }
            self?.saveContext(context)
            callback?(true,route)
        }
    }
    
    // Add route to CoreRoute table
    func insertRoute(_ route:Route,_ context:NSManagedObjectContext) -> CoreRoute  {
        let routeDB = NSEntityDescription.entity(forEntityName:Entity.Route.rawValue ,
                                                 in: context)
        let orderDB = NSEntityDescription.entity(forEntityName:Entity.Order.rawValue,
                                                 in: context)
        let wareHouseDB = NSEntityDescription.entity(forEntityName:Entity.Warehouse.rawValue,
                                                 in: context)
        let reasonDB = NSEntityDescription.entity(forEntityName:Entity.Reason.rawValue,
                                                     in: context)
        let urlDB = NSEntityDescription.entity(forEntityName:Entity.UrlFile.rawValue,
                                                  in: context)
        let skuBD = NSEntityDescription.entity(forEntityName: Entity.CoreSKU.rawValue,
                                               in: context)
        let locationDB = NSEntityDescription.entity(forEntityName: Entity.CoreLocation.rawValue,
                                                    in: context)
        let attachFileDB = NSEntityDescription.entity(forEntityName: Entity.AttachFile.rawValue,
                                                      in: context)!
        let orderNote = NSEntityDescription.entity(forEntityName: Entity.CoreNote.rawValue,
                                                   in: context)

        let coreRoute:CoreRoute = CoreRoute(entity: routeDB!,
                                            insertInto: context)
        
            route.locationList.forEach({ (location) in
                let coreLocation:CoreLocation = CoreLocation(entity: locationDB!,
                                                             insertInto: context)
                coreLocation.setAttributeFrom(location)
                coreRoute.addToLocationList(coreLocation)
            })
            
            route.orderList.forEach({ (order) in
                let coreOrder:CoreOrder = CoreOrder(entity: orderDB!,
                                                    insertInto: context)
                // Set List Attribute
                coreOrder.setAttribiteFrom(order, context: context)
                coreOrder.driver_id = Int16(route.driverId)
                
                // Order File
                order.files?.forEach{ (file) in
                    let coreAttachFile:CoreAttachFile = CoreAttachFile(entity: attachFileDB, insertInto: context)
                    coreAttachFile.id = Int32(file.id)
                    coreAttachFile.setAttributeFrom(file)
                    coreOrder.addToOrderFile(coreAttachFile)
                }
                
                // Order Note
                order.notes.forEach({ (note) in
                    let coreNote:CoreNote = CoreNote(entity: orderNote!,
                                                     insertInto: context)
                    coreNote.setAttributeFrom(note)
                    coreNote.id = Int16(note.id)
                    note.files.forEach({ (file) in
                        let coreAttachFile:CoreAttachFile = CoreAttachFile(entity: attachFileDB, insertInto: context)
                        coreAttachFile.id = Int32(file.id)
                        coreAttachFile.setAttributeFrom(file)
                        coreNote.addToNoteFile(coreAttachFile)
                    })
                    coreOrder.addToOrderNote(coreNote)
                })

                // SKUs
                order.details?.forEach({ (detail) in
                    let coreSKU:CoreSKU = CoreSKU(entity: skuBD!, insertInto: context)
                    
                    // Set Details Attribute
                    coreSKU.setAttributeFrom(detail)
                    coreSKU.id = Int16(detail.pivot?.id ?? 0)
                    
                    // Set List Relationship
                    coreOrder.addToDetail(coreSKU)
                })
                
                // Set List Relationship
                coreRoute.addToOrderList(coreOrder)
            })
        
        
        coreRoute.setAttribiteFrom(route)
        saveContext(context)
        return coreRoute
    }
    
    func deleteCoreRoute(_ coreRoute:CoreRoute,
                     _ context:NSManagedObjectContext,
                     _ onCompletion:@escaping (_ status:Bool) -> Void) {
        delete(object: coreRoute, context: context, onCompletion: onCompletion)
    }
    
    func deleteRoutes(_ stringDate:String, onCompletion:@escaping (_ status:Bool) -> Void) {
        CoreDataManager.queryRoutes(stringDate) {[weak self] (success, routes) in
            if success{
                routes.forEach({ (route) in
                    self?.deleteRoute(route)
                })
            }
        }
    }
    
    func deleteRoute(_ route:Route) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            if let coreRoute = self?.queryCoreRouteById(route.id, context) {
                self?.delete(object: coreRoute, context: context, onCompletion: { (success) in
                    //
                })
            }
        }
    }
    
    func deleteAttachFileById(_ id:Int, context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id = \(id)")
        let coreFile = fetchRecordsForEntity(Entity.AttachFile.rawValue,
                                             predicate:predicate,
            inManagedObjectContext: context).last
        
        if let _coreFile = coreFile {
            delete(object: _coreFile, context: context) { (success) in
                //
            }
        }
    }
    
    func queryRentingOrderBy(_ id:Int, _ callback:@escaping (Bool,RentingOrder?)-> Void) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let order = self?.queryCoreRentingOrderById(id, context)
            let rentingOrder = order?.convertToRentingOrder()
            
            DispatchQueue.main.async {
                callback(true,rentingOrder)
            }
        }
    }
    
    func queryCoreRentingOrderById(_ id: Int,_ context:NSManagedObjectContext) -> CoreRentingOrder? {
        let fetchRequest:NSFetchRequest = CoreRentingOrder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        let orders = try? context.fetch(fetchRequest)
        return orders?.first
    }
    
    func queryRouteBy(_ id: Int, _ callback:@escaping (Bool,Route?)-> Void) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let item = self?.queryCoreRouteById(id, context)
            let route = item?.convertToRoute()
            
            DispatchQueue.main.async {
                callback(true, route)
            }
        }
    }
    
    
    func queryCoreRouteById(_ id: Int,_ context:NSManagedObjectContext) -> CoreRoute? {
        let fetchRequest:NSFetchRequest = CoreRoute.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = \(id)")
        
        let items = try? context.fetch(fetchRequest)
        
        return items?.first
    }
    
    func queryRoutes(_ stringDate:String? = nil,callback:@escaping (Bool,[Route])-> Void){
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            var routes:[Route] = []
            var items = self?.fetchRecordsForEntity(Entity.Route.rawValue,
                                              inManagedObjectContext: context) as? [CoreRoute]
            if let _date = stringDate {
                items = items?.filter({ (coreRoute) -> Bool in
                    let date = self?.dateFormatter1.date(from:E(coreRoute.date))
                    return self?.dateFormatter2.string(from: date!) == _date
                })
            }
            
            if let _items = items {
                print(_items)
                for item in _items {
                    let route = item.convertToRoute()
                    routes.append(route)
                }
            }
            routes.sort(by: { (route1, route2) -> Bool in
                return route1.id > route2.id
            })
            
            DispatchQueue.main.async {
                callback(true,routes)
            }
        }
    }
    
    func convertCoreOrdersToOrders(_ coreOrders:[CoreOrder]) -> [Order] {
        var orders:[Order] = []
        coreOrders.forEach { (coreOrder) in
            orders.append(coreOrder.converToOrder())
        }
        
        return orders
    }
    
    
    //MARK: - ORDER
    func updateOrderDetail(_ orderDetail:Order, _ callback:((Bool,CoreOrder?) -> Void)? = nil)  {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            
            let fetchRequest:NSFetchRequest = CoreOrder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = \(orderDetail.id)")
            
            let reaults = try? context.fetch(fetchRequest)
            reaults?.forEach { (coreOrder) in
                if coreOrder.id == orderDetail.id {
                    coreOrder.setAttribiteFrom(orderDetail, context: context)
                    
                    // Order File
                    orderDetail.files?.forEach { (orderFile) in
                        let predicate = NSPredicate(format: "id = \(orderFile.id)")
                        let coreAttachFile = (self?.fetchRecordsForEntity(Entity.AttachFile.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreAttachFile])?.last
                        if let _coreAttach = coreAttachFile {
                            _coreAttach.setAttributeFrom(orderFile)
                        } else {
                            let fileDB = NSEntityDescription.entity(forEntityName: Entity.AttachFile.rawValue, in: context)
                            let _coreFile:CoreAttachFile = CoreAttachFile(entity: fileDB!, insertInto: context)
                            _coreFile.id = Int32(orderFile.id )
                            _coreFile.setAttributeFrom(orderFile)
                            coreOrder.addToOrderFile(_coreFile)
                        }
                    }
                    
                    // Order Note
                    orderDetail.notes.forEach({ (note) in
                        let predicate = NSPredicate(format: "id = \(note.id)")
                        let coreNote = (self?.fetchRecordsForEntity(Entity.CoreNote.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreNote])?.last
                        if let _coreNote = coreNote {
                            _coreNote.setAttributeFrom(note)
                        } else {
                            let noteDB = NSEntityDescription.entity(forEntityName: Entity.CoreNote.rawValue, in: context)
                            let _coreNote:CoreNote = CoreNote(entity: noteDB!, insertInto: context)
                            _coreNote.id = Int16(note.id)
                            _coreNote.setAttributeFrom(note)
                            coreOrder.addToOrderNote(_coreNote)
                        }
                        note.files.forEach{ (file) in
                            let predicate = NSPredicate(format: "id = \(file.id)")
                            let coreAttachFile = (self?.fetchRecordsForEntity(Entity.AttachFile.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreAttachFile])?.last
                            if let _coreAttach = coreAttachFile {
                                _coreAttach.setAttributeFrom(file)
                            } else {
                                let fileDB = NSEntityDescription.entity(forEntityName: Entity.AttachFile.rawValue, in: context)
                                let _coreFile:CoreAttachFile = CoreAttachFile(entity: fileDB!, insertInto: context)
                                _coreFile.id = Int32(file.id )
                                _coreFile.setAttributeFrom(file)
                                coreNote?.addToNoteFile(_coreFile)
                            }
                        }
                    })
                    
                    // SKUs
                    orderDetail.details?.forEach{ (detail) in
                        let predicate = NSPredicate(format: "id = \(detail.pivot?.id ?? 0)")
                        let coreSKU = (self?.fetchRecordsForEntity(Entity.CoreSKU.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreSKU])?.last
                        if let _coreSKU = coreSKU {
                            _coreSKU.setAttributeFrom(detail)
                        } else {
                            let detailDB = NSEntityDescription.entity(forEntityName: Entity.CoreSKU.rawValue, in: context)
                            let _coreSKU:CoreSKU = CoreSKU(entity: detailDB!, insertInto: context)
                            _coreSKU.id = Int16(detail.pivot?.id ?? 0)
                            // Set List Attribute
                            _coreSKU.setAttributeFrom(detail)
                            coreOrder.addToDetail(_coreSKU)
                        }
                    }
                    
                    var recordReason: CoreReason? = nil
                    let lists = self?.fetchRecordsForEntity(Entity.Reason.rawValue, inManagedObjectContext: context)
                    if let listRecord = lists?.first {
                        recordReason = listRecord as? CoreReason
                    } else if let listRecord = self?.createRecordForEntity(Entity.Reason.rawValue,
                                                                           inManagedObjectContext: context) {
                        recordReason = listRecord as? CoreReason
                    }
                    
                    recordReason?.setAttributeFrom(orderDetail.reason)
                    coreOrder.reason = recordReason
                    
                    self?.saveContext(context)
                }
            }
            DispatchQueue.main.async {
                callback?(true,nil)
            }
        }
    }
    
    func queryOrderDetail(_ id: Int, callback:@escaping(Bool,Order?) -> Void) {
        self.persistentContainer.performBackgroundTask {(context) in
            let fetchRequest:NSFetchRequest = CoreOrder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = \(id)")
            
            var items: [CoreOrder] = []
            var order:Order?
            do {
                items = try context.fetch(fetchRequest)
                order = items.first?.converToOrder()
            } catch {
                print("Couldn't Fetch Data")
            }
            DispatchQueue.main.async {
                callback(true,order)
            }
        }
    }
    
    
    func queryCoreAttachfileBy(_ id: Int, context:NSManagedObjectContext) -> CoreAttachFile? {
        let listRecord = fetchRecordsForEntity(Entity.AttachFile.rawValue,
                                               inManagedObjectContext: context)
        let list  = listRecord.filter { (obj) -> Bool in
            if let _obj = obj as? CoreAttachFile{
                return (id == _obj.id )
            }
            return false
        }
        return list.first as? CoreAttachFile
    }
    
    func updateAttachfile(_ file: AttachFileModel)  {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "id = \(file.id)")
            let items = self?.fetchRecordsForEntity(Entity.AttachFile.rawValue,
                                              predicate:predicate,
                                              inManagedObjectContext: context) as? [CoreAttachFile]
            
            if let item = items?.first {
                item.setAttributeFrom(file)
                self?.saveContext()
            }else{
                //
            }
        }
    }
    
    func updateListReason(_ list:[Reason]) {
        clearDatabase(entity: .Reason)
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            list.forEach { (reason) in
                let coreReason = self?.createRecordForEntity(Entity.Reason.rawValue,
                                                       inManagedObjectContext: context) as? CoreReason
                coreReason?.setAttributeFrom(reason)
                self?.saveContext(context)
            }
        }
    }
    
    func updateRouteListStatus(_ list:[Status]) {
        clearDatabase(entity: .CoreRouteStatus)
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            list.forEach { (status) in
                let coreRouteStatus = self?.createRecordForEntity(Entity.CoreRouteStatus.rawValue,
                                                                  inManagedObjectContext: context) as? CoreRouteStatus
                coreRouteStatus?.setAttributeFrom(status)
                self?.saveContext(context)
            }
        }
    }
    
    func updateRentingOrderStatus(_ list:[RentingOrderStatus]) {
        clearDatabase(entity: .CoreRentingOrderStatus)
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            list.forEach { (status) in
                let coreRentingOrderStatus = self?.createRecordForEntity(Entity.CoreRentingOrderStatus.rawValue, inManagedObjectContext: context) as? CoreRentingOrderStatus
                coreRentingOrderStatus?.setAttributeFrom(status)
                self?.saveContext(context)
            }
        }
    }
    
    func updateRentingOrderDetailStatus(_ list:[RentingOrderDetailStatus]) {
        clearDatabase(entity: .CoreRentingOrderDetailStatus)
        self.persistentContainer.performBackgroundTask { [weak self] (context) in
            list.forEach({ (status) in
                let coreRentingOrderDetailStatus = self?.createRecordForEntity(Entity.CoreRentingOrderDetailStatus.rawValue, inManagedObjectContext: context) as? CoreRentingOrderDetailStatus
                coreRentingOrderDetailStatus?.setAttributeFrom(status)
                self?.saveContext(context)
            })
        }
    }
    
    func updatePurchaseOrderStatus(_ list:[PurchaseOrderStatus]) {
        clearDatabase(entity: .CorePurchaseOrderStatus)
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            list.forEach { (status) in
                let coreRentingOrderStatus = self?.createRecordForEntity(Entity.CorePurchaseOrderStatus.rawValue, inManagedObjectContext: context) as? CorePurchaseOrderStatus
                coreRentingOrderStatus?.setAttributeFrom(status)
                self?.saveContext(context)
            }
        }
    }
    
    func updateListStatus(_ list:[Status]) {
        clearDatabase(entity: .CoreStatus)
        self.persistentContainer.performBackgroundTask {[weak self]  (context) in
            list.forEach { (status) in
                let coreStatus = self?.createRecordForEntity(Entity.CoreStatus.rawValue,
                                                            inManagedObjectContext: context) as? CoreStatus
                coreStatus?.setAttributeFrom(status)
                self?.saveContext(context)
            }
        }
    }
    
    func getListCoreData(_ name: String) -> [NSManagedObject] {
        var results:[NSManagedObject] = []
        results = fetchRecordsForEntity(name, inManagedObjectContext: self.persistentContainer.viewContext)
        return results
    }
    
    func getListRoutes() -> [Route] {
        var results:[Route] = []
        let items = fetchRecordsForEntity(Entity.Route.rawValue, inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreRoute]
        items?.forEach({ (core) in
            results.append(core.convertToRoute())
        })
//        return results.sorted(by: {$0.id > $1.id})
        return results
    }
    
    func getRoute(_ routeID: String) -> Route {
        var result:Route!
        let predicate = NSPredicate(format: "id = \(routeID)")
        let context = getManagedObjectContext()
        let coreRoute = (self.fetchRecordsForEntity(Entity.Route.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreRoute])?.last
        guard let _coreRoute = coreRoute else {
            return result
        }
        result = _coreRoute.convertToRoute()
        return result
    }
    
    func getListRentingOrder() -> [RentingOrder] {
        var results:[RentingOrder] = []
        let items = fetchRecordsForEntity(Entity.CoreRentingOrder.rawValue, inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreRentingOrder]
        items?.forEach({ (core) in
            results.append(core.convertToRentingOrder())
        })
        
//        return results.sorted(by: {$0.id > $1.id})
        return results
    }
    
    func getRentingOrder(_ rentingId: Int) -> RentingOrder {
        var result:RentingOrder!
        let predicate = NSPredicate(format: "id = \(rentingId)")
        let context = getManagedObjectContext()
        let coreRenting = (self.fetchRecordsForEntity(Entity.CoreRentingOrder.rawValue, predicate: predicate, inManagedObjectContext: context) as? [CoreRentingOrder])?.last
        guard let _coreRenting = coreRenting else {
            return result
        }
        result = _coreRenting.convertToRentingOrder()
        return result
    }
    
    func getListSKU() -> [Order.Detail] {
        var results:[Order.Detail] = []
        let items = fetchRecordsForEntity(Entity.CoreSKU.rawValue, inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreSKU]
        items?.forEach({ (core) in
            results.append(core.convertToOrderDetailModel())
        })
        return results
    }
    
    func getListRouteStatus() -> [Status] {
        var results:[Status] = []
        let items = fetchRecordsForEntity(Entity.CoreRouteStatus.rawValue,
                                          inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreRouteStatus]
        items?.forEach({ (core) in
            results.append(core.convertToStatusModel())
        })
        
        return results
    }
    
    func getListStatus() -> [Status] {
        var results:[Status] = []
        let items = fetchRecordsForEntity(Entity.CoreStatus.rawValue,
                                          inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreStatus]
        items?.forEach({ (core) in
            results.append(core.convertToStatusModel())
        })
        
        return results
    }
    
    func getStatus(withCode statusCode:String) -> Status? {
        let listStatus = getListStatus()
        for item in listStatus {
            if item.code == statusCode{
                return item
            }
        }
        return nil
    }
    
    func getListRentingOrderStatus() -> [RentingOrderStatus] {
        var results:[RentingOrderStatus] = []
        let items = fetchRecordsForEntity(Entity.CoreRentingOrderStatus.rawValue, inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreRentingOrderStatus]
        items?.forEach({ (core) in
            results.append(core.convertToStatusModel())
        })
        
        return results
    }
    
    func getListRentingOrderDetailStatus() -> [RentingOrderDetailStatus] {
        var results:[RentingOrderDetailStatus] = []
        let items = fetchRecordsForEntity(Entity.CoreRentingOrderDetailStatus.rawValue, inManagedObjectContext: getManagedObjectContext()) as? [CoreRentingOrderDetailStatus]
        items?.forEach({ (core) in
            results.append(core.convertToStatusModel())
        })
        return results
    }
    
    func getListPurchaseOrderStatus() -> [PurchaseOrderStatus] {
        var results:[PurchaseOrderStatus] = []
        let items = fetchRecordsForEntity(Entity.CorePurchaseOrderStatus.rawValue, inManagedObjectContext: self.persistentContainer.viewContext) as? [CorePurchaseOrderStatus]
        items?.forEach({ (core) in
            results.append(core.convertToStatusModel())
        })
        
        return results
    }
    
    func getListReason() -> [Reason] {
        var results:[Reason] = []
        let items = fetchRecordsForEntity(Entity.Reason.rawValue,
                                          inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreReason]
        var _tempReason:[Reason] = []
        items?.forEach({ (coreReason) in
            _tempReason.append(coreReason.convertToReasonOrderCC())
        })
        results = _tempReason.filter({$0.catalog?.code == KEY_REASON_CANCEL})
        return results
    }
    
    func getListReasonPartialDeliverd() -> [Reason] {
        var results:[Reason] = []
        let items = fetchRecordsForEntity(Entity.Reason.rawValue,
                                          inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreReason]
        var _tempReason:[Reason] = []
        items?.forEach({ (coreReason) in
            _tempReason.append(coreReason.convertToReasonOrderCC())
        })
        results = _tempReason.filter({$0.catalog?.code == KEY_REASON_PARTIAL_DELIVERY})
        return results
    }
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
}


extension NSManagedObject{
    func setRelationShip(_ object:NSManagedObject,key:String) {
        self.setValue(object, forKey: key)
    }
}

// MARK: - Helper Methods
extension _CoreDataManager{
    private func createRecordForEntity(_ entity: String,
                                       inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity,
                                                           in: managedObjectContext)
        
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription,
                                     insertInto: managedObjectContext)
        }
        
        return result
    }
    
    private func fetchRecordsForEntity(_ entity: String,
                                       predicate:NSPredicate? = nil,
                                       inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let _predicate = predicate {
            fetchRequest.predicate = _predicate
        }
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    func deleteRequestModel(_ request:RequestModel,_ onCompletion:@escaping (_ status:Bool) -> Void ) {
        self.persistentContainer.performBackgroundTask { (context) in
            let predicate = NSPredicate(format: "timetamps = \(request.timetamps ?? 0)")

            if let coreRequest = self.fetchRecordsForEntity(Entity.Request.rawValue,
                                                            predicate: predicate,
                                                            inManagedObjectContext:  context).first {
                
                self.delete(object: coreRequest, context: context, onCompletion: onCompletion)
            }
        }
    }
    
    func delete(object: NSManagedObject,
                context:NSManagedObjectContext? = nil,
                onCompletion: @escaping (_ status:Bool) -> Void) {
        var managedContext = CoreDataManager.persistentContainer.viewContext
        if let _context = context {
            managedContext = _context
        }
        managedContext.delete(object)
        
        do {
            try managedContext.save()
            onCompletion(true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}



