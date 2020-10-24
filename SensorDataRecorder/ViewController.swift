import UIKit
import CoreMotion
import simd

//@available(iOS 13.0, *)
class ViewController: UIViewController,UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var sensorDataInfoTextView: UITextView!
    @IBOutlet weak var sensorIntervalLabel: UILabel!
    @IBOutlet weak var sensorIntervalSlider: UISlider!
    @IBOutlet weak var recordCsvButton: CustomButton!
    @IBOutlet weak var modeTouchorDrag: UIButton!
    @IBOutlet weak var csvFileManagementButton: CustomButton!
    
    let motionManager = CMMotionManager()
    var attitude = SIMD3<Double>.zero
    var gyro = SIMD3<Double>.zero
    var gravity = SIMD3<Double>.zero
    var acc = SIMD3<Double>.zero
    
    var offset = CGPoint(x: 0, y: 0)
    
    var format = DateFormatter()    //日付を取得
    let csvManager = SensorDataCsvManager()
//    var isTouch = false
    var i = 0

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSensorUpdates(intervalSeconds: 0.01) // 50Hz
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func changeSensorIntervalSlider(_ sender: UISlider) {
        let val = round(sender.value)
        sensorIntervalSlider.value = val
        
        // change sensor interval
        stopSensorUpdates()
        let intervalSec = Double(1.0/val)
        startSensorUpdates(intervalSeconds: intervalSec)
        
        sensorIntervalLabel.text = "Interval\n" + String(format: "%.0f",val) + "Hz"
    }
    // START・STOPボタンをおしたとき
    @IBAction func recordCsvAction(_ sender: Any) {
        // 別画面toTestへのSegueを実行
        if appDelegate.isDrag{
            self.performSegue(withIdentifier: "toDragTest", sender: nil)
        }else{
             self.performSegue(withIdentifier: "toTest", sender: nil)
        }
    }
    // ドラッグ↔︎タッチ
    @IBAction func modeChange(_ sender: Any) {
        if appDelegate.isDrag{
            appDelegate.isDrag = false
            modeTouchorDrag.setTitle("タッチ", for: .normal)
        }else{
            appDelegate.isDrag = true
            modeTouchorDrag.setTitle("ドラッグ", for: .normal)
        }
        
    }
    
    
    @IBAction func cscFileManagementButtonAction(_ sender: Any) {
        let csvFileManagementViewController = self.storyboard?.instantiateViewController(withIdentifier: "CsvFileManagementViewController") as! CsvFileManagementViewController
        csvFileManagementViewController.modalPresentationStyle = .overCurrentContext
        csvFileManagementViewController.modalTransitionStyle = .crossDissolve
        self.present(csvFileManagementViewController, animated: true, completion: nil)
    }
    
    func startSensorUpdates(intervalSeconds:Double) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = intervalSeconds
            
            // start sensor updates
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.getMotionData(deviceMotion: motion!)
                
            })
        }
    }
    
    func stopSensorUpdates() {
        if motionManager.isDeviceMotionAvailable{
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    func getMotionData(deviceMotion:CMDeviceMotion) {

        attitude.x = deviceMotion.attitude.pitch
        attitude.y = deviceMotion.attitude.roll
        attitude.z = deviceMotion.attitude.yaw
        gyro.x = deviceMotion.rotationRate.x
        gyro.y = deviceMotion.rotationRate.y
        gyro.z = deviceMotion.rotationRate.z
//        var scalarGyro = gyro.x * gyro.y * gyro.z
        gravity.x = deviceMotion.gravity.x
        gravity.y = deviceMotion.gravity.y
        gravity.z = deviceMotion.gravity.z
        acc.x = deviceMotion.userAcceleration.x
        acc.y = deviceMotion.userAcceleration.y
        acc.z = deviceMotion.userAcceleration.z
//        var scalarAcc = acc.x * acc.y * acc.z

        displaySensorData()
        
        // record sensor data
        if csvManager.isRecording {
            format.dateFormat = "MMddHHmmssSSS"
            
            var text = ""
//            text += format.string(from: Date()) + ","
            
//            text += String(attitude.x) + ","
//            text += String(attitude.y) + ","
//            text += String(attitude.z) + ","
            text += String(gyro.x) + ","
            text += String(gyro.y) + ","
            text += String(gyro.z) + ","
            text += String(gyro.x * gyro.y * gyro.z) + ","
//            text += String(gravity.x) + ","
//            text += String(gravity.y) + ","
//            text += String(gravity.z) + ","
            text += String(acc.x) + ","
            text += String(acc.y) + ","
            text += String(acc.z) + ","
            text += String(acc.x * acc.y * acc.z) + ","
            
            text += offset.x.description + ","
            text += offset.y.description + ","
            
            offset = CGPoint(x: 0,y: 0)
                        
            if appDelegate.isTouch {
                text += String(1)
                appDelegate.isTouch = false
            }else{
                text += String(0)
            }
            csvManager.addRecordText(addText: text)
        }
    }
    
    func displaySensorData() {
        var text = ""
        
        text += "Attitude\n"
        text += "X(pitch): " + String(format:"%06f", attitude.x) + "\n"
        text += "Y(roll): " + String(format:"%06f", attitude.y) + "\n"
        text += "Z(yaw): " + String(format:"%06f", attitude.z) + "\n"
        
        text += "Gyro(Rotation Rate)\n"
        text += "X: " + String(format:"%06f", gyro.x) + "\n"
        text += "Y: " + String(format:"%06f", gyro.y) + "\n"
        text += "Z: " + String(format:"%06f", gyro.z) + "\n"
        
        text += "Gravity\n"
        text += "X: " + String(format:"%06f", gravity.x) + "\n"
        text += "Y: " + String(format:"%06f", gravity.y) + "\n"
        text += "Z: " + String(format:"%06f", gravity.z) + "\n"
        
        text += "User Acceleration\n"
        text += "X: " + String(format:"%06f", acc.x) + "\n"
        text += "Y: " + String(format:"%06f", acc.y) + "\n"
        text += "Z: " + String(format:"%06f", acc.z) + "\n"
        
        sensorDataInfoTextView.text = text
    }
    
    func showSaveCsvFileAlert(fileName:String){
        let alertController = UIAlertController(title: "Save CSV file", message: "Enter file name to add.", preferredStyle: .alert)
        
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "OK",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let textField = alertController.textFields![0] as UITextField
                            self.csvManager.saveSensorDataToCsv(fileName: textField.text!)
            })
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.showDeleteRecordedDataAlert(fileName: fileName)
            })
        
        alertController.addTextField { (textField:UITextField!) -> Void in
            alertController.textFields![0].text = fileName
        }
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteRecordedDataAlert(fileName:String){
        let alertController = UIAlertController(title: "Delete recorded data", message: "Do you delete recorded data?", preferredStyle: .alert)
        
        let defaultAction:UIAlertAction =
            UIAlertAction(title: "OK",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // delete recorded data
            })
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            self.showSaveCsvFileAlert(fileName: fileName)
            })
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Home画面に戻るための仕込み 別画面でEixtのSegueでreturnMenuを選択すると、このHomeに戻る ref.book
    @IBAction func retuenMenu(segue: UIStoryboardSegue){
    }   
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first! //このタッチイベントの場合確実に1つ以上タッチ点があるので`!`つけてOKです
//        appDelegate.location = touch.location(in: self.view) //in: には対象となるビューを入れます
//
//        offset.x = appDelegate.location.x - appDelegate.xfValue - 35
//        offset.y = appDelegate.location.y - appDelegate.yfValue - 35
//        appDelegate.isTouch = true
//        print("VCtouchB!")
//    }
    

}
