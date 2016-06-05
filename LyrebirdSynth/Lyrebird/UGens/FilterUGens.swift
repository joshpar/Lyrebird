//
//  FilterUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

// out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (b1 * out(i-1))

public class FirstOrderSection : LyrebirdUGen {
    private var a0: LyrebirdValidUGenInput
    private var a1: LyrebirdValidUGenInput
    private var b1: LyrebirdValidUGenInput
    private var input: LyrebirdValidUGenInput
    
    private var lastA0: LyrebirdFloat = 0.0
    private var lastA1: LyrebirdFloat = 0.0
    private var lastB1: LyrebirdFloat = 0.0
    private var input1: LyrebirdFloat = 0.0
    private var output1: LyrebirdFloat = 0.0
    private var wire: LyrebirdWire?
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, a0: LyrebirdValidUGenInput, a1: LyrebirdValidUGenInput, b1: LyrebirdValidUGenInput) {
        self.a0 = a0
        self.a1 = a1
        self.b1 = b1
        self.input = input
        super.init(rate: rate)
        self.lastA0 = self.a0.floatValue(graph)
        self.lastA1 = self.a1.floatValue(graph)
        self.lastB1 = self.b1.floatValue(graph)
        wire = wireForIndex(0)
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, input: 0.0, a0: 0.0, a1: 0.0, b1: 0.0)
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        guard let wire: LyrebirdWire = self.wire else {
            return false
        }
        let inputSamples: [LyrebirdFloat] = input.sampleBlock(graph, previousValue: 0.0)
        var input1: LyrebirdFloat = self.input1
        var output1: LyrebirdFloat = self.output1
        var currentIn: LyrebirdFloat = 0.0
        
        let newA0 = a0.floatValue(graph)
        let newA1 = a1.floatValue(graph)
        let newB1 = b1.floatValue(graph)
        
        // try to avoid the interpolation
        
        if newA0 == lastA0 &&
            newA1 == lastA1 &&
            newB1 == lastB1 {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx]
                output1 = (lastA0 * currentIn) +
                    (lastA1 * input1) +
                    (lastB1 * output1)
                wire.currentSamples[sampleIdx] = output1
                input1 = currentIn
            }
        } else {
            let a0Samps: [LyrebirdFloat] = a0.sampleBlock(graph, previousValue: lastA0)
            let a1Samps: [LyrebirdFloat] = a1.sampleBlock(graph, previousValue: lastA1)
            let b1Samps: [LyrebirdFloat] = b1.sampleBlock(graph, previousValue: lastB1)
            
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx]
                output1 = (a0Samps[sampleIdx] * currentIn) +
                    (a1Samps[sampleIdx] * input1) +
                    (b1Samps[sampleIdx] * output1)
                wire.currentSamples[sampleIdx] = output1
                input1 = currentIn
            }
            lastA0 = a0Samps.last ?? 0.0
            lastA1 = a1Samps.last ?? 0.0
            lastB1 = b1Samps.last ?? 0.0
        }
        self.input1 = input1
        self.output1 = output1
        
        return success
    }
}

// out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (a2 * in(i-2)) + (b1 * out(i-1)) + (b2 * out(i-2))

public class SecondOrderSection : LyrebirdUGen {
    private var a0: LyrebirdValidUGenInput
    private var a1: LyrebirdValidUGenInput
    private var a2: LyrebirdValidUGenInput
    private var b1: LyrebirdValidUGenInput
    private var b2: LyrebirdValidUGenInput
    private var input: LyrebirdValidUGenInput
    
