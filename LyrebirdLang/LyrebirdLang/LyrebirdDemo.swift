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
    var timer: LyrebirdTimer? = nil
    required init(lyrebird: LyrebirdMain){
        self.lyrebird = lyrebird
        super.init()
    }
    
    func runDemo(){
        let graph = LyrebirdTestGraph()
        
        /* allow subclasses of LyrebirdGraph, and use properties instead of parameter dicts??? */
        /* instead of a key, pass a closure to evaluate? */
        
        
        graph.build { () in
            let sin = OscSin(rate: .Audio, freq: 0.25, phase: 0.0)
            let noise: NoiseWhite = NoiseWhite(rate: .Audio)
            let out = noise * 0.2  //+ sin;
            let x = sin
            //            let fos = FirstOrderSection(rate: .Audio, input: out, a0: 1.0 - Abs(rate: .Audio, input: x), a1: 0.0, b1: x)
            
            let theta = ((OscSin(rate: .Audio, freq: 0.25, phase: 0.0) * 0.4) + 0.6) * M_PI
            let rho = (OscSin(rate: .Audio, freq: 0.25, phase: 0.0) * 0.199) + 0.8
            let b1 = 2.0 * rho * Cos(rate: .Audio, input: theta)
            let srho = Squared(rate: .Audio, input: rho)
            let b2 = Negative(rate: .Audio, input: srho)
            
            let sos = SecondOrderSection(rate: .Audio, input: out, a0: 1.0, a1: 0.0, a2: 0.0, b1: b1, b2: b2)
            
            //            let mul = 0.1 + sin * 0.1
            //            let am: OscSin = OscSin(rate: .Audio, freq: "Freq", phase: 0.0)
            //            let out = am * mul * db_linamp(-6.0)
            // _ = Output(rate: .Audio, index: 4, output: sin)
            //            let input = Input(rate: .Audio, index: 2)
            // _ = Output(rate: .Audio, index: "Output", output: sos)
            //            _ = Output(rate: .Audio, index: 1, output: sin)
            
            _ = Output(rate: .Audio, index: "Output", output: sos)
            
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
        var note: LyrebirdNote? = LyrebirdNote(graph: graph)
        
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
        
        let noteTwo = LyrebirdNote(graph: graph)
        /*
         let randomFreqClosure = LyrebirdFloatClosure {graph in
         let freq = (drand48() * 80.0) + 440.0
         return LyrebirdFloat(freq)
         }
         */
        noteTwo.updateParameter("Freq", value: 440.0)
        noteTwo.updateParameter("Output", value: 1)
        
        //lyrebird.addNodeToHead(noteTwo)
        
        self.timer = LyrebirdTimer()
        if let timer = self.timer {
            var counter: LyrebirdInt = 0
            self.lyrebird.addNodeToHead(note!)
            
            let block: LyrebirdTimerBlock = {_ in
                counter = counter + 1
                print("Hello")
                if counter == 10 {
                    note?.finishBlock = { _ in
                        print("Done")
                    }
                    note?.free()
                    note = nil
                }
                if counter < 20 {
                    return 0.2
                }
                self.timer = nil
                
                return nil
                
            }
            timer.block = block
            
            timer.next()
        }
    }
}
