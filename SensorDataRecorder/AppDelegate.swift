import UIKit
import simd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // tapしたかの判定
    var isTouch = false
    
    //　touch dragモード切り替え
    var isDrag = false
    
    // view 削除用にtagを設置
    var tagViewB = 27
    
    // circles座標
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var safeAreaTop: CGFloat!
    var safeAreaBottom: CGFloat!
    var safeAreaLeft: CGFloat!
    var safeAreaRight: CGFloat!
    var safeAreaHeight: CGFloat!
    var xfValue: CGFloat = 0.0
    var yfValue: CGFloat = 0.0
    var smallCirleX :CGFloat = 0.0
    var smallCirleY :CGFloat = 0.0

    // タッチ座標
    var location: CGPoint!
    
    // アプリが起動した時
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // アプリがバックグラウンドになった時
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    
    // バックグランドから戻ってきたとき
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    // バックグランドから戻ってきたとき_2
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    // アプリが終了する時
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

