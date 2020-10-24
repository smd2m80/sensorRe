import UIKit
import CoreMotion
import simd

//import SwiftUI

//@available(iOS 13.0, *)
class testViewController: UIViewController {

    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    let motionManager = CMMotionManager()
    var attitude = SIMD3<Double>.zero
    var gyro = SIMD3<Double>.zero
    var gravity = SIMD3<Double>.zero
    var acc = SIMD3<Double>.zero
    var tapLocation = CGPoint(x: 0, y: 0)
    var touchB = 0
    var touchM = 0
    var tapCount = 0
    
    var isTapped = 0
    
    var format = DateFormatter()    //日付を取得
    let csvManager = SensorDataCsvManager()
    var text = ""
    var bufText = ""

    var i = 0
    var j = 0
    let endLabel = UILabel() // ラベルの生成
    var circleDraw :UIView!
    
    var iarray = [Int](1...90).shuffled()
    
    var preCircleNum = 0
    
    var myCircleNum = 0
    let uiImageView = UIImageView()
    var DisplayX = 0
    var DisplayY = 0
    let Finger:UIImage = UIImage(named:"Finger")!
    let Phone:UIImage = UIImage(named:"Phone")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startSensorUpdates(intervalSeconds: 0.01) // 100Hz
        csvManager.startRecording()

        appDelegate.smallCirleX = 0
        appDelegate.smallCirleY = 0
        
        iarray = [Int](1...90).shuffled()
//        iarray = [5,4,3,2,1]
        // tapセンサー
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(testViewController.tapped(_:)))
        // デリゲートをセット
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        self.view.addGestureRecognizer(tapGesture)
        
        
        // Labelの書式
        endLabel.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 44) // 位置とサイズの指定
        endLabel.textAlignment = NSTextAlignment.center // 横揃えの設定
        endLabel.textColor = UIColor.black // テキストカラーの設定
        endLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        endLabel.text = "1セット/6セット"
        self.view.addSubview(endLabel) // ラベルの追加

    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        print("tap catch")
        if sender.state == .ended {
            
            isTapped = 1
            i += 1
            print("curentCNum: ", myCircleNum)

            if iarray.count > 0{
                uiImageView.isHidden = true
                // 処理を現時点から0.5秒後に実行する
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    // bufTextをレコード
                    self.csvManager.addRecordText(addText: self.bufText)
                    self.bufText = self.text
                    self.text = ""

                    self.preCircleNum = self.myCircleNum
                    self.drawNewMarker()
                    print(self.iarray)
                    
                    if self.i==15 { //15drag終わり
                        self.i = 0
                        self.j += 1
                    }
                    self.endLabel.text = String(self.j+1)+"セット/6セット"
                }
                    
                    
            }else{ //listを消費したら、record
                // ここで最後のタップにミスがないか尋ねる
                self.csvManager.addRecordText(addText: bufText)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.csvManager.addRecordText(addText: self.text)
                    if self.csvManager.isRecording{
                        self.csvManager.stopRecording()
                        
                        // save csv file
                        self.format.dateFormat = "yyyy-MMdd-HHmmss"
                        
                        let dateText = "touch_" + "100Hz" + self.format.string(from: Date())
                        self.endLabel.text = "おしまい"
                        self.view.backgroundColor = .gray

                        self.showSaveCsvFileAlert(fileName: dateText)
                    }else{
                        self.dismiss(animated: true, completion: nil)   //VC破棄
                    }
                }
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchB = 1
        let touch = touches.first!
        tapLocation = touch.location(in: self.view)
        tapCount += 1
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchM = 1
            tapLocation = touch.location(in: self.view)
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
//            format.dateFormat = "MMddHHmmssSSS"
            format.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmssSSS", options: 0, locale: Locale(identifier: "ja_JP"))
            
//            var text = ""
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
            
            text += String(DisplayX) + ","
            text += String(DisplayY) + ","
//            text += appDelegate.smallCirleX.description + ","
//            text += appDelegate.smallCirleY.description + ","

            text += tapLocation.x.description + ","
            text += tapLocation.y.description + ","
            
            text += String(touchB) + ","
            touchB = 0
            text += String(touchM) + ","
            touchM = 0
            text += String(isTapped) + ","
            isTapped = 0

            text += String(myCircleNum) + "\n"

