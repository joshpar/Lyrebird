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
    
    static var sineTable: [LyrebirdFloat] = [LyrebirdFloat](repeating: 0.0, count: sineTableSize)
    
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
    case audio
    case control
    case spectral
    case demand
}

enum LyrebirdUGenInputType {
    case ugen
    case controlScaler
    case initializedScaler
}

enum LyrebirdUGenOutputRange {
    case bipolar
    case unipolar
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
        let newValue = self.floatValue(graph: graph)
        return interpolatedSampleBlock(startValue: previousValue, endValue: newValue)
    }
}


/**
 The base class for all UGens
 */

open class LyrebirdUGen {
    static let zeroedSamples : [LyrebirdFloat] = [LyrebirdFloat](repeating: 0.0, count: Lyrebird.engine.blockSize)
    fileprivate (set) open var rate: LyrebirdUGenRate
    final var samples: [LyrebirdFloat]
    fileprivate (set) open var outputIndexes: [LyrebirdInt] = []
    fileprivate var ready: Bool = false
    var needsCalc: Bool = true
    
    var graph: LyrebirdGraph?
    var sampleOffset: LyrebirdInt = 0
    
    // default to Bipolar
    var outputRange: LyrebirdUGenOutputRange = .bipolar
    
    public init(rate: LyrebirdUGenRate){
        // TODO:: make this work with num outputs
        samples = LyrebirdUGen.zeroedSamples
        self.graph = LyrebirdGraph.currentBuildingGraph
        self.rate = rate
        self.graph?.addChild(child: self)
        let numOutputs = self.numberOfOutputs()
        ready = true
    }
    
    public convenience init(){
        self.init(rate: LyrebirdUGenRate.control)
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
        let run: Bool = super.next(numSamples: numSamples)
        guard run else {
            return run
        }
        ... 
     
     and return true if successful
     */
    
    open func next(numSamples: LyrebirdInt) -> Bool {
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
        return self.calculatedSamples(graph: graph)[0]
    }
}
