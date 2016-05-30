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

/*
public protocol LyrebirdUnaryMathOps : LyrebirdValidUGenInput {
    func midi_hz() -> LyrebirdFloat
    func hz_midi() -> LyrebirdFloat
    func midi_ratio() -> LyrebirdFloat
    func ratio_midi() -> LyrebirdFloat
    func linamp_db() -> LyrebirdFloat
    func db_linamp() -> LyrebirdFloat
}
 */
/*
extension LyrebirdUnaryMathOps {
    public func midi_hz() -> LyrebirdFloat {
        return 440.0 * pow(2.0, (self.floatValue(nil) - 69.0) * 0.083333333333)
    }
    
    public func hz_midi() -> LyrebirdFloat {
        return (log2(self.floatValue(nil) * 0.0022727272727) * 12.0) + 69.0;
    }
    
    public func midi_ratio() -> LyrebirdFloat {
        return pow(2.0, self.floatValue(nil) * 0.083333333333);
    }
    
    public func ratio_midi() -> LyrebirdFloat {
        return 12.0 * log2(self.floatValue(nil))
    }
    
    public func linamp_db() -> LyrebirdFloat {
        return log10(self.floatValue(nil)) * 20.0
    }
    
    public func db_linamp() -> LyrebirdFloat {
        return  pow(10.0, self.floatValue(nil) * 0.05);
    }
}
*/



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

/*
extension LyrebirdInt : LyrebirdUnaryMathOps {
    
}
*/

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

/*
extension LyrebirdFloat : LyrebirdUnaryMathOps {
    
}
 */

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

// MARK: unary math functions

public func db_linamp(db: LyrebirdFloat) -> LyrebirdFloat {
    return pow(10.0, db * 0.05)
}

public func linamp_db(linamp: LyrebirdFloat) -> LyrebirdFloat {
    return log10(linamp) * 20.0
}

public func keynum_hz(keynum: LyrebirdFloat) -> LyrebirdFloat {
    return 440.0 * pow(2.0, (keynum - 69.0) * 0.08333333333333333333333333)
}

public func hz_keynum(hz: LyrebirdFloat) -> LyrebirdFloat {
    return (log2(hz * 0.002272727272727272727272727) * 12.0) + 69.0;
}

public func midi_ratio(midi: LyrebirdFloat) -> LyrebirdFloat {
    return pow(2.0, midi * 0.08333333333333333333333333);
}

public func ratio_midi(ratio: LyrebirdFloat) -> LyrebirdFloat {
    return 12.0 * log2(ratio)
}

public func reciprocal(value: LyrebirdFloat) -> LyrebirdFloat {
    return 1.0 / value
}

// MARK: functions to work on audio values and signals (retain sign for negative values)

public func sig_sqrt(value: LyrebirdFloat) -> LyrebirdFloat {
    if value >= 0.0 {
        return sqrt(value)
    } else {
        return -sqrt(-value)
    }
}