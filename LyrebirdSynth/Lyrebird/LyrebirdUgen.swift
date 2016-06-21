//
//  LyrebirdUGen.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/4/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

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
    func needsInterpolation() -> Bool
    func sampleBlock(graph: LyrebirdGraph?, previousValue: LyrebirdFloat) -> [LyrebirdFloat]
}

extension LyrebirdValidUGenInput {
    public func needsInterpolation() -> Bool {
        return true
    }
    
    public func sampleBlock(graph: LyrebirdGraph?, previousValue: LyrebirdFloat) -> [LyrebirdFloat] {
        let newValue = self.floatValue(graph)
        return interpolatedSampleBlock(previousValue, endValue: newValue)
    }
}


/**
 The base class for all UGens
 */

public class LyrebirdUGen {
    
    private (set) public var rate: LyrebirdUGenRate
    final var samples: [LyrebirdFloat]
    private (set) public var outputIndexes: [LyrebirdInt] = []
    private var ready: Bool = false
    var needsCalc: Bool = true
    
    var graph: LyrebirdGraph?
    var sampleOffset: LyrebirdInt = 0
    
    public required init(rate: LyrebirdUGenRate){
        // TODO:: make this work with num outputs
        samples = [LyrebirdFloat](count: LyrebirdEngine.engine.blockSize, repeatedValue: 0.0)
        self.graph = LyrebirdGraph.currentBuildingGraph
        self.rate = rate
        self.graph?.addChild(self)
        // TOOD: my initial assumption is that once a graph is initialized, the same
        // wires will be used. Make sure this is actually the case!
        let numOutputs = self.numberOfOutputs()
        ready = true
    }
    
    public convenience init(){
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
}

extension LyrebirdUGen : LyrebirdValidUGenInput {
    
    public func calculatedSamples(graph: LyrebirdGraph?) -> [[LyrebirdFloat]]{
        var sampleArray: [[LyrebirdFloat]] = []
        sampleArray.append(self.samples)
        return sampleArray
    }
    
    // TODO:: handle this better - right now this grabs the current samples from the 0th wire.
    // there should be a better way to do this
    
    public func floatValue(graph: LyrebirdGraph?) -> LyrebirdFloat {
        
            if let returnValue = samples.last {
                return returnValue
            }
        
        return 0.0
    }
    
    public func intValue(graph: LyrebirdGraph?) -> LyrebirdInt {
        
            if let returnValue = samples.last {
                return LyrebirdInt(round(returnValue))
            }
        
        return 0
    }
    
    public func needsInterpolation() -> Bool {
        return false
    }
    
    public func sampleBlock(graph: LyrebirdGraph?, previousValue: LyrebirdFloat) -> [LyrebirdFloat] {
        return self.calculatedSamples(graph)[0]
    }
}

public protocol UGenStruct {    
    mutating func next(inout buffer: [LyrebirdFloat])
}

public struct TestUGenStruct {
    public var ranGen: LyrebirdRandomNumberGenerator = LyrebirdRandomNumberGenerator()
    public init(){
    }
}

extension TestUGenStruct : UGenStruct {
    public mutating func next(inout buffer: [LyrebirdFloat]){
        for idx in 0 ..< buffer.count {
            buffer[idx] = (ranGen.next() * 2.0) - 1.0
        }
    }
}