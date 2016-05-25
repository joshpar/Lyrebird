//
//  LyrebirdUGen.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/4/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

/**
 Holds basic preallocated data that all UGens can access.
 */
class LyrebirdUGenInterface {
    
    /// ---
    /// number of samples in sine table
    
    static var sineTableSize: LyrebirdInt = 32768
    
    static var iSineTableSize: LyrebirdFloat =  1.0 / 32768.0
    
    /// ---
    /// for bit masking an index into the table
    
    static var sineTableMask: LyrebirdInt = sineTableSize - 1
    
    /// ---
    /// the table holding a single cycle of a sine wave
    
    static var sineTable: [LyrebirdFloat] = [LyrebirdFloat](count: sineTableSize, repeatedValue: 0.0)
    
    /**
     Initializes all memory for the Interface
     
     - parameters none:
     */
    
    static func initInterface(){
        let oneOverTableSize: LyrebirdFloat = 1.0 / LyrebirdFloat(sineTableSize)
        for idx: Int in 0 ..< sineTableSize {
            let val = LyrebirdFloat(idx) * oneOverTableSize * M_TWOPI
            sineTable[idx] = sin(val)
        }
    }
}

/**
 each UGen should be able to run at a specified rate.
 Audio calculates samples at the audio rate
 Control calculates one sample per control period
 Spectral has a rate at an integer multiple of the control rate
 */

public enum LyrebirdUGenRate {
    case Audio
    case Control
    case Spectral
    case Demand
}

enum LyrebirdUGenInputType {
    case UGen
    case ControlScaler
    case InitializedScaler
}

public protocol LyrebirdValidUGenInput {
    func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]]
    func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat
    func intValue(graph: LyrebirdGraph?) -> LyrebirdInt
}

/**
 The base class for all UGens
 */

public class LyrebirdUGen: NSObject {
    
    private (set) public var rate: LyrebirdUGenRate
    private (set) public var outputWires: [LyrebirdWire] = []
    private (set) public var outputIndexes: [LyrebirdInt] = []
    private var ready: Bool = false
    var needsCalc: Bool = true
    
    var graph: LyrebirdGraph?
    var sampleOffset: LyrebirdInt = 0
    private var muls: [LyrebirdValidUGenInput] = []
    private var adds: [LyrebirdValidUGenInput] = []
    
    public required init(rate: LyrebirdUGenRate){
        self.graph = LyrebirdGraph.currentBuildingGraph
        self.rate = rate
        super.init()
        self.graph?.addChild(self)
        // TOOD: my initial assumption is that once a graph is initialized, the same
        // wires will be used. Make sure this is actually the case!
        let numOutputs = self.numberOfOutputs()
        for index: LyrebirdInt in 0 ..< numOutputs {
            do {
                let wire = try LyrebirdWire.newWire()
                outputWires.append(wire)
                outputIndexes.append(index)
            } catch LyrebirdError.NotEnoughWires {
                print("Output wire couldn't be allocated - UGen init failed")
                return
            } catch _ {
                print("Output wire couldn't be allocated - UGen init failed")
                return
            }
        }
        ready = true
    }
    
    public override convenience init(){
        self.init(rate: LyrebirdUGenRate.Control)
    }
    
    /**
     Tells the Engine the number of outputs to expect from a UGen
     
     - parameter none:
     
     - Returns: an Integer. 1 is the base return, override in your UGen if more are returned
     
     If your UGen only outputs one, you may access your wire with outputWires[0]
     - Warning: If you override this method, your next function MUST check for the correct output wires!!!
     */
    
    func numberOfOutputs() -> LyrebirdInt {
        return 1
    }
    
    /**
     The default next function.
     
     - parameter numSamples: the number of samples to caluclate
     
     - Return: Bool for whether or not to continue calculation
     - Warning: in your implementation, do not call super.next up to the base UGen class. This is here to help developers realize that their method may not be implemented.
     
     - Warning: Your next function must return immediately if 'super.next' returns false!!!
     
     all subclassed next functions should begin with:
     
     public override func next(numSamples: LyrebirdInt) -> Bool {
        let run: Bool = super.next(numSamples)
        guard run else {
            return run
        }
        ... 
     
     and return true if successful
     */
    