    private var lastA0: LyrebirdFloat = 0.0
    private var lastA1: LyrebirdFloat = 0.0
    private var lastA2: LyrebirdFloat = 0.0
    private var lastB1: LyrebirdFloat = 0.0
    private var lastB2: LyrebirdFloat = 0.0
    private var input1: LyrebirdFloat = 0.0
    private var input2: LyrebirdFloat = 0.0
    private var output1: LyrebirdFloat = 0.0
    private var output2: LyrebirdFloat = 0.0
    private var wire: LyrebirdWire?
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, a0: LyrebirdValidUGenInput, a1: LyrebirdValidUGenInput, a2: LyrebirdValidUGenInput, b1: LyrebirdValidUGenInput, b2: LyrebirdValidUGenInput) {
        self.a0 = a0
        self.a1 = a1
        self.a2 = a2
        self.b1 = b1
        self.b2 = b2
        self.input = input
        super.init(rate: rate)
        self.lastA0 = self.a0.floatValue(graph)
        self.lastA1 = self.a1.floatValue(graph)
        self.lastA2 = self.a2.floatValue(graph)
        self.lastB1 = self.b1.floatValue(graph)
        self.lastB2 = self.b2.floatValue(graph)
        wire = wireForIndex(0)
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, input: 0.0, a0: 0.0, a1: 0.0, a2: 0.0, b1: 0.0, b2: 0.0)
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        guard let wire: LyrebirdWire = self.wire else {
            return false
        }
        let inputSamples: [LyrebirdFloat] = input.sampleBlock(graph, previousValue: 0.0)
        var input1: LyrebirdFloat = self.input1
        var output1: LyrebirdFloat = self.output1
        var input2: LyrebirdFloat = self.input2
        var output2: LyrebirdFloat = self.output2
        var currentIn: LyrebirdFloat = 0.0
        var tmpOutput2: LyrebirdFloat = 0.0
        
        let newA0 = a0.floatValue(graph)
        let newA1 = a1.floatValue(graph)
        let newA2 = a2.floatValue(graph)
        let newB1 = b1.floatValue(graph)
        let newB2 = b2.floatValue(graph)
        
        // try to avoid the interpolation
        
        if newA0 == lastA0 &&
            newA1 == lastA1 &&
            newA2 == lastA2 &&
            newB1 == lastB1 &&
            newB2 == lastB2 {
            
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                tmpOutput2 = output1
                currentIn = inputSamples[sampleIdx]
                output1 = (newA0 * currentIn) +
                    (newA1 * input1) +
                    (newA2 * input2) +
                    (newB1 * output1) +
                    (newB2 * output2)
                wire.currentSamples[sampleIdx] = output1
                input2 = input1
                input1 = currentIn
                output2 = tmpOutput2
            }
        } else {
            let a0Samps: [LyrebirdFloat] = a0.sampleBlock(graph, previousValue: lastA0)
            let a1Samps: [LyrebirdFloat] = a1.sampleBlock(graph, previousValue: lastA1)
            let a2Samps: [LyrebirdFloat] = a2.sampleBlock(graph, previousValue: lastA2)
            let b1Samps: [LyrebirdFloat] = b1.sampleBlock(graph, previousValue: lastB1)
            let b2Samps: [LyrebirdFloat] = b2.sampleBlock(graph, previousValue: lastB2)
            
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                tmpOutput2 = output1
                currentIn = inputSamples[sampleIdx]
                output1 = (a0Samps[sampleIdx] * currentIn) +
                    (a1Samps[sampleIdx] * input1) +
                    (a2Samps[sampleIdx] * input2) +
                    (b1Samps[sampleIdx] * output1) +
                    (b2Samps[sampleIdx] * output2)
                wire.currentSamples[sampleIdx] = output1
                input2 = input1
                input1 = currentIn
                output2 = tmpOutput2
            }
            lastA0 = a0Samps.last ?? 0.0
            lastA1 = a1Samps.last ?? 0.0
            lastA2 = a2Samps.last ?? 0.0
            lastB1 = b1Samps.last ?? 0.0
            lastB2 = b2Samps.last ?? 0.0
        }
        
        self.input1 = input1
        self.output1 = output1
        self.input2 = input2
        self.output2 = output2
        
        return success
    }
}
