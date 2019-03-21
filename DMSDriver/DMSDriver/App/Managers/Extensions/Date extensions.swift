

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
    
    static func getDate(fromDate:Date,daysAhead: Int, timeZone:TimeZone? = nil) -> Date {
        var dateCom = DateComponents()
        dateCom.day = daysAhead
        
        var  cal = Calendar.current
        if timeZone != nil {
            cal.timeZone = timeZone!
        }
        
        let tDate = cal.date(byAdding: dateCom, to: fromDate)
        return tDate ?? Date()
    }
    
    func getDateWithDaysAhead(days:Int,timeZone:TimeZone ) -> Date {
        return Date.getDate(fromDate: self, daysAhead: days, timeZone: timeZone)
    }
    
    func yesterdayCurrentTimeZone() -> Date {
        return Date().getDateWithDaysAhead(days: -1, timeZone: TimeZone.current)
    }
    
    func yesterdayCompanyTimeZone() -> Date {
        return Date().getDateWithDaysAhead(days: -1, timeZone: TimeZone.app)
    }
    
    func yesterdayTimeZone(timeZone:TimeZone) -> Date {
        return Date().getDateWithDaysAhead(days: -1, timeZone: timeZone)
    }
    
    func getYesterdayStartEndDates(timeZone:TimeZone = TimeZone.current) -> (Date,Date) {
        let yesterdate = yesterdayTimeZone(timeZone: timeZone)
        let firstDate = yesterdate.startDay()
        let endDate = yesterdate.endDay()
        
        return (firstDate,endDate)
    }
    
    func getTodayStartEndDates(timeZone:TimeZone = .current) ->  (Date,Date) {
        let startDate = self.startDay(timeZone: timeZone)
        let endDate = self.endDay(timeZone: timeZone)
        return (startDate,endDate)
    }
    
    func tomorrowTimeZone(timeZone:TimeZone? = .current) -> Date {
        return Date().getDateWithDaysAhead(days: +1, timeZone: timeZone!)
    }

    func getTomorrowStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let tomorrow = tomorrowTimeZone(timeZone: timeZone)
        return (tomorrow.startDay(timeZone: timeZone), tomorrow.endDay(timeZone: timeZone))
    }
    
    func getLastWeekStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let dateLastWeek = self.getDateWithDaysAhead(days: -7, timeZone: timeZone)
        let firstDate = dateLastWeek.startDayOfThisWeek(timeZone: timeZone)
        let enđDate = dateLastWeek.endDayOfThisWeek(timeZone: timeZone)
        return (firstDate,enđDate)
    }
    
    func getThisWeekStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let firstDate = self.startDayOfThisWeek(timeZone: timeZone)
        let enđDate = self.endDayOfThisWeek(timeZone: timeZone)
        return (firstDate,enđDate)
    }
    
    func getNextWeekStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let dateNextWeek = getDateWithDaysAhead(days: +7, timeZone: timeZone)
        let firstDate = dateNextWeek.startDayOfThisWeek(timeZone: timeZone)
        let endDate = dateNextWeek.endDayOfThisWeek(timeZone: timeZone)
        
        return (firstDate,endDate)
    }
    
    func getThisMonthStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let firstDate = self.firstDayOfMonth(timeZone: timeZone)
        let endDate = self.lastDayOfMonth(timeZone: timeZone)
        
        return (firstDate,endDate)
    }
    
    func getLastMonthStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let date = self.getLastMonthSameDate(timeZone: timeZone)
        return date.getThisMonthStartEndDates(timeZone:timeZone)
    }
    
    func getNextMonthStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let date = self.getNextMonthSameDate(timeZone: timeZone)
        return date.getThisMonthStartEndDates(timeZone:timeZone)
    }

    
    func startDay(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .gregorian, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        return cal.date(from: dateComponents)!;
    }
    
    func endDay(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .gregorian, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self);
        dateComponents.day = dateComponents.day! + 1;
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = -1;
        return cal.date(from: dateComponents)!;
    }
    
    func startDayOfThisWeek(timeZone:TimeZone = .current) ->Date{
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day,.hour,.minute,.second], from: self)
        let day = dateComponents.day
        let offset = dateComponents.weekday
        
        dateComponents.day = (day ?? 0) - (offset ?? 0)
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        
        return cal.date(from: dateComponents)!;
    }
    
    func endDayOfThisWeek(timeZone:TimeZone = .current) ->Date{
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day,.hour,.minute,.second], from: self)
        let day = dateComponents.day
        let offset = dateComponents.weekday
        
        dateComponents.day = (day ?? 0) - (offset ?? 0) + 6 //start day + 6
        dateComponents.hour = 23;
        dateComponents.minute = 59;
        dateComponents.second = 59;
        
        return cal.date(from: dateComponents)!;
    }
    
    func firstDayOfMonth(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day,.hour,.minute,.second], from: self)
        
        dateComponents.day = 1
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        
        return cal.date(from: dateComponents)!;
    }
    
    
    func lastDayOfMonth(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day,.hour,.minute,.second], from: self)
    
        var day = 31;
        let month = dateComponents.month
        if month == 2{
            let year = dateComponents.year ?? 0
            if year % 400 == 0 || (year % 4 == 0 && year % 100 == 0) {
                day = 29
            }else {
                day = 28
            }
        } else if((month == 4) || (month == 6) || (month == 9) || (month == 11)) {
            day = 30;
        }

        dateComponents.day = day
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        return cal.date(from: dateComponents)!;
    }
    
    func getLastMonthSameDate(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        var year = dateComponents.year ?? 0
        var month = dateComponents.month ?? 0
        var day = dateComponents.day ?? 0
        if(month == 1) {
            year -= 1
            month = 12;
            
        } else {
            month -= 1
        }
        
        self.adjustDay(day: &day, month: &month, year: &year)
        
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.day = day

        return cal.date(from: dateComponents)!;
    }
    
    func getNextMonthSameDate(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        var year = dateComponents.year ?? 0
        var month = dateComponents.month ?? 0
        var day = dateComponents.day ?? 0
        if(month == 12) {
            year += 1
            month = 1;
            
        } else {
            month += 1
        }
        
        self.adjustDay(day: &day, month: &month, year: &year)
        
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.day = day
        
        return cal.date(from: dateComponents)!;
    }
    
    func getLastYearSameDate() -> Date {
        let cal =  Calendar(identifier: .iso8601)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        let year = dateComponents.year ?? 0
        dateComponents.year = year - 1
        return cal.date(from: dateComponents)!;
    }
    
    func getNextYearSameDate() -> Date {
        let cal =  Calendar(identifier: .iso8601)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        let year = dateComponents.year ?? 0
        dateComponents.year = year + 1
        return cal.date(from: dateComponents)!;
    }
    
    func firstDayOfYear(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year = dateComponents.year
        
        return cal.date(from: dateComponents)!;
    }
    
    
    func lastDayOfYear(timeZone:TimeZone = .current) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        dateComponents.day = 31
        dateComponents.month = 12
        dateComponents.year = dateComponents.year
        
        return cal.date(from: dateComponents)!.endDay(timeZone:timeZone);
    }
    
    func firstDayOfYear(timeZone:TimeZone = .current, year:Int) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year = year
        
        return cal.date(from: dateComponents)!;
    }
    
    
    func lastDayOfYear(timeZone:TimeZone = .current,year:Int) -> Date {
        let cal =  Calendar(identifier: .iso8601, timeZone: timeZone)
        var dateComponents = cal.dateComponents([.year, .month, .day], from: self)
        
        dateComponents.day = 31
        dateComponents.month = 12
        dateComponents.year = year
        
        return cal.date(from: dateComponents)!;
    }
    
    func getThisYearStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let firstDate = firstDayOfYear(timeZone: timeZone)
        let enđate = lastDayOfYear(timeZone: timeZone)
        
        return (firstDate,enđate)
    }
    
    func getLastYearStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let date = Date().getLastYearSameDate()
        return date.getThisYearStartEndDates(timeZone:timeZone)
    }
    
    
    func getNextYearStartEndDates(timeZone:TimeZone = .current) -> (Date,Date) {
        let date = Date().getNextYearSameDate()
        return date.getThisYearStartEndDates(timeZone:timeZone)
    }

    
    func checkLeapYear(year:Int) -> Bool {
        if(((year%4 == 0) && (year%100 != 0)) || (year%400 == 0)){
            return true;
        }
        else{
            return false;
        }
    }
    
    func adjustDay(day: inout Int, month: inout Int,year: inout Int)  {
        let  md:[Int] = [ 0, // Zero
            31, // Jan
            28, // Feb
            31, // Mar
            30, // Apr
            31, // May
            30, // June
            31, // july
            31, // Aug
            30, // Sep
            31, // Oct
            30, // Nov
            31, // Dec
            0 // Zero
        ];
        
        var noDay = md[month]
        if(month == 2) {
            if(checkLeapYear(year: year)) {
                noDay = 29;
            }
        }
        
        if(day > noDay) {
            day = noDay;
        }
    }
    
    
    func toString(_ format: String? = nil) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        if let _format = format {
            dateFormat.dateFormat = _format
        }
        return dateFormat.string(from: self)
    }
    
    func toString(_ date: String, _ formatInput: String, _ formatOutput: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatInput
        return dateFormatter.date(from: date)?.toString(formatOutput) ?? ""
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
        
        return date.day(for: timeInDay)
    }
    
    func toServerDateTime() -> (date: String, time: String) {
        return (date: Date.serverDateFormatter.string(from: self),
                time: Date.serverTimeFormatter.string(from: self));
    }

}

