//
//  FilterUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//


// out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (b1 * out(i-1))

public final class FirstOrderSection : LyrebirdUGen {
    fileprivate var a0: LyrebirdValidUGenInput
    fileprivate var a1: LyrebirdValidUGenInput
    fileprivate var b1: LyrebirdValidUGenInput
    fileprivate var input: LyrebirdValidUGenInput
    
    fileprivate var lastA0: LyrebirdFloat = 0.0
    fileprivate var lastA1: LyrebirdFloat = 0.0
    fileprivate var lastB1: LyrebirdFloat = 0.0
    fileprivate var input1: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, a0: LyrebirdValidUGenInput, a1: LyrebirdValidUGenInput, b1: LyrebirdValidUGenInput) {
        self.a0 = a0
        self.a1 = a1
        self.b1 = b1
        self.input = input
        super.init(rate: rate)
        self.lastA0 = self.a0.floatValue(graph: graph)
        self.lastA1 = self.a1.floatValue(graph: graph)
        self.lastB1 = self.b1.floatValue(graph: graph)
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        let inputSamples: [LyrebirdFloat] = input.sampleBlock(graph: graph, previousValue: 0.0)
        var input1: LyrebirdFloat = self.input1
        var currentIn: LyrebirdFloat = 0.0
        
        let newA0 = a0.floatValue(graph: graph)
        let newA1 = a1.floatValue(graph: graph)
        let newB1 = b1.floatValue(graph: graph)
        
        // try to avoid the interpolation
        
        if newA0 == lastA0 &&
            newA1 == lastA1 &&
            newB1 == lastB1 {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx]  +
                    (lastB1 * input1)
                samples[sampleIdx] = (lastA0 * currentIn) +
                    (lastA1 * input1)
                input1 = currentIn
            }
        } else {
            let a0Samps: [LyrebirdFloat] = a0.sampleBlock(graph: graph, previousValue: lastA0)
            let a1Samps: [LyrebirdFloat] = a1.sampleBlock(graph: graph, previousValue: lastA1)
            let b1Samps: [LyrebirdFloat] = b1.sampleBlock(graph: graph, previousValue: lastB1)
            
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx] +
                    (b1Samps[sampleIdx] * input1)
                samples[sampleIdx] = (a0Samps[sampleIdx] * currentIn) +
                    (a1Samps[sampleIdx] * input1)
                input1 = currentIn
            }
            lastA0 = a0Samps.last ?? 0.0
            lastA1 = a1Samps.last ?? 0.0
            lastB1 = b1Samps.last ?? 0.0
        }
        self.input1 = input1
        
        return success
    }
}

// out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (a2 * in(i-2)) + (b1 * out(i-1)) + (b2 * out(i-2))

public final class SecondOrderSection : LyrebirdUGen {
    fileprivate var a0: LyrebirdValidUGenInput
    fileprivate var a1: LyrebirdValidUGenInput
    fileprivate var a2: LyrebirdValidUGenInput
    fileprivate var b1: LyrebirdValidUGenInput
    fileprivate var b2: LyrebirdValidUGenInput
    fileprivate var input: LyrebirdValidUGenInput
    
