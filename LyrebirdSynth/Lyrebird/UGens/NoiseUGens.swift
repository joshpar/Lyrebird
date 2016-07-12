//
//  NoiseUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public class NoiseGen : LyrebirdUGen {
    private var ranGen: LyrebirdRandomNumberGenerator = LyrebirdRandomNumberGenerator(initSeed: 0)
    public var seed: LyrebirdInt = 0 {
        didSet {
            ranGen.seed = UInt32(seed)
        }
    }
    
    static func dateSeed() -> LyrebirdInt {
        return LyrebirdInt(NSDate.timeIntervalSinceReferenceDate())
    }
}

public final class NoiseWhite: NoiseGen {

    public required init(rate: LyrebirdUGenRate, seed: LyrebirdInt){
        super.init(rate: rate)
        self.seed = seed
    }
    
    required public convenience init(rate: LyrebirdUGenRate) {
        self.init(rate: rate, seed: NoiseGen.dateSeed())
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            samples[sampleIdx] = (ranGen.next() * 2.0) - 1.0
        }
        return true
    }
}

public class NoiseLFBase: NoiseGen {
    var freq: LyrebirdValidUGenInput
    internal var currentOutput: LyrebirdFloat = 0.0
    internal var samplesUntilNextValue: LyrebirdInt = 0
    
    public required init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput, seed: LyrebirdInt){
        self.freq = freq
        super.init(rate: rate)
        self.seed = seed
    }
    
    public convenience init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput) {
        self.init(rate: rate, freq: freq, seed: NoiseGen.dateSeed())
    }
    
    required public convenience init(rate: LyrebirdUGenRate) {
        self.init(rate: rate, freq: 1.0, seed: NoiseGen.dateSeed())
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        assert(false, "NoiseLFBase should not be used in a SynthGraph, or have its next function called")
        return true
    }
}

public final class NoiseLFStep: NoiseLFBase {
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        if (samplesUntilNextValue > numSamples) || (samplesUntilNextValue <= -1) {
            samplesUntilNextValue = samplesUntilNextValue - numSamples
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                samples[sampleIdx] = currentOutput
            }
        } else {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                samplesUntilNextValue = samplesUntilNextValue - 1
                if(samplesUntilNextValue == 0){
                    var curFreq =  freq.floatValue(graph)
                    if curFreq <= 0 {
                        samplesUntilNextValue = -1
                    } else {
                        samplesUntilNextValue = LyrebirdInt(round(LyrebirdEngine.engine.iSampleRate / curFreq))
                        if samplesUntilNextValue < 1 {
                            samplesUntilNextValue = 1
                        }
                        self.currentOutput = ranGen.bipolarNext()
                    }
                }
                samples[sampleIdx] = currentOutput
            }
        }
        return true
    }
}

public final class NoiseLFLine: NoiseLFBase {
    internal var prevOutputValue: LyrebirdFloat = 0.0
    private var step: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput, seed: LyrebirdInt){
        super.init(rate: rate, freq: freq, seed: seed)
        self.seed = seed
        self.prevOutputValue = ranGen.bipolarNext()
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        var currentValue = currentOutput
        if (samplesUntilNextValue > numSamples) || (samplesUntilNextValue <= -1) {
            samplesUntilNextValue = samplesUntilNextValue - numSamples
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                currentValue = currentValue + step
                samples[sampleIdx] = currentValue
            }
        } else {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                samplesUntilNextValue = samplesUntilNextValue - 1
                if(samplesUntilNextValue > 0){
                    currentValue = currentValue + step
                    samples[sampleIdx] = currentValue
                } else {
                    var curFreq =  freq.floatValue(graph)
                    if curFreq <= 0 {
                        samplesUntilNextValue = -1
                        step = 0
                    } else {
                        samplesUntilNextValue = LyrebirdInt(round( LyrebirdEngine.engine.sampleRate / curFreq))
                        if samplesUntilNextValue < 1 {
                            samplesUntilNextValue = 1
                        }
                        let nextValue: LyrebirdFloat = ranGen.bipolarNext()
                        step = calcSlope(prevOutputValue, endValue: nextValue, numSamples: LyrebirdFloat(samplesUntilNextValue))
                        currentValue = prevOutputValue
                        prevOutputValue = nextValue
                    }
                    samples[sampleIdx] = currentValue
                }
            }
        }
        currentOutput = currentValue
        return true
    }
}