//            csvManager.addRecordText(addText: text)
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
    
    // retry
    @IBAction func buttonActionSheet(_ sender : Any) {
           // UIAlertController
           let alertController:UIAlertController =
               UIAlertController(title:"タップをミスった？",
                                 message: "前回のタップを削除します",
                                 preferredStyle: .actionSheet)
           self.uiImageView.isHidden = true

           let actionDelete = UIAlertAction(title: "YES", style: .destructive){
               action in
            print("push YES! preN: ", self.preCircleNum)
            self.bufText = ""
            self.text = ""
            self.iarray.append(contentsOf: [self.myCircleNum, self.preCircleNum])
            print(self.iarray)
            // 処理を現時点から0.5秒後に実行する
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.drawNewMarker()
            }
            
           }
           
           let actionCancel = UIAlertAction(title: "Cancel", style: .cancel){
               (action) -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.uiImageView.isHidden = false
                print("Cancel")
            }
           }
           
           // actionを追加
           alertController.addAction(actionDelete)
           alertController.addAction(actionCancel)
           
           // UIAlertControllerの起動
           present(alertController, animated: true, completion: nil)
       }
    
    // safeArea取得
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            appDelegate.safeAreaTop = self.view.safeAreaInsets.top
            appDelegate.safeAreaBottom = self.view.safeAreaInsets.bottom
            appDelegate.safeAreaLeft = self.view.safeAreaInsets.left
            appDelegate.safeAreaLeft = self.view.safeAreaInsets.right
        }
        // Screen Size の取得
        appDelegate.screenWidth = self.view.bounds.width
        appDelegate.screenHeight = self.view.bounds.height
        appDelegate.safeAreaHeight = appDelegate.screenHeight-appDelegate.safeAreaTop - appDelegate.safeAreaBottom
//        print("CircleL:",appDelegate.screenWidth ?? 0,"R: ",appDelegate.safeAreaHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        drawNewMarker()
    }
    
    func drawNewMarker(){
        myCircleNum = iarray.popLast() ?? 0
        if (myCircleNum%2 != 0) {
            uiImageView.image = Finger
        }else{
            uiImageView.image = Phone
        }
        uiImageView.frame = CGRect(x:0, y:0, width:70, height:70)
        
        DisplayX = Int(appDelegate.screenWidth/3) * (myCircleNum%3) + Int.random(in: 35 ..< (Int(appDelegate.screenWidth/3)-35) )
        DisplayY = Int(appDelegate.safeAreaTop) +  Int(appDelegate.safeAreaHeight/3) * (myCircleNum%9/3) + Int.random(in: 35 ..< (Int(appDelegate.safeAreaHeight/3)-35) )
        
        // 画像の表示場所 中心座標の位置を指定
        uiImageView.center = CGPoint(x:DisplayX, y:DisplayY)

        self.view.addSubview(uiImageView)
        self.uiImageView.isHidden = false

    }

//
//    // ドラッグセンサー
//    @State var isDragging = false
//
//    var drag: some Gesture {
//        DragGesture()
//            .onChanged { _ in self.isDragging = true }
//            .onEnded {
//                _ in self.isDragging = false
//                print("dragEnd")
//        }
//    }
//
//    var body: some View {
//        Circle()
//            .fill(self.isDragging ? Color.red : Color.blue)
//            .frame(width: 100, height: 100, alignment: .center)
//            .gesture(drag)
//    }
//
    
    //    //　ドラッグ時に呼ばれる
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        // タッチイベントを取得
    //        let touchEvent = touches.first!
    //
    //            // ドラッグ前の座標, Swift 1.2 から
    //        let preDx = touchEvent.previousLocation(in: self.view).x
    //        let preDy = touchEvent.previousLocation(in: self.view).y
    //
    //        // ドラッグ後の座標
    //        let newDx = touchEvent.location(in: self.view).x
    //        let newDy = touchEvent.location(in: self.view).y
    //
    //        // ドラッグしたx座標の移動距離
    //        let dx = newDx - preDx
    //        print("x:\(dx)")
    //
    //        // ドラッグしたy座標の移動距離
    //        let dy = newDy - preDy
    //        print("y:\(dy)")
    //
    //
    //
    ////        // 小数点以下２桁のみ表示
    ////        labelX.text = "x: ".appendingFormat("%.2f", newDx)
    ////        labelY.text = "y: ".appendingFormat("%.2f", newDy)
    //    }
//
//      var touchViews = [UITouch:TouchSpotView]()
    
//      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////         for touch in touches {
//////            createViewForTouch(touch: touch)
//            print("began")
////         }
//      }
//
//      override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//         for touch in touches {
////            let view = viewForTouch(touch: touch)
//            // Move the view to the new location.
////            let newLocation = touch.location(in: self.view)
////            view?.center = newLocation
//
//            //タッチの正確な位置
//            print(touch.preciseLocation(in: self.view))
//
//         }
//      }
//
//      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////         for touch in touches {
////            removeViewForTouch(touch: touch)
//            print("ended")
////         }
//      }
//
//      override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//         for touch in touches {
////            removeViewForTouch(touch: touch)
//         }
//      }
    
//    func createViewForTouch( touch : UITouch ) {
//       let newView = TouchSpotView()
//       newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
//        newView.center = touch.location(in: self.view)
//
//       // Add the view and animate it to a new size.
//        self.view.addSubview(newView)
//       UIView.animate(withDuration: 0.2) {
//          newView.bounds.size = CGSize(width: 100, height: 100)
//       }
//
//       // Save the views internally
//       touchViews[touch] = newView
//    }
//
//    func viewForTouch (touch : UITouch) -> TouchSpotView? {
//       return touchViews[touch]
//    }
//
//    func removeViewForTouch (touch : UITouch ) {
//       if let view = touchViews[touch] {
//          view.removeFromSuperview()
//          touchViews.removeValue(forKey: touch)
//       }
//    }
}
