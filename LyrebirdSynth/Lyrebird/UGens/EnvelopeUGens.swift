//
//  EnvelopeUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/12/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum EnvelopeGenDoneAction: Int {
    case nothing, freeNode, loop
}

open class EnvelopeGen : LyrebirdUGen {
    let envelope: Envelope
    var gate: Bool = false
    var doneAction: EnvelopeGenDoneAction
    let releaseSegment: LyrebirdInt
    let levelScale: LyrebirdFloat
    let levelBias: LyrebirdFloat
    let timeScale: LyrebirdFloat
    let totalDur: LyrebirdFloat
    fileprivate var timeKeeper: LyrebirdFloat = 0.0
    fileprivate let timeInc: LyrebirdFloat
    fileprivate let gateTime: LyrebirdFloat
    
    public required init(rate: LyrebirdUGenRate, envelope: Envelope, levelScale: LyrebirdFloat = 1.0, levelBias: LyrebirdFloat = 0.0, timeScale: LyrebirdFloat = 1.0, releaseSegment: LyrebirdInt = -1, doneAction: EnvelopeGenDoneAction = .nothing){
        self.envelope = envelope
        self.levelScale = levelScale
        self.levelBias = levelBias
        self.timeScale = timeScale
        self.releaseSegment = releaseSegment
        var timeInc = Lyrebird.engine.iSampleRate
        var gateTime = -1.0
        if releaseSegment >= 0 {
            gateTime = 0.0
            for (index, segment) in envelope.segments.enumerated() {
                if index <= releaseSegment {
                    gateTime = gateTime + segment.duration
                } else {
                    break
                }
            }
        }
        var totalDur: LyrebirdFloat = 0.0
        for (index, segment) in envelope.segments.enumerated() {
            totalDur = totalDur + segment.duration
        }
        self.gateTime = gateTime
        if timeScale != 1.0 && timeScale > 0.0 {
            totalDur = totalDur * timeScale
            timeInc = timeInc / timeScale
        }
        self.totalDur = totalDur
        self.doneAction = doneAction
        self.timeInc = timeInc
        super.init(rate: rate)
    }
    
    override final public func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples: numSamples)
        for sampleIdx in 0 ..< numSamples {
            samples[sampleIdx] = (envelope.poll(atTime: timeKeeper) * levelScale) + levelBias
            timeKeeper = timeKeeper + timeInc
            // test release
            if (timeKeeper > totalDur) && (doneAction == .loop) {
                timeKeeper = 0.0
            }
        }
        if (timeKeeper > totalDur) && (doneAction == .freeNode) {
                self.graph?.shouldRemoveFromTree = true
        }
        return success
    }
    
}
