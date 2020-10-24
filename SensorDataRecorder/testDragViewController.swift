import UIKit
import CoreMotion
import simd

class testDragViewController: UIViewController {

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let motionManager = CMMotionManager()
    var attitude = SIMD3<Double>.zero
    var gyro = SIMD3<Double>.zero
    var gravity = SIMD3<Double>.zero
    var acc = SIMD3<Double>.zero
    var tapLocation = CGPoint(x: 0, y: 0)
    var touchB = 0
    var touchM = 0
    var isTapped = 0
    var tapCount = 0
    
//    var referenceAttitude :CMAttitude!
//    var refAttitude = SIMD3<Double>.zero
    var format = DateFormatter()    //日付を取得
    let csvManager = SensorDataCsvManager()
//    var isTouch = false

    var i = 0
    var j = 0
    let endLabel = UILabel() // ラベルの生成
    var circleDraw :UIView!

    static var iarray = [Int](1...90).shuffled()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSensorUpdates(intervalSeconds: 0.01) // 100Hz
        csvManager.headerText = "timestamp,attX,attY,attZ,gyroX,gyroY,gyroZ,gyroScalar,accX,accY,accZ,accScalar,circleSx,circleSy,cirlcleEx,circleEy,tapLx,tapLy,touchB,touchM,isTapped,tapID"
        csvManager.startRecording()
        var iarray = [Int](1...90).shuffled()
        
        
        appDelegate.tagViewB = iarray.popLast() ?? 0
        // Screen Size の取得
        appDelegate.screenWidth = self.view.bounds.width
        appDelegate.screenHeight = self.view.bounds.height
        
        circleDraw = CircleDraw(frame: CGRect(x: 0, y: 0,
                                              width: appDelegate.screenWidth, height: appDelegate.screenHeight))
        circleDraw.tag = appDelegate.tagViewB
        self.view.addSubview(circleDraw)

        // 不透明にしない（透明）
        circleDraw.isOpaque = false
        
        // Labelの書式
        endLabel.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44) // 位置とサイズの指定
        endLabel.textAlignment = NSTextAlignment.center // 横揃えの設定
        endLabel.textColor = UIColor.black // テキストカラーの設定
        endLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        endLabel.text = "1セット/6セット"
        self.view.addSubview(endLabel) // ラベルの追加

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                let touch = touches.first!
                touchB = 1
                touchM = 1
                tapLocation.x = touch.location(in: self.view).x
                tapLocation.y = touch.location(in: self.view).y
                tapCount += 1
//
//        self.referenceAttitude = self.motionManager.deviceMotion?.attitude;
                print("began")

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     for touch in touches {
    //            let view = viewForTouch(touch: touch)
        // Move the view to the new location.
    //            let newLocation = touch.location(in: self.view)
    //            view?.center = newLocation
        
        tapLocation = touch.location(in: self.view)
        //タッチの正確な位置
        print(touch.preciseLocation(in: self.view))

     }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //         for touch in touches {
    //            removeViewForTouch(touch: touch)
        isTapped = 1
        touchM = 0
        tapLocation = CGPoint(x: 0,y: 0)
        // タグを利用してマーカーview削除
        let fetchedViewB = self.view.viewWithTag(appDelegate.tagViewB)
        fetchedViewB?.removeFromSuperview()
        
        if j<6 {
                i += 1
                print("drag" + String(i) + " done")

                // swipe遷移
//                let nextView = self.storyboard? .instantiateViewController(withIdentifier: "testbreak") as! testBreakViewController
//                self.present(nextView, animated: true, completion: nil)　//present https://capibara1969.com/684/
            
                // swipe遷移
//                self.performSegue(withIdentifier: "toBreakdrag", sender: nil)
                // 処理を現時点から0.5秒後に実行する
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    
                    self.appDelegate.tagViewB = testDragViewController.iarray.popLast() ?? 0
                    
                    self.circleDraw = CircleDraw(frame: CGRect(x: 0, y: 0,
                                                               width: self.appDelegate.screenWidth, height: self.appDelegate.screenHeight))
        //                circleDraw.tag = appDelegate.tagViewB
                    self.view.addSubview(self.circleDraw)
                    self.circleDraw.tag = self.appDelegate.tagViewB
                    // 不透明にしない（透明）
                    self.circleDraw.isOpaque = false
                }
                if i>=15{ //10drag終わったらセットjが切り上がる
                    i=0
                    j+=1
                    endLabel.text = String(j+1) + "セット/6セット"
                }
        }else{ //10セット完了
            if csvManager.isRecording{
                csvManager.stopRecording()
                
                // save csv file
                format.dateFormat = "yyyy-MMdd-HHmmss"
                
                var dateText = "touch_" + format.string(from: Date())
                if appDelegate.isDrag{
                    dateText = "drag_" + format.string(from: Date())
                }
                endLabel.text = "おしまい"
                self.view.backgroundColor = .gray

                showSaveCsvFileAlert(fileName: dateText)
            }else{
                self.dismiss(animated: true, completion: nil)   //VC破棄
            }
        }

        
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
    func getMotionData(deviceMotion:CMDeviceMotion) {
        
//        refAttitude.x = referenceAttitude.pitch
//        refAttitude.y = referenceAttitude.roll
//        refAttitude.z = referenceAttitude.yaw
        attitude.x = deviceMotion.attitude.pitch
        attitude.y = deviceMotion.attitude.roll
        attitude.z = deviceMotion.attitude.yaw
        
        gyro.x = deviceMotion.rotationRate.x
        gyro.y = deviceMotion.rotationRate.y
        gyro.z = deviceMotion.rotationRate.z
        acc.x = deviceMotion.userAcceleration.x
        acc.y = deviceMotion.userAcceleration.y
        acc.z = deviceMotion.userAcceleration.z
//        gravity.x = deviceMotion.gravity.x
//        gravity.y = deviceMotion.gravity.y
//        gravity.z = deviceMotion.gravity.z

        // record sensor data
        if csvManager.isRecording {
            format.dateFormat = "MMddHHmmssSSS"
            
            var text = ""
            text += format.string(from: Date()) + ","
            
            text += String(attitude.x) + ","
            text += String(attitude.y) + ","
            text += String(attitude.z) + ","
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
            
            text += appDelegate.xfValue.description + ","
            text += appDelegate.yfValue.description + ","
            text += appDelegate.smallCirleX.description + ","
            text += appDelegate.smallCirleY.description + ","

            text += tapLocation.x.description + ","
            text += tapLocation.y.description + ","
                        
            text += String(touchB) + ","
            touchB = 0
            text += String(touchM) + ","
            text += String(isTapped) + ","
            isTapped = 0
            text += String(appDelegate.tagViewB)

            csvManager.addRecordText(addText: text)
        }
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
                            self.dismiss(animated: true, completion: nil)   //VC破棄

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
                            self.dismiss(animated: true, completion: nil)   //VC破棄

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
