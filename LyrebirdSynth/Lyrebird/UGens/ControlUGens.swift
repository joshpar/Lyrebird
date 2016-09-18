//
//  ControlUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/11/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

/**
 Control rate interpolated values
 
 use the currentValue property to set new values
 for UGens that only need a single value, the currentValue property can also be used
 */

open class Control: LyrebirdUGen {
    /// ---
    /// The current value of the control
    ///
    /// This is the value that should be updated
    
    var currentValue: LyrebirdValidUGenInput = 0.0
    
    /// ---
    /// holds the last value set
    ///
    /// only updated AFTER a control period interpolating to the currentValue has been run
    
    fileprivate var previousValue: LyrebirdFloat = 0.0
    
    /**
     init method for Control values that aren't 0.0
     
     - parameter rate: Lyrebird UGen rate - should be control
     - parameter currentValue: The initial value for the control's output
     */
    
    public required init(rate: LyrebirdUGenRate, currentValue: LyrebirdValidUGenInput){
        super.init(rate: rate)
        self.currentValue = currentValue
        self.previousValue = currentValue.floatValue(graph: graph)
    }
    
    /**
     overridden next function for LyrebirdControlUGen
     
     - parameter numSamples: the number of samples to calculate
     
     fills wire with interpolated data between last value and current value
     if these are the same, an output buffer of the same value is returned
     */
    
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let run: Bool = super.next(numSamples: numSamples)
        guard run else {
            return run
        }
        let valueIn: LyrebirdFloat = currentValue.floatValue(graph: graph)
        
        let success: Bool = self.next(numSamples: numSamples, currentValueIn: valueIn)
        return success
    }
    
    fileprivate func next(numSamples: LyrebirdInt, currentValueIn: LyrebirdFloat) -> Bool {
            // optimization - avoid addition in the loop, fill in a control
            // period of this value ...
            if previousValue == currentValueIn {
                for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                    samples[sampleIdx] = currentValueIn
                }
            } else {
                let step: LyrebirdFloat = calcSlope(startValue: previousValue, endValue: currentValueIn)
                var curSample: LyrebirdFloat = previousValue
                // end at currentValue - last block lands at lastValue, step on from there
                for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                    curSample = curSample + step
                    samples[sampleIdx] = curSample
                }
            }
            previousValue = currentValueIn
        return true
    }
}


/*
 
 public override func next(numSamples: LyrebirdInt) -> Bool {
 let run: Bool = super.next(numSamples: numSamples)
 guard run else {
 return run
 }
 if let wire: LyrebirdWire = wireForIndex(0){
 // optimization - avoid addition in the loop, fill in a control
 // period of this value ...
 if lastValue == currentValue {
 for sampleIdx: LyrebirdInt in 0 ..< numSamples {
 wire.currentSamples[sampleIdx] = currentValue
 }
 } else {
 let step: LyrebirdFloat = LyrebirdWire.iBlockSize * (currentValue - lastValue)
 var curSample: LyrebirdFloat = lastValue
 // end at currentValue - last block lands at lastValue, step on from there
 for sampleIdx: LyrebirdInt in 0 ..< numSamples {
 curSample = curSample + step
 wire.currentSamples[sampleIdx] = curSample
 }
 }
 }
 lastValue = currentValue
 return true
 }
 // for multi out UGen
 
 public override func next(numSamples: LyrebirdInt) -> Bool {
 let run: Bool = super.next(numSamples: numSamples)
 guard run else {
 return run
 }
 if let wire: LyrebirdWire = wireForIndex(0){
 // optimization - avoid addition in the loop, fill in a control
 // period of this value ...
 if lastValue == currentValue {
 for sampleIdx: LyrebirdInt in 0 ..< numSamples {
 wire.currentSamples[sampleIdx] = currentValue
 }
 } else {
 let step: LyrebirdFloat = LyrebirdWire.iBlockSize * (currentValue - lastValue)
 var curSample: LyrebirdFloat = lastValue
 // end at currentValue - last block lands at lastValue, step on from there
 for sampleIdx: LyrebirdInt in 0 ..< numSamples {
 curSample = curSample + step
 wire.currentSamples[sampleIdx] = curSample
 }
 }
 }
 lastValue = currentValue
 return true
 }
 
 */
