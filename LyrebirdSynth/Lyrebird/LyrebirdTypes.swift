//
//  LyrebirdTypes.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public typealias LyrebirdInt =  Int
public typealias LyrebirdFloat = Double
public typealias LyrebirdKey = String
public typealias LyrebirdFloatClosureBody = (graph: LyrebirdGraph?) -> LyrebirdFloat

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
        let float = closure?(graph: graph) ?? 0.0
        let returnValues = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: LyrebirdFloat(float))
        return [returnValues]
    }
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        let float = closure?(graph: graph) ?? 0.0
        return LyrebirdFloat(float)
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        let int = closure?(graph: graph) ?? 0
        return LyrebirdInt(int)
    }
}

extension LyrebirdFloatClosure : LyrebirdFloatUGenValue {
    
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
        return [LyrebirdWire.zeroedSamples]
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

enum LyrebirdError : ErrorType {
    case NotEnoughWires
}