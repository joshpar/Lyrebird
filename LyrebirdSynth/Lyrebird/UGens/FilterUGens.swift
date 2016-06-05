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
    private var out1: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, a0: LyrebirdValidUGenInput, a1: LyrebirdValidUGenInput, b1: LyrebirdValidUGenInput) {
        self.a0 = a0
        self.a1 = a1
        self.b1 = b1
        self.input = input
        super.init(rate: rate)
        self.lastA0 = self.a0.floatValue(graph)
        self.lastA1 = self.a1.floatValue(graph)
        self.lastB1 = self.b1.floatValue(graph)
        
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, input: 0.0, a0: 0.0, a1: 0.0, b1: 0.0)
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        guard let wire: LyrebirdWire = wireForIndex(0) else {
            return false
        }
        guard let inputSamples: [LyrebirdFloat] = self.input.calculatedSamples(graph)[0] else {
            return false
        }
        
        let a0Samps: [LyrebirdFloat] = a0.sampleBlock(graph, lastValue: lastA0)
        let a1Samps: [LyrebirdFloat] = a1.sampleBlock(graph, lastValue: lastA1)
        let b1Samps: [LyrebirdFloat] = b1.sampleBlock(graph, lastValue: lastB1)
        
        var lastIn: LyrebirdFloat = input1
        var lastOut: LyrebirdFloat = out1
        var currentIn: LyrebirdFloat = 0.0
        var input = wire.currentSamples
        
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            currentIn = inputSamples[sampleIdx]
            lastOut = (a0Samps[sampleIdx] * currentIn) + (a1Samps[sampleIdx] * lastIn) + (a1Samps[sampleIdx] * lastOut)
            wire.currentSamples[sampleIdx] = lastOut
            lastIn = currentIn
        }
        
        input1 = lastIn
        out1 = lastOut
        lastA0 = a0Samps.last!
        lastA1 = a1Samps.last!
        lastB1 = b1Samps.last!
        
        return success
    }
    
    
}
