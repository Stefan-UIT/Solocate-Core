
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
        self.init(format: format, timeZone: TimeZone.current);
    }
}

let Hour24Formater = DateFormatter.hour24Formater
let HourFormater = DateFormatter.hourFormater
let ServerDateFormater = DateFormatter.serverDateFormater
let ShortDateFormater = DateFormatter.shortDate
let NormalDateFormater = DateFormatter.normalDateFormater
let ShortNormalDateFormater = DateFormatter.shortNormalDateFormater
let NormalTimeFormater = DateFormatter.normalTimeFormater
let OnlyDateFormater = DateFormatter.onlyDateFormater
let DateTimeUSWithSecond = DateFormatter.displayDateTimeUSWithSecond

//MARK: - DateFormatter Instance
extension DateFormatter {
    static let filterDate = DateFormatter(format: "yyyy/MM/dd");
    static let displayDateForLogControl = DateFormatter(format: "MMM d yyyy, h:mm a");
    static let displayDateForOrder = DateFormatter(format: "EEE', 'MMM' 'dd', 'yyyy");
    static let displayDateVietNames = DateFormatter(format: "dd/MM/yyyy");
    static let displayDateUS = DateFormatter(format: "MM/dd/yyyy");
    static let displayDateTimeUS = DateFormatter(format: "MM/dd/yyyy HH:mm");
    static let hourFormater = DateFormatter(format: "h:mm a");
    static let hour24Formater = DateFormatter(format: "HH:mm");
    static let displayDateTimeVN = DateFormatter(format: "dd/MM/yyyy HH:mm");
    static let shortDate = DateFormatter(format: "MMM dd");
    static let serverDateFormater = DateFormatter(format: "yyyy/MM/dd HH:mm:ss");
    static let normalDateFormater = DateFormatter(format: "yyyy/MM/dd HH:mm:ss");
    static let shortNormalDateFormater = DateFormatter(format: "yyyy/MM/dd HH:mm");
    static let normalTimeFormater = DateFormatter(format: "HH:mm:ss");
    static let onlyDateFormater = DateFormatter(format: "MMM/dd/yyyy");
    static let displayDateTimeUSWithSecond = DateFormatter(format: "MM/dd/yyyy HH:mm:ss");
    
    static let mobileDateDisplayFormatter = DateFormatter(format: "dd-MM-yyyy HH:mm");
    
    func convertDateFromServer(_ date: String) -> String
    {
        self.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = self.date(from: date)
        self.dateFormat = "dd-MM-yyyy HH:mm"
        return  self.string(from: date!)

    }
    
}
