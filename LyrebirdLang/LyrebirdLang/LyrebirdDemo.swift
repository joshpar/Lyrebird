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
    
    let lyrebird: Lyrebird!
    var timer: LyrebirdTimer? = nil
    var graphs: LyrebirdTestGraphs = LyrebirdTestGraphs()
    
    required init(lyrebird: Lyrebird){
        self.lyrebird = lyrebird
        super.init()
    }
    
    func runDemo(){
        
        graphs.setupDemoGraphs()
        
        
        let impulse = graphs.graphs["impulse"]
        let impulseNote : LyrebirdNote = LyrebirdNote(graph: impulse)
        impulseNote.updateParameter("Freq", value: 1.0)
        impulseNote.updateParameter("Output", value: 0)
        impulseNote.finishBlock = {(node) -> Void in
            print("DONE!!!!")
            }
        
        let noiseLine = graphs.graphs["noiseLineDelay"]
        var noiseLineNote: LyrebirdNote? = LyrebirdNote(graph: noiseLine)
        noiseLineNote?.updateParameter("Output", value: 0)
        noiseLineNote?.updateParameter("OutputTwo", value: 1)
        
        /* // some sample benchmark code for testing
        let start  = NSDate.timeIntervalSinceReferenceDate()
        
        let white = LyrebirdRandomNumberGenerator()
        for _ in 0 ..< 10000 {
            feedbackCoef(0.1, decayTime: 10.0, targetAmp: white.next())
        }
        
        let end = NSDate.timeIntervalSinceReferenceDate()
        
        print("time to run: \(end-start)")
        */
        
        self.timer = LyrebirdTimer()
        if let timer = self.timer {
            var counter: LyrebirdInt = 0
            /*
            self.lyrebird.addNodeToHead(noiseNote!)
            lyrebird.addNodeToHead(fmNote!)
            */
            //lyrebird.addNodeToHead(impulseNote)
            lyrebird.addNodeToHead(noiseLineNote!)
            
            let block: LyrebirdTimerBlock = {(curTime: LyrebirdFloat, inc: LyrebirdInt) in
                counter = counter + 1
                print("Hello \(curTime, inc)")
                if counter == 19 {
/*                    noiseNote?.finishBlock = { _ in
                        print("Done")
                    }
                    noiseNote?.free()
                    noiseNote = nil
                    fmNote?.free()
                    fmNote = nil
 */
//                    impulseNote?.free()
//                    impulseNote = nil
                    noiseLineNote?.free()
                    noiseLineNote = nil
                }
                if counter < 20 {
                    return 0.4
                }
                self.timer = nil
                
                return nil
                
            }
            timer.block = block
            let finalBlock: LyrebirdTimerFinalizerBlock = {(curTime: LyrebirdFloat) in
                    print("Final \(curTime)")
            }
            timer.finalizerBlock = finalBlock
            timer.run()
        }
    }
}
