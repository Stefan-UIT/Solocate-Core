

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
    
    func toString(_ format: String? = nil) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        if let _format = format {
            dateFormat.dateFormat = _format
        }
        return dateFormat.string(from: self)
    }
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.app.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.app.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.app.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.app.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.app.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.app.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.app.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    func offsetLong(from date: Date) -> String {
        
        if years(from: date)   > 0 {
            return years(from: date) > 1 ? String(format: "%d years ago".localized, years(from: date)) : String(format: "%d year ago", years(from: date))}
        if months(from: date)  > 0 {
            return months(from: date) > 1 ? String(format: "%d months ago".localized, months(from: date))  : String(format: "%d month ago", months(from: date)) }
        if weeks(from: date)   > 0 {
            return weeks(from: date) > 1 ? String(format: "%d weeks ago".localized, weeks(from: date)) : String(format: "%d week ago".localized, weeks(from: date))}
        if days(from: date)    > 0 {
            return days(from: date) > 1 ? String(format: "%d days ago".localized, days(from: date)) : String(format: "%d day ago", days(from: date))  }
        if hours(from: date)   > 0 {
            return hours(from: date) > 1 ? String(format: "%d hours ago".localized, hours(from: date)) : "an hour ago".localized}
        if minutes(from: date) > 0 {
            return minutes(from: date) > 1 ? String(format: "%d minutes ago".localized, minutes(from: date)) : "an minute ago".localized}
        if seconds(from: date) > 0 {
            return "just now".localized
        }
        return ""
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

