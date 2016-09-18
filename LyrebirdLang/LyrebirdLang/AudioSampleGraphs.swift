//
//  AudioSampleGraphs.swift
//  LyrebirdSynthLang
//
//  Created by Joshua Parmenter on 5/15/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa
import Lyrebird

struct LyrebirdTestGraphs {
    var graphs: [String: LyrebirdGraph] = [:]
    
    // closure should refer to the graph, assign children and refer to args
    mutating func setupDemoGraphs(){
        let noiseSweepGraph = LyrebirdGraph()
        noiseSweepGraph.build { () in
            let noise: NoiseWhite = NoiseWhite(rate: .audio)
            let out = noise * 0.2
            let theta = ((OscSin(rate: .audio, freq: 0.25, phase: 0.0) * 0.4) + 0.6) * M_PI
            let rho = (OscSin(rate: .audio, freq: 0.25, phase: 0.0) * 0.199) + 0.8
            let b1 = 2.0 * rho * Cos(rate: .audio, input: theta)
            let srho = Squared(rate: .audio, input: rho)
            let b2 = Negative(rate: .audio, input: srho)
            let sos = SecondOrderSection(rate: .audio, input: out, a0: 1.0, a1: 0.0, a2: 0.0, b1: b1, b2: b2)
            _ = Output(rate: .audio, index: "Output", output: sos)
        }
        graphs["noiseSweep"] = noiseSweepGraph

        let fmGraph = LyrebirdGraph()
        // "Freq" and "Output" can be passed in as parameters at run time
        fmGraph.build { () in
            let mod: OscSin = OscSin(rate: .audio, freq: 110, phase: 0.0)
            let modMul = 3412.0 * mod - "Freq"
            let sin: OscSin = OscSin(rate: .audio, freq: modMul, phase: 0.0)
            _ = Output(rate: .audio, index: "Output", output: sin * "Amp")
        }
        // parameter defaults
        fmGraph.parameters["Freq"] = 440.0
        fmGraph.parameters["Output"] = 0
        fmGraph.parameters["Amp"] = 0.2
        graphs["fm"] = fmGraph
        
        let impulseGraph = LyrebirdGraph()
        
        impulseGraph.build {
            let white = RandWhite()
            let trigger: Impulse = Impulse(rate: .audio, freq: "Freq", initPhase: 0.0)
            let freq: TriggerWithBlock = TriggerWithBlock(rate: .audio, trigger: trigger, triggerBlock: { (triggerValue, counter) -> LyrebirdFloat in
                return 440.0 * LyrebirdFloat(counter) * white.next().numberValue()
            })
            let sin: OscSin = OscSin(rate: .audio, freq: freq, phase: 0.0)
            let envelope: Envelope = Envelope(levels: [0, 1, 1, 0], duration: 1, curves: [5, 0, -5])
            let out = sin * EnvelopeGen(rate: .audio, envelope: envelope, levelScale: db_linamp(db: -24.0), levelBias: 0.0, timeScale: 1.0, releaseSegment: -1, doneAction: EnvelopeGenDoneAction.freeNode)
            _ = Output(rate: .audio, index: "Output", output: out )
        }
        impulseGraph.parameters["Output"] = 0
        impulseGraph.parameters["Freq"] = 4
        graphs["impulse"] = impulseGraph
        
        let noiseLineGraph = LyrebirdGraph()
        
        noiseLineGraph.build { 
            let freq = NoiseLFLine(rate: .audio, freq: 1)
            let freqRange = freq * 440.0 + 440.0
            let sin = OscSin(rate: .audio, freq: freqRange, phase: 0.0)
            _ = Output(rate: .audio, index: "Output", output: sin * db_linamp(db: -24.0))
        }
        noiseLineGraph.parameters["Output"] = 0
        
        graphs["noiseLine"] = noiseLineGraph
        
        let noiseLineGraphDelay = LyrebirdGraph()
        
        noiseLineGraphDelay.build {
            let freq = NoiseLFLine(rate: .audio, freq: 1, seed: 123)
            let freqRange = freq * 440.0 + 440.0
            let sin = OscSin(rate: .audio, freq: freqRange, phase: 0.0)
            let delTime = 0.2
            let delay = DelayLineFeedback(rate: .audio, input: sin, delayTime: delTime, decayTime: 20.0, maxDelayTime: 1.0, interpolation: .cubic)
            _ = Output(rate: .audio, index: "Output", output: sin * db_linamp(db: -24.0))
            _ = Output(rate: .audio, index: "OutputTwo", output: delay * db_linamp(db: -24.0))
        }
        noiseLineGraphDelay.parameters["Output"] = 0
        noiseLineGraphDelay.parameters["OutputTwo"] = 1
        
        graphs["noiseLineDelay"] = noiseLineGraphDelay
        
        let filterTests = LyrebirdGraph()
        
        filterTests.build { 
            let noise: NoiseWhite = NoiseWhite(rate: .audio)
            let out = noise // * 0.2
            let freq = NoiseLFLine(rate: .audio, freq: 1, seed: 123)
            let freqRange = Range(rate: .audio, input: freq, low: 1000, high: 1440.0);
            let bandpass = FilterRBJBandPass(rate: .audio, input: out, freq: freqRange, bandwidth: 0.01)
            _ = Output(rate: .audio, index: "Output", output: bandpass)
        }
        
        filterTests.parameters["Output"] = 0
        graphs["filterTests"] = filterTests

    }
}


/*
 
 
 
 
 note?.outputOffsetSamples = 0
 
 note?.updateParameter("StartFreq", value: keynum_hz(69.0))
 
 let risingFreqClosure = LyrebirdFloatClosure {graph in
 var freq = 0.0
 if let graph = graph {
 if let freqIn = graph.parameters["StartFreq"] {
 freq = freqIn.floatValue(graph) + 10
 graph.parameters["StartFreq"] = freq
 }
 }
 return LyrebirdFloat(freq)
 }
 
 note?.updateParameter("Freq", value: risingFreqClosure)
 note?.updateParameter("Output", value: 0)
 
 //lyrebird.addNodeToHead(note)
 
 let noteTwo = LyrebirdNote(graph: noiseSweep)
 /*
 let randomFreqClosure = LyrebirdFloatClosure {graph in
 let freq = (drand48() * 80.0) + 440.0
 return LyrebirdFloat(freq)
 }
 */
 noteTwo.updateParameter("Freq", value: 440.0)
 noteTwo.updateParameter("Output", value: 1)

 */
