import SwiftUI

struct BoardModel {
    let board: [TileModel]
    
    let rows: Int 
    let cols: Int
    
    private init(_ rows: Int, _ cols: Int, board: [TileModel]) {
        self.rows = rows 
        self.cols = cols 
        
        self.board = board
    }
    
    func replaced(with newBoard: [TileModel]) -> BoardModel {
        BoardModel(rows, cols, board: newBoard)
    }
    
    init(_ cols: Int, _ rows: Int) {
        self.rows = rows 
        self.cols = cols 
        
        let midx = Int(floor(CGFloat(cols)/2.0))
        let midy = Int(floor(CGFloat(rows)/2.0))
        
        let cutOffX = Int(floor(CGFloat(cols) / 5.0))
        let cutOffY = Int(floor(CGFloat(rows) / 5.0))
        
        let minDesired = 2
        
        var currentRandom = [0, 0, 0, 0]
        
        self.board =  
        (0..<rows).flatMap { y in
            (0..<cols).map { x in
                
                let isBottom = y > midy
                let isLeft = x < midx
                let quadrant: Int
                switch(isBottom, isLeft) {
                case (false, false): quadrant = 0
                case (true, false): quadrant = 1
                case (false, true): quadrant = 2
                case (true, true): quadrant = 3
                } 
                
                guard 
                    x != midx || y != midy
                else {
                    return .start
                }
                
                if (abs(midx - x) > cutOffX || abs(midy - y) > cutOffY) && drand48() < (0.04 * Double(minDesired - currentRandom[quadrant])) {
                    currentRandom[quadrant] += 1
                    return .empty
                    //return TileModel.random
                } else {
                    return TileModel.empty
                }
            }
        }
        
        // quick sanity check since the flatMap/map order
        // matters
        guard .start == board[midy*cols + midx] else {
            fatalError("Invalid board")
        }
    }
    
    func tileAt(x: Int, y: Int) -> TileModel {
        let ix = y*cols + x
        guard ix < self.board.count else {
            fatalError("Wrong index requested \(x) \(y) (cols \(cols) rows \(rows))")
        }
        
        let result = self.board[ix]
        return result
    }
    
    func changed(_ model: TileModel, x: Int, y: Int) -> BoardModel {
        var data = self.board
        data[y * cols + x] = model 
        return BoardModel(rows, cols, board: data)
    }
}