    public func next(numSamples: LyrebirdInt) -> Bool {
        guard ready else {
            return false
        }
        guard needsCalc else {
            return false
        }
        needsCalc = false
        return true
    }
    
    /**
     if available, returns the wire for writing to
     
     - parameter index: theh index to return - for most UGens that output 1 channel, this is will be 0
     
     - Returns: nil or a valid LyrebirdWire
     
     */
    
    internal func wireForIndex(index: LyrebirdInt) -> LyrebirdWire? {
        if index < numberOfOutputs(){
            return outputWires[index]
        }
        return nil
    }
    
    func applyOperators(){
        for mul in self.muls {
            mulOp(mul)
        }
        for add in self.adds {
            addOp(add)
        }
    }
}

extension LyrebirdUGen : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]]{
        var samples: [[LyrebirdFloat]] = []
        for wire: LyrebirdWire in outputWires {
            samples.append(wire.currentSamples)
        }
        return samples
    }
    
    // TODO:: handle this better - right now this grabs the current samples from the 0th wire.
    // there should be a better way to do this
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        if( outputWires.count > 0){
            let output = outputWires[0]
            let numSamples = output.currentSamples.count
            if let returnValue = output.currentSamples.last {
                return returnValue
            }
        }
        return 0.0
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        if( outputWires.count > 0){
            let output = outputWires[0]
            if let returnValue = output.currentSamples.last {
                return LyrebirdInt(round(returnValue))
            }
        }
        return 0
    }
}


// math support
// Change this to return a new Instance of a MathOPUgen

public func * (lhs: LyrebirdUGen, rhs: LyrebirdUGen) -> LyrebirdUGen {
    lhs.mul(rhs)
    return lhs
}

public func * (lhs: LyrebirdUGen, rhs: LyrebirdValidUGenInput) -> LyrebirdUGen {
    lhs.mul(rhs)
    return lhs
}

public func * (lhs: LyrebirdValidUGenInput, rhs: LyrebirdUGen) -> LyrebirdUGen {
    rhs.mul(lhs)
    return rhs
}

public func + (lhs: LyrebirdUGen, rhs: LyrebirdUGen) -> LyrebirdUGen {
    lhs.add(rhs)
    return lhs
}

public func + (lhs: LyrebirdUGen, rhs: LyrebirdValidUGenInput) -> LyrebirdUGen {
    lhs.add(rhs)
    return lhs
}

public func + (lhs: LyrebirdValidUGenInput, rhs: LyrebirdUGen) -> LyrebirdUGen {
    rhs.add(lhs)
    return rhs
}

extension LyrebirdUGen {
    
    func mul(newMul: LyrebirdValidUGenInput){
        self.muls.append(newMul)
    }
    
    func mulOp(value: LyrebirdValidUGenInput){
        let valueSamples: [LyrebirdFloat] = value.calculatedSamples(self.graph)[0]
        var selfSamples: [LyrebirdFloat] = self.outputWires[0].currentSamples
        for (index, currentSampleValue) in selfSamples.enumerate() {
            selfSamples[index] = currentSampleValue * valueSamples[index]
        }
        self.outputWires[0].currentSamples = selfSamples
    }
    
    func add(newAdd: LyrebirdValidUGenInput){
        self.adds.append(newAdd)
    }
    
    func addOp(value: LyrebirdValidUGenInput){
        let valueSamples: [LyrebirdFloat] = value.calculatedSamples(self.graph)[0]
        var selfSamples: [LyrebirdFloat] = self.outputWires[0].currentSamples
        for (index, currentSampleValue) in selfSamples.enumerate() {
            selfSamples[index] = currentSampleValue + valueSamples[index]
        }
        self.outputWires[0].currentSamples = selfSamples
    }

}
