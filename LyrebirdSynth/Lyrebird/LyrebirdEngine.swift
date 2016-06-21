//
//  LyrebirdEngine.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

protocol LyrebirdEngineDelegate {
    func synthEngineHasStarted(engine: LyrebirdEngine)
    func synthEngineHasStopped(engine: LyrebirdEngine)
}

typealias LyrebirdResultOutputBlock = (finished: Bool) -> Void

class LyrebirdEngine {
    // initial default engine. This should act as a singleton however! Every init of LyrebirdEngine will overwrite this instance.
    static var engine: LyrebirdEngine = LyrebirdEngine()
    
    var delegate: LyrebirdEngineDelegate?
    
    var isRunning                       : Bool = false
    var numberOfAudioChannels           : LyrebirdInt = 128
    var numberOfControlChannels         : LyrebirdInt = 2048
    var internalMemoryPoolSize          : LyrebirdInt = 32768
    var blockSize                       : LyrebirdInt = 1024 {
        didSet {
            if(self.blockSize > 0){
                self.iBlockSize = 1.0 / LyrebirdFloat(self.blockSize)
            }
        }
    }
    var sampleRate                      : LyrebirdFloat = 44100.0 {
        didSet {
            if(self.sampleRate > 0.0){
                self.iSampleRate = 1.0 / sampleRate
            }
        }
    }
    var iBlockSize                      : LyrebirdFloat = 0.015625
    var iSampleRate                     : LyrebirdFloat = 0.000022676
    var audioBlock                      : [LyrebirdAudioChannel] = []
    var controlBlock                    : [LyrebirdControlChannel] = []
    var tree                            : LyrebirdNodeTree = LyrebirdNodeTree()
    
    // need to
    func start(){
        if(!isRunning){
            // allocate our memory
            for idx: Int in 0 ..< numberOfAudioChannels {
                let channel: LyrebirdAudioChannel = LyrebirdAudioChannel(index: idx, blockSize: blockSize)
                self.audioBlock.append(channel)
            }
            for idx: Int in 0 ..< numberOfControlChannels-1 {
                let channel: LyrebirdControlChannel = LyrebirdControlChannel(index: idx, iBlockSize: iBlockSize)
                self.controlBlock.append(channel)
            }
            LyrebirdUGenInterface.initInterface()
            isRunning = true
            self.delegate?.synthEngineHasStarted(self)
        }
    }
    
    func stop(){
        if(isRunning){
            isRunning = false
            self.delegate?.synthEngineHasStopped(self)
        }
    }
    
    func clearAll(){
        tree = LyrebirdNodeTree()
    }
    
    func processWithInputChannels(inputChannels: [LyrebirdAudioChannel]){
        for audioChannel: LyrebirdAudioChannel in self.audioBlock {
            audioChannel.zeroValues()
        }
        // add input channels to the audio block
        do {
            try tree.processTree { (nodeTree, finished) in
                // write to outputs
            }
        } catch LyrebirdTreeError.AlreadyProcessing {
            print("Already Processing")
        } catch _ {
            print("Throw on some Bootsy Collins, because something funky happened.")
        }
    }
    
    func runTests(){
        /*
        let graph = LyrebirdGraph()
        
        /* allow subclasses of LyrebirdGraph, and use properties instead of parameter dicts??? */
        /* instead of a key, pass a closure to evaluate? */
        graph.build { (graph: LyrebirdGraph) in
            graph.parameters["ControlScaler"] = 1.0
            /*
            let control = Control(graph: graph, rate: .Control, currentValue: "ControlScaler");
            let controlTwo = Control(graph: graph, rate: .Control, currentValue: control);
            */
            let sin = OscSin(graph: graph, rate: .Audio, freq: 440.0, phase: 0.0)
            Output(graph: graph, rate: .Audio, index: 0, output: sin)
        }
        let note = LyrebirdNote(graph: graph)
        tree.defaultGroup.addNodeToHead(note)
        
        do {
            try tree.processTree { (nodeTree, finished) in
                // write to outputs
            }
        } catch LyrebirdTreeError.AlreadyProcessing {
            print("Already Processing")
        } catch _ {
            print("Throw on some Bootsy Collins, because something funky happened.")
        }
*/
    }
    
}
