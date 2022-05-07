import SwiftUI

extension Array {
    func optGet(_ ix: Int) -> Element? {
        guard 
            ix < self.count, 
                ix >= 0 else { 
                    return nil 
                }
        return self[ix]
    }
}
