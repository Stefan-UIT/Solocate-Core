
import Foundation

//MARK: - DateFormatter
extension DateFormatter {
    
    convenience init(format: String, timeZone: TimeZone) {
        self.init();
        
        self.locale = .en_US_POSIX;
        self.dateFormat = format;
        self.timeZone = timeZone;
    }
    
    convenience init(format: String) {
        self.init(format: format, timeZone: .current);
    }
}

let HourFormater = DateFormatter.hourFormater
let ServerDateFormater = DateFormatter.serverDateFormater
let ShortDateFormater = DateFormatter.shortDate


//MARK: - DateFormatter Instance
extension DateFormatter {
    static let shortDate = DateFormatter(format: "MMM dd");
    static let displayDateForLogControl = DateFormatter(format: "MMM d yyyy, h:mm a");
    static let displayDateForOrder = DateFormatter(format: "EEE', 'MMM' 'dd', 'yyyy");
    static let displayDateVietNames = DateFormatter(format: "dd/MM/yyyy",timeZone: TimeZone(identifier: "UTC")!);
    static let displayDateUS = DateFormatter(format: "MM/dd/yyyy",timeZone: TimeZone(identifier: "UTC")!);
    static let serverDateFormater = DateFormatter(format: "yyyy/MM/dd HH:mm:ss", timeZone: TimeZone(identifier: "UTC")!);
    static let hourFormater = DateFormatter(format: "HH:mm",timeZone: TimeZone(identifier: "UTC")!);
    static let displayDateTimeVN = DateFormatter(format: "dd/MM/yyyy HH:mm",timeZone: TimeZone(identifier: "UTC")!);
    
}
