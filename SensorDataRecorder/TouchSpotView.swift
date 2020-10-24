//https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_touches_in_your_view/implementing_a_multi-touch_app//

import UIKit

class TouchSpotView : UIView {
   override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = UIColor.lightGray
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   // Update the corner radius when the bounds change.
   override var bounds: CGRect {
      get { return super.bounds }
      set(newBounds) {
         super.bounds = newBounds
         layer.cornerRadius = newBounds.size.width / 2.0
      }
   }
}
