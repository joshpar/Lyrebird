//
//  IOUgens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/15/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public final class Output : LyrebirdUGen {
    var index: LyrebirdValidUGenInput
    var output: LyrebirdValidUGenInput
    fileprivate var channel: LyrebirdAudioChannel? = nil
    
    public required init(rate: LyrebirdUGenRate, index: LyrebirdValidUGenInput, output: LyrebirdValidUGenInput){
        self.index = index
        self.output = output
        super.init(rate: rate)
        let channels: [LyrebirdAudioChannel] = Lyrebird.engine.audioBlock
        if(index.intValue(graph: graph) < channels.count){
            channel = channels[index.intValue(graph: graph)]
        }
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        // get the audio wire to output
        let channels: [LyrebirdAudioChannel] = Lyrebird.engine.audioBlock
        if(index.intValue(graph: graph) < channels.count){
            channel = channels[index.intValue(graph: graph)]
        }
        let sampleChannels: [[LyrebirdFloat]] = output.calculatedSamples(graph: graph)
        // assume mono for now
        let outputChannel: [LyrebirdFloat] = sampleChannels[0]
        
        // Wires always write their output to the first indexes of their array
        // however, when an offset if needed, Output UGens must account for this when they write
        
        let blockSize = Lyrebird.engine.blockSize
        let offset = blockSize - numSamples
        if let channel = self.channel {
            channel.touched = true
            for index in offset ..< Lyrebird.engine.blockSize {
                channel.currentValues[index] = channel.currentValues[index] + outputChannel[index]
            }
        }
        return true
    }
    
}

public final class Input : LyrebirdUGen {
    var index: LyrebirdValidUGenInput
    fileprivate var channel: LyrebirdAudioChannel? = nil
    
    public required init(rate: LyrebirdUGenRate, index: LyrebirdValidUGenInput){
        self.index = index
        super.init(rate: rate)
        let channels: [LyrebirdAudioChannel] = Lyrebird.engine.audioBlock
        if(index.intValue(graph: graph) < channels.count){
            channel = channels[self.index.intValue(graph: graph)]
        }
    }
    
    override public final func next(numSamples: LyrebirdInt) -> Bool {
        // get the audio wire to output
        guard let channel: LyrebirdAudioChannel = self.channel else {
            return false
        }
        
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            samples[sampleIdx] = channel.currentValues[sampleIdx]
        }
    
        return true
    }
    
}
