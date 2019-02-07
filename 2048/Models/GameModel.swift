//
//  GameModel.swift
//  2048
//
//  Created by Yash Patel on 2/5/19.
//  Copyright © 2019 Yash Patel. All rights reserved.
//

import UIKit

protocol GameModelProtocol :class {
    func scoreChange(score : Int)
    func moveOneTile(from: (Int ,Int), to: (Int, Int),value :Int)
    func moveTwoTile(from: ((Int ,Int),(Int ,Int)), to: (Int, Int),value :Int)
    func insertTile(location: (Int,Int),value : Int)
}

class GameModel:NSObject{
    
    let dimension:Int
    let threshold:Int
    
    var score: Int = 0
    {
        didSet{
            delegate.scoreChange(score: score)
        }
    }
    var gameboard: SquareGameboard<TileObject>
    
    let delegate : GameModelProtocol
    var queue: [MoveCommand]
    var timer: Timer
    
    let maxCommands=100
    let queueDelay=0.3
    init(dimention d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameboard(dimension : d, initialValue: .empty)
        
        super.init()
        
        
    }
    
    func reset(){
        score = 0
        gameboard.setAll(to: .empty)
        queue.removeAll(keepingCapacity : true)
        timer.invalidate()
    }
    
    func queueMove(direction : MoveDirection, completion: @escaping (Bool)->()){
        
        if queue.count > maxCommands{
            return
        }
        let  command = MoveCommand(d: direction, c: completion)
        queue.append(command)
        if(!timer.isValid){
            timerFired(timer)
        }
    }
    
    @objc func timerFired(_: Timer) {
        if queue.count == 0 {
            return
        }
        // Go through the queue until a valid command is run or the queue is empty
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.remove(at: 0)
            changed = performMove(direction: command.direction)
            command.completion(changed)
            if changed {
                // If the command doesn't change anything, we immediately run the next one
                break
            }
        }
        if changed {
            timer = Timer.scheduledTimer(timeInterval: queueDelay,
                                         target: self,
                                         selector:
                #selector(GameModel.timerFired(_:)),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    func insertTile(pos: (Int,Int), value :Int){
        let (x,y) = pos
        switch gameboard[x,y]{
        case .empty:
            gameboard[x,y] = TileObject.tile(value)
            delegate.insertTile(location: pos , value: value)
        case .tile:
            break
            
        }
    }
    
    
    func insertTileAtRandomLocation(value : Int){
        let openSpots = gameboardEmptySpots()
        if openSpots.count == 0{
            return
        }
        let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
        let (x,y)=openSpots[idx]
        insertTile(pos: (x,y), value: value)
    }
    
    func gameboardEmptySpots()->[(Int,Int)]{
        
        var buffer = Array<(Int,Int)>()
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameboard[i,j]{
                case .empty:
                    buffer += [(i,j)]
                case .tile:
                    break
                }
            }
        }
        return buffer
    }
    
    func gameboardFull()->Bool{
        return gameboardEmptySpots().count == 0
    }
    
    func tileBelowHasSameValue(location: (Int, Int), value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gameboard[x, y+1] {
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(location: (Int, Int), value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gameboard[x+1, y] {
            return v == value
        }
        return false
    }
    
    func userHasLost() -> Bool {
        guard gameboardEmptySpots().isEmpty else {
            // Player can't lose before filling up the board
            return false
        }
        
        // Run through all the tiles and check for possible moves
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameboard[i, j] {
                case .empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .tile(v):
                    if tileBelowHasSameValue(location: (i, j), value: v) ||
                        tileToRightHasSameValue(location: (i, j), value: v)
                    {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func userHasWon()->(Bool, (Int,Int)?){
        for i in 0..<dimension{
            for j in 0..<dimension{
                switch gameboard[i,j]{
                case let .tile(v) where v >= threshold:
                    return (true,(i,j))
                default:
                    continue
                    
                    }
                }
            }
        return (false,nil)
        }
    
    func performMove(direction: MoveDirection) -> Bool {
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
            var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.dimension)
            for i in 0..<self.dimension {
                switch direction {
                case .up: buffer[i] = (i, iteration)
                case .down: buffer[i] = (self.dimension - i - 1, iteration)
                case .left: buffer[i] = (iteration, i)
                case .right: buffer[i] = (iteration, self.dimension - i - 1)
                }
            }
            return buffer
        }
        
        var atLeastOneMove = false
        for i in 0..<dimension{
            let coords = coordinateGenerator(i)
            
            let tiles = coords.map() { (c: (Int,Int)) -> TileObject in
                let (x,y) = c
                return self.gameboard[x,y]
                }
            let orders = merge(group: tiles)
            atLeastOneMove = orders.count > 0 ? true :  atLeastOneMove
            
            for object in orders{
                switch object{
                case let MoveOrder.singleMoveOrder(s,d,v,wasMerge):
                    let (sx, sy) = coords[s]
                    let (dx,dy) = coords[d]
                    if wasMerge {
                        score += v
                        gameboard[sx,sy] = TileObject.empty
                        gameboard[dx,dy] = TileObject.tile(v)
                        delegate.moveOneTile(from: coords[s], to: coords[d], value :v)
                        
                    }
               
                case let MoveOrder.doubleMoveOrder(s1,s2,d,v):
                        let (s1x, s1y) = coords[s1]
                        let (s2x, s2y) = coords[s2]
                        let (dx, dy) = coords[d]
                        score += v
                        gameboard[s1x,s1y] = TileObject.empty
                        gameboard[s2x,s2y] = TileObject.empty
                        gameboard [dx,dy] = TileObject.tile(v)
                        delegate.moveTwoTile(from: ((coords[s1],coords[s2])), to: coords[d], value: v)
                        }
            }
            
            
            
        }
        
   return atLeastOneMove
    }// func ends
    
    func condense(group: [TileObject]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        for (idx, tile) in group.enumerated() {
            // Go through all the tiles in 'group'. When we see a tile 'out of place', create a corresponding ActionToken.
            switch tile {
            case let .tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.noAction(source: idx, value: value))
            case let .tile(value):
                tokenBuffer.append(ActionToken.move(source: idx, value: value))
            default:
                break
            }
        }
        return tokenBuffer;
    }
    
    class func quiescentTileStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken] {
        
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        for (idx, token) in group.enumerated() {
            if skipNext {
                skipNext = false
                continue
            }
            switch token {
            case .singleCombine:
                assert(false, "Cannot have single combine token in input")
            case .doubleCombine:
                assert(false, "Cannot have double combine token in input")
            case let .noAction(s, v)
                where (idx < group.count-1
                    && v == group[idx+1].getValue()
                    && GameModel.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s)):
                let next = group[idx+1]
                let nv = v + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), value: nv))
            case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
            case let .noAction(s, v) where !GameModel.quiescentTileStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s):
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            case let .noAction(s, v):
                tokenBuffer.append(ActionToken.noAction(source: s, value: v))
            case let .move(s, v):
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    func convert(group: [ActionToken]) -> [MoveOrder] {
        var moveBuffer = [MoveOrder]()
        for (idx, t) in group.enumerated() {
            switch t {
            case let .move(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
            case let .singleCombine(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
            case let .doubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default:
                break
            }
        }
        return moveBuffer
    }
    
    func merge(group: [TileObject]) -> [MoveOrder] {
        return convert(group: collapse(group: condense(group: group)))
    }
    
    
    
    
}// class ends
    
    
    
    

    

