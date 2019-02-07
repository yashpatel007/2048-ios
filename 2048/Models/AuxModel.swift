//
//  AuxModel.swift
//  2048
//
//  Created by Yash Patel on 2/5/19.
//  Copyright © 2019 Yash Patel. All rights reserved.
//

import Foundation


enum MoveDirection {
    case up, down, left, right
}

struct MoveCommand {
    let direction : MoveDirection
    let completion : (Bool) -> ()
    init(d: MoveDirection, c: @escaping (Bool) -> ()){
        direction = d
        completion = c
    }
}

enum MoveOrder {
    case singleMoveOrder(source: Int, destination: Int, value: Int, wasMerge: Bool)
    case doubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}

enum TileObject {
    case empty
    case tile(Int)
}

enum ActionToken {
    case noAction(source: Int, value: Int)
    case move(source: Int, value: Int)
    case singleCombine(source: Int, value: Int)
    case doubleCombine(source: Int, second: Int, value: Int)
    
    func getValue() -> Int {
        switch self {
        case let .noAction(_, v): return v
        case let .move(_, v): return v
        case let .singleCombine(_, v): return v
        case let .doubleCombine(_, _, v): return v
        }
    }
    func getSource() -> Int {
        switch self {
        case let .noAction(s, _): return s
        case let .move(s, _): return s
        case let .singleCombine(s, _): return s
        case let .doubleCombine(s, _, _): return s
        }
    }
}

struct SquareGameboard<T> {
    let dimension : Int
    var boardArray : [T]
    
    init(dimension d: Int, initialValue: T) {
        dimension = d
        boardArray = [T](repeating: initialValue, count: d*d)
    }
    
    subscript(row: Int, col: Int) -> T {
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row*dimension + col]
        }
        set {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row*dimension + col] = newValue
        }
    }
    
    // We mark this function as 'mutating' since it changes its 'parent' struct.
    mutating func setAll(to item: T) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                self[i, j] = item
            }
        }
    }
}
