//
//  LyrebirdDemo.swift
//  LyrebirdSynthLang
//
//  Created by Joshua Parmenter on 5/19/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa
import Lyrebird

class LyrebirdDemo: NSObject {
    
    let lyrebird: LyrebirdMain!
    
    required init(lyrebird: LyrebirdMain){
        self.lyrebird = lyrebird
        super.init()
    }
    
    func runDemo(){
        let graph = LyrebirdTestGraph()
        
        /* allow subclasses of LyrebirdGraph, and use properties instead of parameter dicts??? */
        /* instead of a key, pass a closure to evaluate? */
        
        graph.build { () in
            let sin: OscSin = OscSin(rate: .Audio, freq: 4, phase: 0.0)
            let mul = 0.1 + sin * 0.1
            let am: OscSin = OscSin(rate: .Audio, freq: "Freq", phase: 0.0)
            let out = am * mul * db_linamp(-6.0)
            _ = Output(rate: .Audio, index: "Output", output: out)
            
        }
        
        /*
        // FM
        graph.build { () in
            let mod: OscSin = OscSin(rate: .Audio, freq: 110, phase: 0.0)
            let modMul = 3412.0 * mod - "Freq"
            let sin: OscSin = OscSin(rate: .Audio, freq: modMul, phase: 0.0)
            _ = Output(rate: .Audio, index: "Output", output: sin * 0.05)
            
        }
        */
        let note = LyrebirdNote(graph: graph)
        note.outputOffsetSamples = 44100
        
        note.updateParameter("StartFreq", value: keynum_hz(69.0))
        
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
        
        note.updateParameter("Freq", value: risingFreqClosure)
        note.updateParameter("Output", value: 0)
        
        lyrebird.addNodeToHead(note)
        
        let noteTwo = LyrebirdNote(graph: graph)
        /*
        let randomFreqClosure = LyrebirdFloatClosure {graph in
            let freq = (drand48() * 80.0) + 440.0
            return LyrebirdFloat(freq)
        }
        */
        noteTwo.updateParameter("Freq", value: 440.0)
        noteTwo.updateParameter("Output", value: 1)
        
        lyrebird.addNodeToHead(noteTwo)
    }
}
