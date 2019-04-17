//
//  TimeDataItem.swift
//  DMSDriver
//
//  Created by machnguyen_uit on 3/4/19.
//  Copyright © 2019 machnguyen_uit. All rights reserved.
//

import UIKit
import ObjectMapper

enum TimeItemType:Int {
    case TimeItemTypeAll = 0
    case TimeItemTypeToday
    case TimeItemTypeYesterday
    case TimeItemTypeTomorrow
    case TimeItemTypeThisWeek
    case TimeItemTypeLastWeek
    case TimeItemTypeNextWeek
    case TimeItemTypeThisMonth
    case TimeItemTypeLastMonth
    case TimeItemTypeNextMonth
    case TimeItemTypeThisYear
    case TimeItemTypeLastYear
    case TimeItemTypeNextYear
    case TimeItemTypeCustom
}

class TimeDataItem: BaseModel {//You should get it from [TimeData getTimeDataItemType:]
    
    var title:String?
    var subtitle:String?
    var startDate:Date?
    var endDate:Date?
    var reviewDate:Date?
    var type:TimeItemType?
    
    init(title:String,subtitle:String,type:TimeItemType, start:Date?,end:Date?) {
        super.init()
        self.title = title;
        self.subtitle = subtitle;
        self.type = type;
        self.startDate = start;
        self.endDate = end;
    }
    
    required init?(map: Map) {
        super.init()
    }
    
    override func mapping(map: Map) {
        title <- map["title"]
        subtitle <- map["subtitle"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        reviewDate <- map["reviewDate"]
        type <- map["type"]
    }
}

class TimeData: NSObject {//You should get it from [TimeData getTimeDataItemType:]
    
    var timeDataItemDefault:TimeDataItem?
    var timeDataItemDefaultCustom:TimeDataItem?
    
    static var shared = TimeData()

    
    class func setTimeDataItemDefault(item:TimeDataItem)  {
        TimeData.shared.timeDataItemDefault = item
    }
    
    class func setTimeDataItemCustom(item:TimeDataItem)  {
        TimeData.shared.timeDataItemDefaultCustom = item
    }

    class func getTimeDataItemDefault() -> TimeDataItem? {
        let timeData = TimeData.shared.timeDataItemDefault
        return timeData
    }
    
    class func timeFormatDefault() -> [String] {
        return ["MM/dd/yyyy",
                "dd/MM/yyyy",
                "yyyy/MM/dd",
                "MMM-dd-yyyy",
                "dd-MMM-yyyy",
                "yyyy-MMM-dd"]
    }
    
    class func monthYearFormat() -> String {
        let companyTimeFormat = "MM/dd/yyyy"
        if companyTimeFormat == "MM/dd/yyyy" ||
            companyTimeFormat == "dd/MM/yyyy"{
            return "MM/yyyy"
        }else if (companyTimeFormat == "yyyy/MM/dd") {
            return "yyyy/MM"
        }else if (companyTimeFormat == "MMM-dd-yyyy" ||
            (companyTimeFormat == "dd-MMM-yyyy")) {
            return "MMM-yyyy"
        }else if (companyTimeFormat == "yyyy-MMM-dd") {
            return "yyyy-MMM"
        }
        
        return ""
    }
    
    class func arrItemTitle() -> [String] {
        return ["All Time",
                "Today",
                "Yesterday",
                "Tomorrow",
                "This Week",
                "Last Week",
                "Next Week",
                "This Month",
                "Last Month",
                "Next Month",
                "This Year",
                "Last Year",
                "Next Year",
                "Custom"];
    }
    
   class func getTimeDataItemCustom() -> TimeDataItem? {
      
        if ((TimeData.shared.timeDataItemDefaultCustom == nil)) {
            
            let start:Date = Date().startDay()
            let end = Date().endDay()
            
            let subTitle = "\(DateFormatter.displayDateUS.string(from: start)) - \(DateFormatter.displayDateUS.string(from: end))"
            
            let item = TimeDataItem(title: "Custom",
                                    subtitle: subTitle,
                                    type: .TimeItemTypeCustom,
                                    start: start,
                                    end: end)
            
            TimeData.shared.timeDataItemDefaultCustom = item;
        }
        
