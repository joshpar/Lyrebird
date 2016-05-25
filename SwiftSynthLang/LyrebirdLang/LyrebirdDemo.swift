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
            var sin: OscSin = OscSin(rate: .Audio, freq: 3, phase: 0.0)
            sin = (sin * 0.1) as! OscSin
            sin = sin + 0.1 as! OscSin
            var am: OscSin = OscSin(rate: .Audio, freq: "Freq", phase: 0.0)
            am = ((am * sin) * 0.5) as! OscSin
            _ = Output(rate: .Audio, index: "Output", output: am)
            
        }
        /*
        // FM
        graph.build { () in
            var mod: OscSin = OscSin(rate: .Audio, freq: 110, phase: 0.0)
            mod = 3412.0 * mod + 310.0 as! OscSin
            let sin: OscSin = OscSin(rate: .Audio, freq: mod, phase: 0.0) * 0.05 as! OscSin
            _ = Output(rate: .Audio, index: "Output", output: sin)
            
        }
        */
        let note = LyrebirdNote(graph: graph)
        note.outputOffsetSamples = 44100
        
        note.updateParameter("StartFreq", value: 440.0)
        
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
        
        let randomFreqClosure = LyrebirdFloatClosure {graph in
            let freq = (drand48() * 40.0) + 440.0
            return LyrebirdFloat(freq)
        }
        
        noteTwo.updateParameter("Freq", value: randomFreqClosure)
        noteTwo.updateParameter("Output", value: 1)
        
        lyrebird.addNodeToHead(noteTwo)
    }
}
