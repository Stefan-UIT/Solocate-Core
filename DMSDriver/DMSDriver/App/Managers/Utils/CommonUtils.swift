
import Foundation;
import UIKit;

class CommonUtils {
   
    static func OSVersion() -> Float {
        return Float(UIDevice.current.systemVersion)!;
    }
    
    static func formatEstTime(seconds totalSeconds: Int64) -> String{
        let minutes = (totalSeconds / 60) % 60;
        let hours = totalSeconds / 3600;
        
        var formatedHours = ""
        if hours > 0 {
            formatedHours = "\(hours) " + "h".localized + " "
        }
        
        if minutes > 0 {
            let string = (minutes > 1) ? ("\(minutes) " + "mins".localized.uppercased()) : ("\(minutes)" + "min".localized.uppercased())
            formatedHours += string
        }
        return formatedHours
    }
    
    
    static func formatTime(seconds totalSeconds: Int64) -> String{
        
        let seconds = totalSeconds % 60;
        let minutes = (totalSeconds / 60) % 60;
        let hours = totalSeconds / 3600;
        
        let formatedHours = hours == 0 ? "" : ("\(hours):");
        
        return "\(formatedHours)\(minutes):\(seconds)";
        
    }
    
    static func formatEstKm(met totalMet: Double) -> String{
        let m = Int(totalMet / 1000) % 1000
        let km:Double = totalMet / 1000.0
        
        if totalMet > 1 {
            return "\(km.rounded(toPlaces: 1)) " + "km".localized
        }
        return  "\(m) " + "m".localized
    }
    
    static func getTwoFirstLetter(string:String) -> String {
       var str = ""
       let arr = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        if arr.count == 1 {
            str = arr[0];
            str = str.substring(from: MIN(2, str.length)).uppercased()
            return str
        }
        
        for item in arr {
            if !isEmpty(item){
                str = str.appending(item.substring(from: 1))
            }
        }
        
        if str.length >= 2 {
            return str.uppercased()
        }
        
        return str
    }
}
