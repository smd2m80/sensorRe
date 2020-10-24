import Foundation

class SensorDataCsvManager {
    
    private(set) var isRecording = false
//    private let headerText = "timestamp,attitudeX,attitudeY,attitudeZ,gyroX,gyroY,gyroZ,gravityX,gravityY,gravityZ,accX,accY,accZ,tap"
    var headerText = "timestamp,attX,attY,attZ,gyroX,gyroY,gyroZ,gyroScalar,accX,accY,accZ,accScalar,circleSx,circleSy,tapLx,tapLy,touchB,touchM,isTapped,tapID"
    private var recordText = ""
    
    var format = DateFormatter()
    
    
    init() {
//        format.dateFormat = "yyyyMMddHHmmssSSS"
        format.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmssSSS", options: 0, locale: Locale(identifier: "ja_JP"))
    }
    
    func startRecording() {
        recordText = ""
        recordText += headerText + "\n"
        isRecording = true
    }
    
    func stopRecording() {
        isRecording = false
    }
    
    func addRecordText(addText:String) {
        recordText += addText 
    }
    
    func saveSensorDataToCsv(fileName:String) {
        
        let filePath = NSHomeDirectory() + "/Documents/" + fileName + ".csv"
        
        do{
            try recordText.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            print("Success to Write CSV")
        }catch let error as NSError{
            print("Failure to Write CSV\n\(error)")
        }
    }
}
