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

typealias LyrebirdResultOutputBlock = (_ finished: Bool) -> Void

class LyrebirdEngine {
    // initial default engine. This should act as a singleton however! Every init of LyrebirdEngine will overwrite this instance.
    static var engine: LyrebirdEngine = LyrebirdEngine()
    
    var delegate: LyrebirdEngineDelegate?
    
    var isRunning                       : Bool = false
    var numberOfAudioChannels           : LyrebirdInt = 128
    var numberOfControlChannels         : LyrebirdInt = 2048
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
            self.delegate?.synthEngineHasStarted(engine: self)
        }
    }
    
    func stop(){
        if(isRunning){
            isRunning = false
            self.delegate?.synthEngineHasStopped(engine: self)
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
        } catch LyrebirdTreeError.alreadyProcessing {
            print("Already Processing")
        } catch _ {
            print("Throw on some Bootsy Collins, because something funky happened.")
        }
    }
    
    func runTests(){

    }
    
}
