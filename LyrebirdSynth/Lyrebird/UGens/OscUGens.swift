//
//  OscSin.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/5/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

enum OscSinState: Int {
    case ugenUgen, ugenFloat, floatUgen, floatFloat
}

public final class OscSin: LyrebirdUGen {
    var freq                        : LyrebirdValidUGenInput
    var phase                       : LyrebirdValidUGenInput
    fileprivate var lastFreq            : LyrebirdFloat = 0.0
    fileprivate var lastPhase           : LyrebirdFloat = 0.0
    fileprivate var internalPhase       : LyrebirdFloat = 0.0
    fileprivate var state               : OscSinState = .floatFloat
    fileprivate var samplingIncrement   : LyrebirdFloat = 0.0
    fileprivate let mask                : LyrebirdInt = LyrebirdUGenInterface.sineTableMask
    fileprivate let table               : [LyrebirdFloat] = LyrebirdUGenInterface.sineTable
    fileprivate let tableCount          : LyrebirdFloat
    
    
    public required init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput, phase: LyrebirdValidUGenInput){
        self.freq = freq
        self.phase = phase
        self.tableCount = LyrebirdFloat(table.count)
        super.init(rate: rate)
        checkState()
        internalPhase = phase.floatValue(graph: graph)
        let initialFreq = freq.floatValue(graph: graph)
        self.lastFreq = initialFreq
        self.lastPhase = internalPhase
        self.samplingIncrement = self.lastFreq * LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate
        
    }
    
    fileprivate final func checkState(){
        if freq is LyrebirdFloatUGenValue {
            if phase is LyrebirdFloat {
                state = .floatFloat
                return
            } else {
                state = .floatUgen
                return
            }
        } else {
            if phase is LyrebirdFloatUGenValue {
                state = .ugenFloat
                return
            } else {
                state = .ugenUgen
            }
        }
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples: numSamples)
        switch state {
        case .ugenUgen:
            let u_freq: LyrebirdUGen = freq as! LyrebirdUGen
            let u_phase: LyrebirdUGen = phase as! LyrebirdUGen
            success = next(numSamples: numSamples, u_freq: u_freq, u_phase: u_phase)
            break
        case .ugenFloat:
            let u_freq: LyrebirdUGen = freq as! LyrebirdUGen
            let f_phase: LyrebirdFloat = phase.floatValue(graph: graph)
            success = next(numSamples: numSamples, u_freq: u_freq, f_phase: f_phase)
            lastPhase = f_phase
            break
        case .floatUgen:
            let f_freq: LyrebirdFloat = freq.floatValue(graph: graph)
            let u_phase: LyrebirdUGen = phase as! LyrebirdUGen
            success = next(numSamples: numSamples, f_freq: f_freq, u_phase: u_phase)
            lastFreq = f_freq
            break
        case .floatFloat:
            let f_freq: LyrebirdFloat = freq.floatValue(graph: graph)
            let f_phase: LyrebirdFloat = phase.floatValue(graph: graph)
            success = next(numSamples: numSamples, f_freq: f_freq, f_phase: f_phase)
            lastFreq = f_freq
            lastPhase = f_phase
            break
        }
        internalPhase = internalPhase.truncatingRemainder(dividingBy: tableCount)
        return success
    }
    
    fileprivate final func next(numSamples: LyrebirdInt, u_freq: LyrebirdUGen, u_phase: LyrebirdUGen) -> Bool {
        let freqSamples: [LyrebirdFloat] = u_freq.sampleBlock(graph: graph, previousValue: 0.0)
        var f_freq: LyrebirdFloat = 0.0
        let phaseSamples: [LyrebirdFloat] = u_phase.sampleBlock(graph: graph, previousValue: 0.0)
        var f_phase: LyrebirdFloat = 0.0
        let incrementScaler = LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            f_freq = freqSamples[sampleIdx]
            f_phase = phaseSamples[sampleIdx]
            let phaseOffsetDiff = (f_phase - lastPhase) * tableCountTimesTwoPI
            samplingIncrement = (f_freq * incrementScaler) + phaseOffsetDiff
            samples[sampleIdx] = sineLookup(sampleIdx: internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
            lastPhase = f_phase
        }
        return true
    }
    
    fileprivate final func next(numSamples: LyrebirdInt, f_freq: LyrebirdFloat, u_phase: LyrebirdUGen) -> Bool {
        var freqSlope: LyrebirdFloat = 0.0
        var freq: LyrebirdFloat = lastFreq
        if lastFreq != f_freq {
            freqSlope = calcSlope(startValue: lastFreq, endValue: f_freq)
        }
        let phaseSamples: [LyrebirdFloat] = u_phase.sampleBlock(graph: graph, previousValue: 0.0)
        var f_phase: LyrebirdFloat = 0.0
        let incrementScaler = LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        var phaseOffsetDiff = 0.0
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            f_phase = phaseSamples[sampleIdx]
            phaseOffsetDiff = (f_phase - lastPhase) * tableCountTimesTwoPI
            samplingIncrement = (freq * incrementScaler) + phaseOffsetDiff
            samples[sampleIdx] = sineLookup(sampleIdx: internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
            lastPhase = f_phase
            freq = freq + freqSlope
        }
        return true
    }
    
    fileprivate final func next(numSamples: LyrebirdInt, u_freq: LyrebirdUGen, f_phase: LyrebirdFloat) -> Bool {
        let freqSamples: [LyrebirdFloat] = u_freq.sampleBlock(graph: graph, previousValue: 0.0)
        var f_freq: LyrebirdFloat = 0.0
        var phaseSlope: LyrebirdFloat = 0.0
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        if lastPhase != f_phase {
            phaseSlope = calcSlope(startValue: lastPhase, endValue: f_phase)
            phaseSlope = phaseSlope * tableCountTimesTwoPI
        }
        let incrementScaler = LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            f_freq = freqSamples[sampleIdx]
            samplingIncrement = (f_freq * incrementScaler) + phaseSlope
            samples[sampleIdx] = sineLookup(sampleIdx: internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
        }
        return true
    }
    
    fileprivate final func next(numSamples: LyrebirdInt, f_freq: LyrebirdFloat, f_phase: LyrebirdFloat) -> Bool {
        var sampleIncSlope: LyrebirdFloat = 0.0
        if lastFreq != f_freq || lastPhase != f_phase {
            samplingIncrement = f_freq * LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate
            let phaseOffsetDiff = (f_phase - lastPhase) * M_1_TWOPI * tableCount
            let nextSamplingIncrement = (f_freq * LyrebirdFloat(table.count) * Lyrebird.engine.iSampleRate) + phaseOffsetDiff
            sampleIncSlope = calcSlope(startValue: samplingIncrement, endValue: nextSamplingIncrement)
        }
        let phaseSlope = lastPhase != f_phase ? calcSlope(startValue: lastPhase, endValue: f_phase) : 0.0
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            samples[sampleIdx] = sineLookup(sampleIdx: internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement + sampleIncSlope + phaseSlope
        }
        
        return true
    }
}

