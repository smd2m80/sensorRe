import UIKit

class testBreakViewController: UIViewController {
    
    @IBOutlet var imageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面の横幅を取得
        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
        
        let image:UIImage = UIImage(named:"arrow")!
        
        // UIImageView 初期化
        imageView.image = image
        
        // pi/2で回転
        let angle = CGFloat.pi * CGFloat(Int.random(in: 0...3)) / 2
        let transRotate = CGAffineTransform(rotationAngle: CGFloat(angle));
        imageView.transform = transRotate
        
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        
        // UIImageViewのインスタンスをビューに追加
        self.view.addSubview(imageView)
    }
    
    // swipe画面表示
    
    // これないとtestViewControllerの設定を引き継ぐ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                    // ViewContoller消せた
                    self.dismiss(animated: true, completion: nil)
    }
    

}
