

import Foundation

//MARK: - Locale
extension Locale {
    static let en_US_POSIX: Locale = Locale(identifier: "en_US_POSIX")
}

//MARK: - TimeZone
extension TimeZone {
    static let centralTexas: TimeZone = TimeZone(identifier: "UTC-06:00")!
    static fileprivate(set) var app: TimeZone = .centralTexas;
}

//MARK: - Calendar
extension Calendar {
    static let app: Calendar = Calendar(identifier: .gregorian, timeZone: .app)
    
    init(identifier: Calendar.Identifier, timeZone: TimeZone) {
        self.init(identifier: identifier);
        self.timeZone = timeZone;
    }
}


//MARK: - Date
extension Date {
    
    static var now: Date {
        return Date();
    }
    
    static func join(date: Date, time: Date) -> Date?{
        var dateComponents = Calendar.app.dateComponents([.year, .month, .day], from: date);
        let timeComponents = Calendar.app.dateComponents([.hour, .minute, .second], from: time);
        dateComponents.hour = timeComponents.hour;
        dateComponents.minute = timeComponents.minute;
        dateComponents.second = timeComponents.second;
        return Calendar.app.date(from: dateComponents);
    }
    
    enum TimeInDay {
        case start;
        case end;
    }
    
    func day(for timeInDay: TimeInDay) -> Date {
        switch timeInDay {
        case .start:
            return startDay();
            
        case .end:
            return endDay();
        }
    }
    
    func startDay() -> Date {
        var dateComponents = Calendar.app.dateComponents([.year, .month, .day], from: self);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        return Calendar.app.date(from: dateComponents)!;
    }
    
    func endDay() -> Date {
        var dateComponents = Calendar.app.dateComponents([.year, .month, .day], from: self);
        dateComponents.day = dateComponents.day! + 1;
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = -1;
        return Calendar.app.date(from: dateComponents)!;
    }
    
    func offsetFrom(date : Date) -> DateComponents {
        return offsetFrom(date: date, components: [.day,.hour, .minute, .second])
    }
    
    func offsetFrom(date : Date, components:Set<Calendar.Component> = [.year,.day,.hour, .minute, .second]) -> DateComponents {
        let dayHourMinuteSecond: Set<Calendar.Component> = components
        let difference = Calendar.app.dateComponents(dayHourMinuteSecond, from: date, to: self);
        return difference
    }
}

//MARK: - Date for server
extension Date {
    
    private static let serverDateFormatter = DateFormatter(format: "MM/dd/yyyy")
    private static let serverTimeFormatter = DateFormatter(format: "hh:mm a")
    
    static func server(date dateString: String?, time timeString: String?) -> Date? {
        var date: Date? = nil;
        if let dateString = dateString {
            date = serverDateFormatter.date(from: dateString)
        }
        
        var time: Date? = nil;
        if let timeString = timeString {
            time = serverTimeFormatter.date(from: timeString)
        }
        
        if date != nil || time != nil {
            return join(date: date ?? Date(), time: time ?? Date());
        }
        
        return nil;
    }
    
    static func server(date dateString: String?, defaultTime: Date) -> Date? {
        guard let dateString = dateString,
            let date = serverDateFormatter.date(from: dateString) else {
            return nil;
        }
        
        return join(date: date, time: defaultTime);
    }
    
    static func server(time timeString: String?, defaultDate: Date) -> Date? {
        guard let timeString = timeString,
            let time = serverTimeFormatter.date(from: timeString) else {
                return nil;
        }
        
        return join(date: defaultDate, time: time);
    }
    
    static func server(date dateString: String?, for timeInDay: TimeInDay) -> Date? {
        guard let dateString = dateString,
            let date = serverDateFormatter.date(from: dateString) else {
                return nil;
        }
        
        return date.day(for: timeInDay);
    }
    
    func toServerDateTime() -> (date: String, time: String) {
        return (date: Date.serverDateFormatter.string(from: self),
                time: Date.serverTimeFormatter.string(from: self));
    }

}

