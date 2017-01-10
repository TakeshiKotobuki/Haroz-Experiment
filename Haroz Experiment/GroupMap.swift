//
//  GroupMap.swift
//  Haroz Experiment
//
//  Created by 寿 斌 on 24/10/2016.
//  Copyright © 2016 Engyokun. All rights reserved.
//

import UIKit

class GroupMap: NSObject {
    var long: Int
    var colors: Int
    
    var setOrder: [SetOrder] = []
    
    struct CGEdge {
        var x: Int
        var y: Int
    }
    
    enum PositionKind: Int {
        case corner = 0
        case edge = 1
        case center = 2
    }
    
    struct SetOrder {
        var type: PositionKind
        var kind: Int
    }
    
    func getIndexFromPoints(A pointA: CGEdge, B pointB: CGEdge) -> [Int] {
        var temp: [Int] = []
        
        for index in min(pointA.y, pointB.y)...max(pointA.y, pointB.y) {
            for row in min(pointA.x, pointB.x)...max(pointA.x, pointB.x) {
                temp.append(row + index * long)
            }
        }
        return temp
    }
    
    func getRandPosition(_ order: Int, withSquare square: CGEdge) -> [CGEdge] {
        let tempKind = setOrder[order]
        switch tempKind.type {
        case .corner:
            return cornerPosition(square, kindNumber: tempKind.kind)
        case .edge:
            return edgePosition(square, kindNumber: tempKind.kind)
        case .center:
            return centerPosition(square)
        }
    }
    
    func cornerPosition(_ square: CGEdge, kindNumber pID: Int) -> [CGEdge] {
        switch pID {
        case 0:
            return [CGEdge.init(x: 0, y: 0), square]
        case 1:
            return [CGEdge.init(x: long - 1, y: 0), CGEdge.init(x: long - 1 - square.x, y: square.y)]
        case 2:
            return [CGEdge.init(x: long - 1, y: long - 1), CGEdge.init(x: long - 1 - square.x, y: long - 1 - square.y)]
        case 3:
            return [CGEdge.init(x: 0, y: long - 1), CGEdge.init(x: square.x, y: long - 1 - square.y)]
        default:
            return [CGEdge.init(x: 0, y: 0), CGEdge.init(x: 0, y: 0)]
        }
    }
    
    func edgePosition(_ square: CGEdge, kindNumber pID: Int) -> [CGEdge] {
        let a = Int(arc4random_uniform(UInt32(6 - square.x))) + 1
        let b = Int(arc4random_uniform(UInt32(6 - square.y))) + 1
        
        switch pID {
        case 0:
            return [CGEdge.init(x: a, y: 0), CGEdge.init(x: a + square.x, y: square.y)]
        case 1:
            return [CGEdge.init(x: long - 1, y: b), CGEdge.init(x: long - 1 - square.x, y: b + square.y)]
        case 2:
            return [CGEdge.init(x: a, y: b), CGEdge.init(x: a + square.x, y: long - 1)]
        case 3:
            return [CGEdge.init(x: 0, y: b), CGEdge.init(x: square.x, y: b + square.y)]
        default:
            return [CGEdge.init(x: 0, y: 0), CGEdge.init(x: 0, y: 0)]
        }
    }
    
    func centerPosition(_ square: CGEdge) -> [CGEdge] {
        let a = Int(arc4random_uniform(UInt32(6 - square.x))) + 1
        let b = Int(arc4random_uniform(UInt32(6 - square.y))) + 1
        return [CGEdge.init(x: a, y: b), CGEdge.init(x: a + square.x, y: b + square.y)]
    }
    
    func getRect() -> CGEdge {
        let x = Int(arc4random_uniform(UInt32(4))) + 1
        let y = Int(arc4random_uniform(UInt32(4))) + 1
        
        let square: CGEdge = CGEdge.init(x: x, y: y)
        
        return square
    }
    
    func sortSquares(_ squares: [CGEdge]) -> [CGEdge] {
        return squares.sorted(by: {$0.x * $0.y > $1.x * $1.y})
    }
    
    func creatSquares(_ kinds: Int) -> [CGEdge] {
        var squares: [CGEdge] = []
        for _ in 0..<kinds - 1 {
            squares.append(getRect())
        }
        return squares
    }
    
    func planMap(_ squares: [CGEdge]) -> [Int] {
        var tempMap = Array.init(repeating: 0, count: long * long)
        for index in 0...colors - 1 {
            if index == 0{
                continue
            }
            let tempSquarePosition = getRandPosition(index - 1, withSquare: squares[index - 1])
            let indexes = getIndexFromPoints(A: tempSquarePosition[0], B: tempSquarePosition[1])
            NSLog(indexes.description)
            for temp in indexes {
                tempMap[temp] = index
            }
        }
        return tempMap
    }
    
    func creatOrder() -> [SetOrder] {
        var order: [SetOrder] = []
        switch colors {
        case 2, 3:
            let temp = getCornerOrder()
            for index in 0..<colors - 1 {
                order.append(SetOrder.init(type: PositionKind.corner, kind: temp[index]))
            }
        case 4, 5:
            var temp = getCornerOrder()
            for index in 0..<2 {
                order.append(SetOrder.init(type: PositionKind.corner, kind: temp[index]))
            }
            temp = getEdgeOrder()
            for index in 0..<colors - 3 {
                order.append(SetOrder.init(type: PositionKind.edge, kind: temp[index]))
            }
        case 6, 7:
            var temp = getCornerOrder()
            for index in 0..<3 {
                order.append(SetOrder.init(type: PositionKind.corner, kind: temp[index]))
            }
            temp = getEdgeOrder()
            for index in 0..<colors - 5 {
                order.append(SetOrder.init(type: PositionKind.edge, kind: temp[index]))
            }
            order.append(SetOrder.init(type: PositionKind.center, kind: 0))
        default:
            return []
        }
        return order
    }
    
    func getCornerOrder() -> [Int] {
        let start = Int(arc4random_uniform(UInt32(4)))
        let way = Int(arc4random_uniform(UInt32(2)))
        var temp: [Int] = []
        for index in 0..<4 {
            temp.append((way == 0 ? start + index: start - index + 4) % 4)
        }
        return temp
    }
    
    func getEdgeOrder() -> [Int] {
        return getCornerOrder()
    }
    
    
    init(_ length: Int, inType type: Int) {
        long = length
        colors = type
    }
    func creatMap() -> [Int] {
        var squares = creatSquares(colors)
        squares = sortSquares(squares)
        setOrder = creatOrder()
        
        return planMap(squares)
    }
}
