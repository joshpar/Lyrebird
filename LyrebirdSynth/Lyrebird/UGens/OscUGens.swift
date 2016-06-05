//
//  OscSin.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/5/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

enum OscSinState: Int {
    case UGenUGen, UGenFloat, FloatUGen, FloatFloat
}

public class OscSin: LyrebirdUGen {
    var freq                        : LyrebirdValidUGenInput
    var phase                       : LyrebirdValidUGenInput
    private var lastFreq            : LyrebirdFloat = 0.0
    private var lastPhase           : LyrebirdFloat = 0.0
    private var internalPhase       : LyrebirdFloat = 0.0
    private var state               : OscSinState = .FloatFloat
    private var samplingIncrement   : LyrebirdFloat = 0.0
    private let mask                : LyrebirdInt = LyrebirdUGenInterface.sineTableMask
    private let table               : [LyrebirdFloat] = LyrebirdUGenInterface.sineTable
    private let tableCount          : LyrebirdFloat
    
    
    public required init(rate: LyrebirdUGenRate, freq: LyrebirdValidUGenInput, phase: LyrebirdValidUGenInput){
        self.freq = freq
        self.phase = phase
        self.tableCount = LyrebirdFloat(table.count)
        super.init(rate: rate)
        checkState()
        internalPhase = phase.floatValue(graph)
        let initialFreq = freq.floatValue(graph)
        self.lastFreq = initialFreq
        self.lastPhase = internalPhase
        self.samplingIncrement = self.lastFreq * LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate
        
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        let defaultFreq = 440.0
        let defaultPhase = 0.0
        self.init(rate: rate, freq: defaultFreq, phase: defaultPhase)
    }
    
    private func checkState(){
        if freq is LyrebirdFloatUGenValue {
            if phase is LyrebirdFloat {
                state = .FloatFloat
                return
            } else {
                state = .FloatUGen
                return
            }
        } else {
            if phase is LyrebirdFloatUGenValue {
                state = .UGenFloat
                return
            } else {
                state = .UGenUGen
            }
        }
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        guard let wire: LyrebirdWire = wireForIndex(0) else {
            return false
        }
        switch state {
        case .UGenUGen:
            let u_freq: LyrebirdUGen = freq as! LyrebirdUGen
            let u_phase: LyrebirdUGen = phase as! LyrebirdUGen
            success = next(numSamples, wire: wire, u_freq: u_freq, u_phase: u_phase)
            break
        case .UGenFloat:
            let u_freq: LyrebirdUGen = freq as! LyrebirdUGen
            let f_phase: LyrebirdFloat = phase.floatValue(graph)
            success = next(numSamples, wire: wire, u_freq: u_freq, f_phase: f_phase)
            lastPhase = f_phase
            break
        case .FloatUGen:
            let f_freq: LyrebirdFloat = freq.floatValue(graph)
            let u_phase: LyrebirdUGen = phase as! LyrebirdUGen
            success = next(numSamples, wire: wire, f_freq: f_freq, u_phase: u_phase)
            lastFreq = f_freq
            break
        case .FloatFloat:
            let f_freq: LyrebirdFloat = freq.floatValue(graph)
            let f_phase: LyrebirdFloat = phase.floatValue(graph)
            success = next(numSamples, wire: wire, f_freq: f_freq, f_phase: f_phase)
            lastFreq = f_freq
            lastPhase = f_phase
            break
        }
        internalPhase = internalPhase % tableCount
        return success
    }
    
    private func next(numSamples: LyrebirdInt, wire: LyrebirdWire, u_freq: LyrebirdUGen, u_phase: LyrebirdUGen) -> Bool {
        let freqSamples: [LyrebirdFloat] = u_freq.sampleBlock(graph, lastValue: 0.0)
        var f_freq: LyrebirdFloat = 0.0
        let phaseSamples: [LyrebirdFloat] = u_phase.sampleBlock(graph, lastValue: 0.0)
        var f_phase: LyrebirdFloat = 0.0
        let incrementScaler = LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        var phaseOffsetDiff = 0.0 
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            f_freq = freqSamples[sampleIdx]
            f_phase = phaseSamples[sampleIdx]
            var phaseOffsetDiff = (f_phase - lastPhase) * tableCountTimesTwoPI
            samplingIncrement = (f_freq * incrementScaler) + phaseOffsetDiff
            wire.currentSamples[sampleIdx] = sineLookup(internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
            lastPhase = f_phase
        }
        return true
    }
    
    private func next(numSamples: LyrebirdInt, wire: LyrebirdWire, f_freq: LyrebirdFloat, u_phase: LyrebirdUGen) -> Bool {
        var freqSlope: LyrebirdFloat = 0.0
        var freq: LyrebirdFloat = lastFreq
        if lastFreq != f_freq {
            freqSlope = calcSlope(lastFreq, endValue: f_freq)
        }
        let phaseSamples: [LyrebirdFloat] = u_phase.sampleBlock(graph, lastValue: 0.0)
        var f_phase: LyrebirdFloat = 0.0
        let incrementScaler = LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        var phaseOffsetDiff = 0.0
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            var phaseOffsetDiff = (f_phase - lastPhase) * tableCountTimesTwoPI
            samplingIncrement = (freq * incrementScaler) + phaseOffsetDiff
            wire.currentSamples[sampleIdx] = sineLookup(internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
            lastPhase = f_phase
            freq = freq + freqSlope
        }
        return true
    }
    
    private func next(numSamples: LyrebirdInt, wire: LyrebirdWire, u_freq: LyrebirdUGen, f_phase: LyrebirdFloat) -> Bool {
        let freqSamples: [LyrebirdFloat] = u_freq.sampleBlock(graph, lastValue: 0.0)
        var f_freq: LyrebirdFloat = 0.0
        var phaseSlope: LyrebirdFloat = 0.0
        let tableCountTimesTwoPI = M_1_TWOPI * tableCount
        if lastPhase != f_phase {
            phaseSlope = calcSlope(lastPhase, endValue: f_phase)
            phaseSlope = phaseSlope * tableCountTimesTwoPI
        }
        let incrementScaler = LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            f_freq = freqSamples[sampleIdx]
            samplingIncrement = (f_freq * incrementScaler) + phaseSlope
            wire.currentSamples[sampleIdx] = sineLookup(internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement
        }
        return true
    }
    
    private func next(numSamples: LyrebirdInt, wire: LyrebirdWire, f_freq: LyrebirdFloat, f_phase: LyrebirdFloat) -> Bool {
        var sampleIncSlope: LyrebirdFloat = 0.0
        if lastFreq != f_freq || lastPhase != f_phase {
            samplingIncrement = f_freq * LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate
            let phaseOffsetDiff = (f_phase - lastPhase) * M_1_TWOPI * tableCount
            let nextSamplingIncrement = (f_freq * LyrebirdFloat(table.count) * LyrebirdEngine.engine.iSampleRate) + phaseOffsetDiff
            sampleIncSlope = calcSlope(samplingIncrement, endValue: nextSamplingIncrement)
        }
        let phaseSlope = lastPhase != f_phase ? calcSlope(lastPhase, endValue: f_phase) : 0.0
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            wire.currentSamples[sampleIdx] = sineLookup(internalPhase, mask: mask, table: table)
            internalPhase = internalPhase + samplingIncrement + sampleIncSlope
        }
        
        return true
    }
}
