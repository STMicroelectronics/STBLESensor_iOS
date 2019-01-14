import Foundation
import BlueSTSDK

public class NucleoConsole{
    private static let MAX_NAME_LENGTH = 7;
    private static let SET_NAME_COMMAND_FORMAT = "setName %@\n";
    
    private static let SET_TIME_FORMAT: DateFormatter = {
        let timeFormat = DateFormatter();
        timeFormat.dateFormat = "HH:mm:ss";
        return timeFormat;
    }();
    private static let SET_TIME_COMMAND_FORMAT = "setTime %@\n";
    
    private static let SET_DATE_FORMAT: DateFormatter = {
        let timeFormat = DateFormatter()
        //set tle locate to uk to be secure to have the the first day of the moth = monday
        timeFormat.locale = Locale(identifier:"en_UK") // to be secure to have the the first day of the moth = monday
        timeFormat.dateFormat = "ee/dd/MM/yy";
        return timeFormat;
    }();
    private static let SET_DATE_COMMAND_FORMAT = "setDate %@\n";

    
    private let mConsole:BlueSTSDKDebug;
    
    public init(_ console:BlueSTSDKDebug){
        mConsole = console;
    }
    
    public func setName(newName:String){
        guard !newName.isEmpty else{
            return;
        }
        let namePrefix = newName.prefix(NucleoConsole.MAX_NAME_LENGTH);
        mConsole.writeMessage(String(format: NucleoConsole.SET_NAME_COMMAND_FORMAT, String(namePrefix)));
    }
 
    public func setTime(date:Date){
        let timeStr = NucleoConsole.SET_TIME_FORMAT.string(from: date);
        mConsole.writeMessage(String(format:NucleoConsole.SET_TIME_COMMAND_FORMAT,timeStr));
    }
    
    public func setDate(date:Date){
        let timeStr = NucleoConsole.SET_DATE_FORMAT.string(from: date);
        mConsole.writeMessage(String(format:NucleoConsole.SET_DATE_COMMAND_FORMAT,timeStr));
    }
 
    public func setDateAndTime(date:Date){
        setDate(date: date);
        setTime(date: date);
    }
    
}
