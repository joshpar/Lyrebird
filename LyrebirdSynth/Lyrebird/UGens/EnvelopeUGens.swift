//
//  EnvelopeUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/12/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum EnvelopeGenDoneAction: Int {
    case Nothing, FreeNode, Loop
}

public class EnvelopeGen : LyrebirdUGen {
    let envelope: Envelope
    var gate: Bool = false
    var doneAction: EnvelopeGenDoneAction
    let releaseSegment: LyrebirdInt
    let levelScale: LyrebirdFloat
    let levelBias: LyrebirdFloat
    let timeScale: LyrebirdFloat
    let totalDur: LyrebirdFloat
    private var timeKeeper: LyrebirdFloat = 0.0
    private let timeInc: LyrebirdFloat
    private let gateTime: LyrebirdFloat
    
    public required init(rate: LyrebirdUGenRate, envelope: Envelope, levelScale: LyrebirdFloat = 1.0, levelBias: LyrebirdFloat = 0.0, timeScale: LyrebirdFloat = 1.0, releaseSegment: LyrebirdInt = -1, doneAction: EnvelopeGenDoneAction = .Nothing){
        self.envelope = envelope
        self.levelScale = levelScale
        self.levelBias = levelBias
        self.timeScale = timeScale
        self.releaseSegment = releaseSegment
        var timeInc = LyrebirdEngine.engine.iSampleRate
        var gateTime = -1.0
        if releaseSegment >= 0 {
            gateTime = 0.0
            for (index, segment) in envelope.segments.enumerate() {
                if index <= releaseSegment {
                    gateTime = gateTime + segment.duration
                } else {
                    break
                }
            }
        }
        var totalDur: LyrebirdFloat = 0.0
        for (index, segment) in envelope.segments.enumerate() {
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
    
    required public convenience init(rate: LyrebirdUGenRate) {
        let dummyEnv: Envelope = Envelope(segments: [])
        self.init(rate: rate, envelope: dummyEnv, levelScale: 1.0, levelBias: 0.0, timeScale: 1.0, releaseSegment: -1)
    }
    
    override final public func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        print("Env \((envelope.pollAtTime(timeKeeper) * levelScale) + levelBias)")
        for sampleIdx in 0 ..< numSamples {
            samples[sampleIdx] = (envelope.pollAtTime(timeKeeper) * levelScale) + levelBias
            timeKeeper = timeKeeper + timeInc
        }
        // test release
        if timeKeeper > totalDur {
            self.graph?.shouldRemoveFromTree = true
        }
        return success
    }
    
}