public final class Impulse : LyrebirdUGen {
    var samplesRemain: LyrebirdInt = 0
    var freq: LyrebirdValidUGenInput
    
    
    // phase values between 0.0 and 1.0
    public required init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput = 0.0, initPhase: LyrebirdValidUGenInput = 0.0){
        self.freq = freq
        super.init(rate: rate)
        let phase: LyrebirdFloat = initPhase.floatValue(graph: graph).truncatingRemainder(dividingBy: 1.0)
        if(phase > 0.0){
            self.calcNextImpulse()
            samplesRemain = LyrebirdInt(round(LyrebirdFloat(samplesRemain) * (1.0 - phase)))
        } else {
            samplesRemain = 0
        }
        
    }
    
    fileprivate final func calcNextImpulse(){
        let f_freq = freq.floatValue(graph: graph)
        if(f_freq > 0.0){
            samplesRemain = LyrebirdInt(round(Lyrebird.engine.sampleRate / f_freq))
            if samplesRemain < 1 {
                samplesRemain = 1
            }
        } else {
            samplesRemain = -1
        }
    }
    
    public final override func next(numSamples: LyrebirdInt) -> Bool {
        let success = super.next(numSamples: numSamples)
        if(samplesRemain > numSamples){
            samplesRemain = samplesRemain - numSamples
            samples = LyrebirdUGen.zeroedSamples
            return success
        }
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            if samplesRemain != 0 {
                samples[sampleIdx] = 0.0
                samplesRemain = samplesRemain - 1
            } else {
                samples[sampleIdx] = 1.0
                calcNextImpulse()
            }
            
        }
        return success
    }
}
