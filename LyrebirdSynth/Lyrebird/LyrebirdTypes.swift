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
public typealias LyrebirdFloatClosureBody = (graph: LyrebirdGraph?, currentPoint: LyrebirdFloat?) -> LyrebirdFloat


public protocol LyrebirdNumber {
    func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat
    func numberValue() -> LyrebirdFloat
    func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat
    func valueAtPoint(point: LyrebirdNumber) -> LyrebirdFloat
}

extension LyrebirdNumber {
    public func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat {
        //var currentPoint = point.numberValue(graph)
        return self.numberValue(graph)
    }
    
    public func valueAtPoint(point: LyrebirdNumber) -> LyrebirdFloat {
        return self.valueAtPoint(nil, point: point)
    }
    
    public func numberValue() -> LyrebirdFloat {
        return self.numberValue(nil)
    }
}

protocol LyrebirdFloatUGenValue {
    
}

public struct LyrebirdFloatClosure {
    public var closure : LyrebirdFloatClosureBody?
    
    public init(closure: LyrebirdFloatClosureBody){
        self.closure = closure
    }
}

extension LyrebirdFloatClosure : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let float = closure?(graph: graph, currentPoint: nil) ?? 0.0
        let returnValues = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: LyrebirdFloat(float))
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        let float = closure?(graph: graph, currentPoint: nil) ?? 0.0
        return LyrebirdFloat(float)
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        let int = closure?(graph: graph, currentPoint: nil) ?? 0
        return LyrebirdInt(int)
    }
}

extension LyrebirdFloatClosure : LyrebirdFloatUGenValue {
    
}

extension LyrebirdFloatClosure : LyrebirdNumber {
    public func valueAtPoint(graph: LyrebirdGraph?, point: LyrebirdNumber) -> LyrebirdFloat {
        var currentPoint = point.numberValue()
        return closure?(graph: graph, currentPoint: currentPoint) ?? 0.0
    }
    
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph)
    }
}

extension LyrebirdInt : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let returnValues = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: LyrebirdFloat(self))
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
        return self.floatValue(graph)
    }
}

extension LyrebirdInt : LyrebirdFloatUGenValue {
    
}


extension LyrebirdFloat : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        let returnValues = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: self)
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        return LyrebirdInt(round(self))
    }
}

extension LyrebirdFloat : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph)
    }
}

extension LyrebirdFloat : LyrebirdFloatUGenValue {
    
}

// TODO:: right now, accessing a key that doesn't exist returns zeroes. However, once mapped, that key is valid. Do we want this?
extension LyrebirdKey : LyrebirdValidUGenInput {
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]] {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.calculatedSamples(graph)
            }
        }
        let returnValues = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: LyrebirdFloat(0.0))
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.floatValue(graph)
            }
        }
        return 0.0
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        if let graph: LyrebirdGraph = graph {
            if let parameter = graph.parameters[self] {
                return parameter.intValue(graph)
            }
        }
        return 0
    }
}

extension LyrebirdKey : LyrebirdFloatUGenValue {
    
}

extension LyrebirdKey : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return self.floatValue(graph)
    }
}


/**
 LyrebirdPollable is a class that keeps track of how values can change over time
 Timekeeping is internal to its methods and accessible from currentTime(). With the first time currentTime() or every time start() is called (if allowsRestart is true), the timekeeping begins
 */

public class LyrebirdPollable {
    var startTime: LyrebirdFloat = -1.0
    var currentValue: LyrebirdFloat
    public var allowsRestart: Bool = false
    private var hasStarted: Bool = false
    
    public required init(currentValue: LyrebirdFloat = 0.0){
        self.currentValue = currentValue
    }
    
    public convenience init(){
        self.init(currentValue: 0.0)
    }
    
    public func currentTime() -> LyrebirdFloat {
        if startTime < 0.0 {
            start()
            return 0.0
        }
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        return currentTime - startTime
    }
    
    public func start() {
        if !hasStarted || allowsRestart {
            hasStarted = true
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
}

extension LyrebirdPollable : LyrebirdNumber {
    public func numberValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        return currentValue
    }
}

enum LyrebirdError : ErrorType {
    case NotEnoughWires
}



