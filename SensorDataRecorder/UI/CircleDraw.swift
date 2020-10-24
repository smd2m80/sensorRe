import UIKit

class CircleDraw: UIView {
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    override func draw(_ rect: CGRect) {
        
        appDelegate.xfValue = CGFloat.random(in: 16 ..< (appDelegate.screenWidth-86)) //padding:L16,R16
        appDelegate.yfValue = CGFloat.random(in: 44 ..< (appDelegate.safeAreaHeight-70)) //Top:44,Bottom:34
//        print(appDelegate.xfValue)
//        print(appDelegate.yfValue)

        if (appDelegate.tagViewB%2 == 0){
            // 塗りつぶし色の設定
            UIColor.gray.setFill()
        }else{
            // 塗りつぶし色の設定
            UIColor.orange.setFill()
        }

        // stroke 色の設定
        UIColor.darkGray.setStroke()
        // 楕円 -------------------------------------
        let oval = UIBezierPath(ovalIn:
            CGRect(x: appDelegate.xfValue, y: appDelegate.yfValue, width: 70, height: 70))
        // 内側の塗りつぶし
        oval.fill()
//         ライン幅
//        oval.lineWidth = 2
        // 描画
        oval.stroke()

        // drag時の終点表示
        if appDelegate.isDrag{
            appDelegate.smallCirleX = CGFloat.random(in: 16 ..< (appDelegate.screenWidth-46))//.truncatingRemainder(dividingBy: appDelegate.screenWidth)
            appDelegate.smallCirleY = CGFloat.random(in: 44 ..< (appDelegate.screenHeight-64))//.truncatingRemainder(dividingBy: appDelegate.screenHeight)
                        
            let oval2 = UIBezierPath(ovalIn:
                CGRect(x: appDelegate.smallCirleX, y: appDelegate.smallCirleY, width: 30, height: 30))
            // 塗りつぶし色の設定
            UIColor.gray.setFill()
            oval2.fill()
            oval2.stroke()
        }
        
    }
    
}

