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
        print("Find DB At: ", FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).last ?? "Not Found!")
    
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
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
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
    }
    
    func clearDatabase( entity:Entity ) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue )
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch let error as NSError {
                debugPrint(error)
            }
            self?.saveContext(context)
        }
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
    
    //MARK: - ROUTE
    func saveRoutes(_ routes:[Route], callback:((Bool,[Route]) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            routes.forEach { (route) in
                let coreRoute = self?.queryCoreRouteById(route.id,context)
                if coreRoute != nil{
                    //context.delete(coreRoute!)
                    //self.updateRouteOnCoreCooradinator(coreRoute!, route, context)
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
    
    
    //MARK : - ROUTE
    func updateRoute(_ route:Route,_ callback:((Bool,Route) -> Void)? = nil) {
        self.persistentContainer.performBackgroundTask {[weak self] (context) in
            let predicate = NSPredicate(format: "id = \(route.id)")
            let reaults = self?.fetchRecordsForEntity(Entity.Route.rawValue,
                                                predicate:predicate,
                                                inManagedObjectContext: context) as? [CoreRoute]
            reaults?.forEach { (coreRoute) in
                if coreRoute.id == route.id {
                    coreRoute.setAttribiteFrom(route)
                    route.orderList.forEach({ (order) in
                        order.driver_id = route.driverId
                        order.driver_name = route.driver_name
                        
                        let predicate = NSPredicate(format: "id = \(order.id)")
                        let coreOrder = (self?.fetchRecordsForEntity(Entity.Order.rawValue,
                                                               predicate: predicate ,
                                                               inManagedObjectContext: context) as? [CoreOrder])?.last
                        
                        if let _coreOrder = coreOrder{
                            _coreOrder.setAttribiteFrom(order)
                            
                        }else {
                            let orderDB = NSEntityDescription.entity(forEntityName:Entity.Order.rawValue,
                                                                     in: context)
                            let coreOdr:CoreOrder = CoreOrder(entity: orderDB!,
                                                              insertInto: context)
                            // Set List Attribute
                            coreOdr.setAttribiteFrom(order)
                            coreOdr.driver_id = Int16(route.driverId)
                            coreRoute.addToOrderList(coreOdr)
                        }
                        self?.saveContext(context)
                    })
                }
            }
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
        
        let coreRoute:CoreRoute = CoreRoute(entity: routeDB!,
                                            insertInto: context)
       
        route.orderList.forEach({ (order) in
            let coreOrder:CoreOrder = CoreOrder(entity: orderDB!,
                                                insertInto: context)
            
            // Set List Attribute
            coreOrder.setAttribiteFrom(order)
            coreOrder.driver_id = Int16(route.driverId)
            if order.files != nil{
                let coreUrl:CoreUrlFile = CoreUrlFile(entity: urlDB!, insertInto: context)
                if let sig = order.signature{
                    let coreSig = createRecordForEntity(Entity.AttachFile.rawValue,
                                                        inManagedObjectContext: context) as? CoreAttachFile
                    coreSig?.setAttributeFrom(sig)
                    coreUrl.sig = coreSig
                }
                
                if let docs = order.pictures {
                    docs.forEach({ (doc) in
                        let coreDoc = createRecordForEntity(Entity.AttachFile.rawValue, inManagedObjectContext: context) as? CoreAttachFile
                        coreDoc?.setAttributeFrom(doc)
                        coreUrl.addToDoc(coreDoc!)
                    })
                }
                coreOrder.url = coreUrl
            }
            
            // Set List Relationship
            coreRoute.addToOrderList(coreOrder)
        })
        
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
                    coreOrder.setAttribiteFrom(orderDetail)
                    if let _ = orderDetail.files{
                        
                        coreOrder.url?.sig = nil
                        coreOrder.url?.doc = nil
                        
                        let coreUrl = self?.createRecordForEntity(Entity.UrlFile.rawValue,
                                                            inManagedObjectContext: context) as? CoreUrlFile
                        if let sig = orderDetail.signature {
                            self?.deleteAttachFileById(sig.id, context: context)
                            let coreSig = self?.createRecordForEntity(Entity.AttachFile.rawValue,inManagedObjectContext: context) as? CoreAttachFile
                            coreSig?.setAttributeFrom(sig)
                            coreUrl?.sig = coreSig
                        }
                        
                        if let docs = orderDetail.pictures {
                            docs.forEach({ (doc) in
                                var coreDoc :CoreAttachFile? = self?.queryCoreAttachfileBy(doc.id, context: context)
                                if coreDoc == nil || doc.id == 0{
                                    coreDoc  = (self?.createRecordForEntity(Entity.AttachFile.rawValue,
                                                                      inManagedObjectContext: context) as! CoreAttachFile)
                                }
                                coreDoc?.setAttributeFrom(doc)
                                coreUrl?.addToDoc(coreDoc!)
                            })
                        }
                        coreOrder.url = coreUrl
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
                let coreRouteStatus = self?.createRecordForEntity(Entity.CoreStatus.rawValue,
                                                                  inManagedObjectContext: context) as? CoreRouteStatus
                coreRouteStatus?.setAttributeFrom(status)
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
    
    func getListReason() -> [Reason] {
        var results:[Reason] = []
        let items = fetchRecordsForEntity(Entity.Reason.rawValue,
                                          inManagedObjectContext: self.persistentContainer.viewContext) as? [CoreReason]
        items?.forEach({ (coreReason) in
            results.append(coreReason.convertToReasonOrderCC())
        })
        
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