        return TimeData.shared.timeDataItemDefaultCustom;
    }
    
    class func arrTimeDataItem() -> [TimeDataItem] {
        var arrItems:[TimeDataItem] = []
        
        let arrStr:[String] = TimeData.arrItemTitle();
        let count = arrStr.count
        for i in 0..<count {
            
            let title = arrStr[i];
            var subTitle = ""
            let start:Date?
            var end:Date?
            guard let type = TimeItemType(rawValue: i) else {return arrItems}

            switch type {
            case .TimeItemTypeAll:
                start = Date.init(timeIntervalSince1970: 0)
                end = Date().addingTimeInterval(31536000)
                subTitle = "All Time"
                
            case .TimeItemTypeYesterday:
                let arr = Date().getYesterdayStartEndDates(timeZone: TimeZone.current)
    
                start = arr.0;
                end = arr.1;
                subTitle = DateFormatter.displayDateUS.string(from: end ?? Date())
                
            case .TimeItemTypeToday:
                let arr = Date().getTodayStartEndDates()
                start = arr.0;
                end = arr.1;
                subTitle = DateFormatter.displayDateUS.string(from: end ?? Date())
       
            case .TimeItemTypeTomorrow:
                let arr = Date().getTomorrowStartEndDates(timeZone: TimeZone.current)
                start = arr.0;
                end = arr.1;
                subTitle = DateFormatter.displayDateUS.string(from: end ?? Date())
                
            case .TimeItemTypeLastWeek:
                let arr = Date().getLastWeekStartEndDates(timeZone: .current)
          
                start = arr.0
                end = arr.1
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
             
            case .TimeItemTypeThisWeek:
                let arr = Date().getThisWeekStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
      
                
            case .TimeItemTypeNextWeek:
                let arr = Date().getNextWeekStartEndDates(timeZone: TimeZone.current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
       
                
            case .TimeItemTypeLastMonth:
                let arr = Date().getLastMonthStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
                
            case .TimeItemTypeThisMonth:
                let arr = Date().getThisMonthStartEndDates(timeZone:  .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
                
            case .TimeItemTypeNextMonth:
                let arr = Date().getNextMonthStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
                
                
            case .TimeItemTypeLastYear:
                let arr = Date().getLastYearStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
                
                
            case .TimeItemTypeThisYear:
                let arr = Date().getThisYearStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
  
            case .TimeItemTypeNextYear:
                let arr = Date().getNextYearStartEndDates(timeZone: .current)
                start = arr.0;
                end = arr.1;
                subTitle = "\(DateFormatter.displayDateUS.string(from: start ?? Date())) - \(DateFormatter.displayDateUS.string(from: end ?? Date()))"
                
            case .TimeItemTypeCustom:
                start = TimeData.getTimeDataItemCustom()?.startDate
                end = TimeData.getTimeDataItemCustom()?.endDate
                
                let startDisplay = (start != nil) ? DateFormatter.displayDateUS.string(from: start!) : "?"
                let endDisplay = (end != nil) ? DateFormatter.displayDateUS.string(from: end!) : "?"

                subTitle = "\(startDisplay) - \(endDisplay)"
            }
            
            let item = TimeDataItem(title: title,
                                    subtitle: subTitle,
                                    type: type, start: start, end: end)
            
            
           
            arrItems.append(item)
        }
        
        return arrItems;
    }
    
    class func getTimeDataItemType(type:TimeItemType) -> TimeDataItem {
        return TimeData.arrTimeDataItem()[type.rawValue]
    }
    
    
    func getArrayTimeDataItemFromArrayTypes(types:[NSNumber]) -> [TimeDataItem] {
        var results:[TimeDataItem] = []
        let arr: [TimeDataItem] = TimeData.arrTimeDataItem()
        
        types.forEach { (type) in
            results.append(arr[type.intValue])
        }
   
        return results;
    }
}

