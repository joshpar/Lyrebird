//
//  LyrebirdTypes.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public typealias LyrebirdInt =  Int
public typealias LyrebirdFloat = Double
public typealias LyrebirdKey = String
public typealias LyrebirdFloatClosureBody = (_ graph: LyrebirdGraph?, _ currentPoint: LyrebirdFloat?) -> LyrebirdFloat


public protocol LyrebirdNumber {
    func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat
    func numberValue() -> LyrebirdFloat
    func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat
    func valueAtPoint(point: LyrebirdNumber) -> LyrebirdFloat
}

extension LyrebirdNumber {
    public func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat {
        //var currentPoint = point.numberValue(graph)
        return self.numberValue(graph: graph)
    }
    
    public func valueAtPoint(point: LyrebirdNumber) -> LyrebirdFloat {
        return self.valueAtPoint(graph: nil, point: point)
    }
    
    public func numberValue() -> LyrebirdFloat {
        return self.numberValue(graph: nil)
    }
}

protocol LyrebirdFloatUGenValue {
    
}

public struct LyrebirdFloatClosure {
    public var closure : LyrebirdFloatClosureBody?
    
    public init(closure: @escaping LyrebirdFloatClosureBody){
        self.closure = closure
    }
}

extension LyrebirdFloatClosure : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let float = closure?(graph, nil) ?? 0.0
        let returnValues = [LyrebirdFloat](repeating: LyrebirdFloat(float), count: Lyrebird.engine.blockSize)
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        let float = closure?(graph, nil) ?? 0.0
        return LyrebirdFloat(float)
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        let int = closure?(graph, nil) ?? 0
        return LyrebirdInt(int)
    }
}

extension LyrebirdFloatClosure : LyrebirdFloatUGenValue {
    
}

extension LyrebirdFloatClosure : LyrebirdNumber {
    public func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat {
        let currentPoint = point.numberValue()
        return closure?(graph, currentPoint) ?? 0.0
    }
    
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph: graph)
    }
}

extension LyrebirdInt : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let returnValues = [LyrebirdFloat](repeating: LyrebirdFloat(self), count: Lyrebird.engine.blockSize)
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return LyrebirdFloat(self)
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        return self
    }
}


extension LyrebirdInt : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph: graph)
    }
}

extension LyrebirdInt : LyrebirdFloatUGenValue {
    
}


extension LyrebirdFloat : LyrebirdValidUGenInput {
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        //var selfCopy = round(self)
        return LyrebirdInt(self)
    }

    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let returnValues = [LyrebirdFloat](repeating: self, count: Lyrebird.engine.blockSize)
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self
    }
//    
//    public mutating func intValue(_ graph: LyrebirdGraph?) -> LyrebirdInt {
//        return LyrebirdInt(round(self))
//    }
}

extension LyrebirdFloat : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph: graph)
    }
}

extension LyrebirdFloat : LyrebirdFloatUGenValue {
    
}

// TODO:: right now, accessing a key that doesn't exist returns zeroes. However, once mapped, that key is valid. Do we want this?
extension LyrebirdKey : LyrebirdValidUGenInput {
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.calculatedSamples(graph: graph)
            }
        }
        let returnValues = [LyrebirdFloat](repeating: LyrebirdFloat(0.0), count: Lyrebird.engine.blockSize)
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.floatValue(graph: graph)
            }
        }
        return 0.0
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.intValue(graph: graph)
            }
        }
        return 0
    }
}

extension LyrebirdKey : LyrebirdFloatUGenValue {
    
}

extension LyrebirdKey : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph: graph)
    }
}


/**
 LyrebirdPollable is a class that keeps track of how values can change over time
 Timekeeping is internal to its methods and accessible from currentTime(). With the first time currentTime() or every time start() is called (if allowsRestart is true), the timekeeping begins
 */

open class LyrebirdPollable {
    var startTime: LyrebirdFloat = -1.0
    var currentValue: LyrebirdFloat
    open var allowsRestart: Bool = false
    fileprivate var hasStarted: Bool = false
    
    public required init(currentValue: LyrebirdFloat = 0.0){
        self.currentValue = currentValue
    }
    
    public convenience init(){
        self.init(currentValue: 0.0)
    }
    
    open func currentTime() -> LyrebirdFloat {
        if startTime < 0.0 {
            start()
            return 0.0
        }
        let currentTime = Date.timeIntervalSinceReferenceDate
        return currentTime - startTime
    }
    
    open func start() {
        if !hasStarted || allowsRestart {
            hasStarted = true
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
}

extension LyrebirdPollable : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return currentValue
    }
}

enum LyrebirdError : Error {
    case notEnoughWires
}



