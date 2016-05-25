//
//  LyrebirdWire.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/4/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

/**
 Wires are used within Graphs to pass audio data between UGens.
 UGens can accept an array of wires as inputs
 UGens store an array of wires as outputs
 */

public class LyrebirdWire: NSObject {
    
    /**
     The inverse of the blockSize. For wires that need to interpolate between two control values, this provides a scaler
     
     - Warning: a value of -1.0 means no interpolation should be done. It is placed here in the event
     */
    
    internal static var iBlockSize : LyrebirdFloat = -1.0
    
    /**
     The size of a control period.
     
     - Warning: setting this value will cause all wires to be recreated. This is memory intensive and should be saved for initialization only.
     
     */
    
    static var blockSize: LyrebirdInt = 1024 {
        didSet {
            if blockSize > 0 {
                LyrebirdWire.iBlockSize =  1.0 / LyrebirdFloat(blockSize)
                zeroedSamples = [LyrebirdFloat](count: blockSize,
                                                     repeatedValue: 0.0)
                prepareAllWires()
            } else {
                iBlockSize = -1.0
            }
        }
    }
    
    /**
     The total number of interconnect wires
     
     - Warning: This should be set at Engine init time to prevent a large CPU hit with memory allocation
     */
    
    static var numWires: LyrebirdInt = 0
    
    /**
     Holds an array of zeroes that can be used for preparing wires for reuse
     */
    
    static var zeroedSamples: [LyrebirdFloat] = []
    
    /**
     The array of available wires
     */
    
    static var allWires: [LyrebirdWire] = []
    
    /**
     The index of the current wire, which is incremented by the newWire() allocator. Resets to 0
     for each new graph calculation.
     */
    
    static var currentWireIndex: LyrebirdInt = 0
    
    /**
     Called to allocate memory for the wires, and set up the array of wires
     - parameter none:
     - Warning: VERY memory and CPU intensive. Limit use of this method
     */
    
    static func prepareAllWires(){
        if (numWires > 0){
            allWires.removeAll()
            for _: LyrebirdInt in 0 ..< numWires {
                let wire = LyrebirdWire()
                wire.currentSamples = zeroedSamples
                allWires.append(wire)
            }
        }
    }
    
    /**
     Called to reset the wire allocator for a new graph calculation
     - parameter none:
     */
    
    static func prepareForNewGraph(){
        currentWireIndex = 0
    }
    
    /**
     Allocates a new wire for use in a graph.
     - parameter none:
     - Throws: If a new wire is not available, a LyrebirdError is thrown
     */
    
    static func newWire() throws -> LyrebirdWire  {
        if currentWireIndex >= numWires {
            throw LyrebirdError.NotEnoughWires
        }
        let wire = allWires[currentWireIndex]
        currentWireIndex = currentWireIndex + 1
        return wire
    }
    
    /**
     The wires audio samples.
     - Warning: Samples should always be overwritten! Samples are NOT gauranteed to be initialized to zero.
     */
    var currentSamples: [LyrebirdFloat] = LyrebirdWire.zeroedSamples
    
    func createSamplesForControlValues(lastValue: LyrebirdFloat, currentValue: LyrebirdFloat){
        if lastValue != currentValue {
            let step: LyrebirdFloat = (currentValue - lastValue) * LyrebirdWire.iBlockSize
            var start = lastValue
            for idx: LyrebirdInt in 0 ..< LyrebirdWire.blockSize {
                currentSamples[idx] = start
                start = start + step
            }
        } else {
            if (currentSamples[0] != currentSamples[LyrebirdWire.blockSize-1]) ||
                (currentSamples[0] != currentValue) {
                currentSamples = [LyrebirdFloat](count: LyrebirdWire.blockSize,repeatedValue: currentValue)
            }
        }
    }
    
}