    fileprivate var lastA0: LyrebirdFloat = 0.0
    fileprivate var lastA1: LyrebirdFloat = 0.0
    fileprivate var lastA2: LyrebirdFloat = 0.0
    fileprivate var lastB1: LyrebirdFloat = 0.0
    fileprivate var lastB2: LyrebirdFloat = 0.0
    fileprivate var input1: LyrebirdFloat = 0.0
    fileprivate var input2: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, a0: LyrebirdValidUGenInput, a1: LyrebirdValidUGenInput, a2: LyrebirdValidUGenInput, b1: LyrebirdValidUGenInput, b2: LyrebirdValidUGenInput) {
        self.a0 = a0
        self.a1 = a1
        self.a2 = a2
        self.b1 = b1
        self.b2 = b2
        self.input = input
        super.init(rate: rate)
        self.lastA0 = self.a0.floatValue(graph: graph)
        self.lastA1 = self.a1.floatValue(graph: graph)
        self.lastA2 = self.a2.floatValue(graph: graph)
        self.lastB1 = self.b1.floatValue(graph: graph)
        self.lastB2 = self.b2.floatValue(graph: graph)
    }

    override public final func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        let inputSamples: [LyrebirdFloat] = input.sampleBlock(graph: graph, previousValue: 0.0)
        var input1: LyrebirdFloat = self.input1
        var input2: LyrebirdFloat = self.input2
        var currentIn: LyrebirdFloat = 0.0
        
        let newA0 = a0.floatValue(graph: graph)
        let newA1 = a1.floatValue(graph: graph)
        let newA2 = a2.floatValue(graph: graph)
        let newB1 = b1.floatValue(graph: graph)
        let newB2 = b2.floatValue(graph: graph)
        // try to avoid the interpolation
        
        if (newA0 == lastA0) &&
            (newA1 == lastA1) &&
            (newA2 == lastA2) &&
            (newB1 == lastB1) &&
            (newB2 == lastB2) {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx] +
                    (newB1 * input1) +
                    (newB2 * input2)
                samples[sampleIdx] = (newA0 * currentIn) +
                    (newA1 * input1) +
                    (newA2 * input2)
                input2 = input1
                input1 = currentIn
            }
        } else {
            let a0Samps: [LyrebirdFloat] = a0.sampleBlock(graph: graph, previousValue: lastA0)
            let a1Samps: [LyrebirdFloat] = a1.sampleBlock(graph: graph, previousValue: lastA1)
            let a2Samps: [LyrebirdFloat] = a2.sampleBlock(graph: graph, previousValue: lastA2)
            let b1Samps: [LyrebirdFloat] = b1.sampleBlock(graph: graph, previousValue: lastB1)
            let b2Samps: [LyrebirdFloat] = b2.sampleBlock(graph: graph, previousValue: lastB2)
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentIn = inputSamples[sampleIdx]  +
                    (b1Samps[sampleIdx] * input1) +
                    (b2Samps[sampleIdx] * input2)
                samples[sampleIdx] = (a0Samps[sampleIdx] * currentIn) +
                    (a1Samps[sampleIdx] * input1) +
                    (a2Samps[sampleIdx] * input2)
                input2 = input1
                input1 = currentIn
            }
            lastA0 = a0Samps.last ?? 0.0
            lastA1 = a1Samps.last ?? 0.0
            lastA2 = a2Samps.last ?? 0.0
            lastB1 = b1Samps.last ?? 0.0
            lastB2 = b2Samps.last ?? 0.0
        }
        self.input1 = input1
        self.input2 = input2
        return success
    }
}




/**
 Bristow-Johnson SOS Cookbook
 */

open class FliterRBJ : LyrebirdUGen {
    internal var input: LyrebirdValidUGenInput
    internal var sos: SecondOrderSection?
    internal var a0: LyrebirdValidUGenInput = 0.0
    internal var a1: LyrebirdValidUGenInput = 0.0
    internal var a2: LyrebirdValidUGenInput = 0.0
    internal var b1: LyrebirdValidUGenInput = 0.0
    internal var b2: LyrebirdValidUGenInput = 0.0
    
    public init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput){
        self.input = input
        super.init(rate: rate)
        calculateCoefs()
        self.sos = SecondOrderSection(rate: rate, input: self.input, a0: self.a0, a1: self.a1, a2: self.a2, b1: self.b1, b2: self.b2)

    }
    
    internal func calculateCoefs(){
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        calculateCoefs()
        if let sos = self.sos {
            self.samples = sos.samples
        }
        return success
    }
    
}

public final class FilterRBJBandPass : FliterRBJ {
    fileprivate var freq: LyrebirdValidUGenInput
    fileprivate var bandwidth: LyrebirdValidUGenInput
    fileprivate var lastFreq: LyrebirdFloat = 0.0
    fileprivate var lastBandwidth: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, freq: LyrebirdValidUGenInput, bandwidth: LyrebirdValidUGenInput) {
        self.freq = freq
        self.bandwidth = bandwidth
        super.init(rate: rate, input: input)
        self.lastFreq = freq.floatValue(graph: graph)
        self.lastBandwidth = bandwidth.floatValue(graph: graph)
    }
    
    override internal final func calculateCoefs(){
        super.calculateCoefs()
        let curFreq = freq.floatValue(graph: graph)
        let curBandwidth = bandwidth.floatValue(graph: graph)
        if curFreq > 0.0 {
            if (curFreq != lastFreq) ||
                (curBandwidth != lastBandwidth) {
                let sampleRate  = Lyrebird.engine.sampleRate
                let sampleDur = Lyrebird.engine.iSampleRate
                let w0 = M_TWOPI * freq.floatValue(graph: graph) * sampleDur
                let sin_w0 =  sin(w0)
                let alpha = sin_w0 * sinh(((0.34657359027997 * bandwidth.floatValue(graph: graph) * w0)) / sin_w0);
                let b0rz = 1.0 / (1.0 + alpha)
                if let sos = sos {
                    sos.a0 = alpha * b0rz;
                    sos.b1 = cos(w0) * 2.0 * b0rz;
                    sos.b2 = (1.0 - alpha) * (b0rz * -1.0);
                    sos.a1 = 0.0
                    sos.a2 = a0 * -1.0
                }
                lastFreq = curFreq
                lastBandwidth = curBandwidth
            }
        } else {
            lastFreq = curFreq
            a0 = 0.0
            b1 = 0.0
            b2 = 0.0
            a1 = 0.0
            a2 = 0.0
        }
    }
}
