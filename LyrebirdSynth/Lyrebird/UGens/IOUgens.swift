//
//  IOUgens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/15/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation



public class Output : LyrebirdUGen {
    var index: LyrebirdValidUGenInput
    var output: LyrebirdValidUGenInput
    private var channel: LyrebirdAudioChannel? = nil
    
    public required init(rate: LyrebirdUGenRate, index: LyrebirdValidUGenInput, output: LyrebirdValidUGenInput){
        self.index = index
        self.output = output
        super.init(rate: rate)
        let channels: [LyrebirdAudioChannel] = LyrebirdEngine.engine.audioBlock
        if(index.intValue(graph) < channels.count){
            channel = channels[self.index.intValue(graph)]
        }
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        let defaultIndex = 0.0
        let defaultOuput = 0.0
        self.init(rate: rate, index: defaultIndex, output: defaultOuput)
    }
   
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        // get the audio wire to output
        let channels: [LyrebirdAudioChannel] = LyrebirdEngine.engine.audioBlock
        if(index.intValue(graph) < channels.count){
            channel = channels[self.index.intValue(graph)]
        }
        let sampleChannels: [[LyrebirdFloat]] = output.calculatedSamples(graph)
        // assume mono for now
        let outputChannel: [LyrebirdFloat] = sampleChannels[0]
        
        // Wires always write their output to the first indexes of their array
        // however, when an offset if needed, Output UGens must account for this when they write
        
        let blockSize = LyrebirdEngine.engine.blockSize
        let offset = blockSize - numSamples
        if let channel = self.channel {
            channel.touched = true
            for index in offset ..< LyrebirdEngine.engine.blockSize {
                channel.currentValues[index] = channel.currentValues[index] + outputChannel[index]
            }
        }
        return true
    }
    
}

public class Input : LyrebirdUGen {
    var index: LyrebirdValidUGenInput
    private var channel: LyrebirdAudioChannel? = nil
    private var wire: LyrebirdWire? = nil
    
    public required init(rate: LyrebirdUGenRate, index: LyrebirdValidUGenInput){
        self.index = index
        super.init(rate: rate)
        let channels: [LyrebirdAudioChannel] = LyrebirdEngine.engine.audioBlock
        if(index.intValue(graph) < channels.count){
            channel = channels[self.index.intValue(graph)]
        }
        wire = wireForIndex(0)
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        let defaultIndex = 0.0
        self.init(rate: rate, index: defaultIndex)
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        // get the audio wire to output
        guard let wire: LyrebirdWire = self.wire else {
            return false
        }
        
        guard let channel: LyrebirdAudioChannel = self.channel else {
            return false
        }
        
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            wire.currentSamples[sampleIdx] = channel.currentValues[sampleIdx]
        }
    
        return true
    }
    
}
