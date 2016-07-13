//
//  EnvelopeUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/12/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//


class EnvelopeUGens {

    
}


public struct Segment {
    let start: LyrebirdFloat
    let end: LyrebirdFloat
    let curve: LyrebirdFloat
    let duration: LyrebirdFloat
    
    // inverse of duration to avoid the divide later!
    private let iDuration: LyrebirdFloat
    private let isLine: Bool
    
    public init(start: LyrebirdFloat, end: LyrebirdFloat, curve: LyrebirdFloat, duration: LyrebirdFloat = 0.0){
        self.start = start
        self.end = end
        self.curve = curve
        self.duration = duration
        if(duration >= 0.0){
            iDuration = 1.0 / duration
        } else {
            iDuration = 1.0
        }
        isLine = self.curve == 0.0        
    }
    
    public func pollAtTime(time: LyrebirdFloat) -> LyrebirdFloat {
        if duration <= 0 || time <= 0.0 {
            return start
        }
        if time >= duration {
            return end
        }
        let timeRatio: LyrebirdFloat = (time * iDuration)
        if isLine {
            return ((end - start) * timeRatio) + start
        }
        let denom: LyrebirdFloat = 1.0 - exp(curve)
        let numer: LyrebirdFloat = 1.0 - exp(timeRatio * curve)
        let level: LyrebirdFloat = start + ((end - start) * (numer/denom))
        return level
    }
}

public struct Envelope {
    let segments: [Segment]
    private let segmentStarts: [LyrebirdFloat]
    private let segmentEnds: [LyrebirdFloat]
    
    public init (segments: [Segment]){
        self.segments = segments
        var localStarts: [LyrebirdFloat] = []
        var localEnds: [LyrebirdFloat] = []
        var curTime = 0.0
        for segment in self.segments {
            localStarts.append(curTime)
            curTime = curTime + segment.duration
            localEnds.append(curTime)
        }
        segmentStarts = localStarts
        segmentEnds = localEnds
    }
    
    public init (levels: [LyrebirdFloat], durations: [LyrebirdFloat], curves: [LyrebirdFloat]){
        // levels should have one more value than durations and curves
        var localSegments: [Segment] = []
        let levelsCount = levels.count
        let durAndCurvesNeededSize = levelsCount - 1
        let durationCount = durations.count
        let curvesCount = curves.count
        var durationsCopy = durations
        // first some checks ...
        let neededDurationValues = durAndCurvesNeededSize - durationCount
        if neededDurationValues > 0 {
            
            let lastValue: LyrebirdFloat = durations.last ?? 1.0
            for _ in 0 ... neededDurationValues {
                durationsCopy.append(lastValue)
            }
        }
        var curvesCopy = curves
        let neededCurvesValue = durAndCurvesNeededSize - curvesCount
        if neededCurvesValue > 0 {
            let lastValue: LyrebirdFloat = curves.last ?? 0.0
            for _ in 0 ... neededCurvesValue {
                curvesCopy.append(lastValue)
            }
        }
        for endIdx in 1 ..< levels.count {
            let idx = endIdx - 1
            let start = levels[idx]
            let end = levels[endIdx]
            let duration = durationsCopy[idx]
            let curve = curvesCopy[idx]
            let segment = Segment(start: start, end: end, curve: curve, duration: duration)
            localSegments.append(segment)
        }
        self.init(segments: localSegments)
    }

    public init (levels: [LyrebirdFloat], duration: LyrebirdFloat, curves: [LyrebirdFloat]){
        self.init(levels: levels, durations: [duration], curves: curves)
    }

    public init (levels: [LyrebirdFloat], durations: [LyrebirdFloat], curve: LyrebirdFloat){
        self.init(levels: levels, durations: durations, curves: [curve])
    }
    
    public init (levels: [LyrebirdFloat], duration: LyrebirdFloat, curve: LyrebirdFloat){
        self.init(levels: levels, durations: [duration], curves: [curve])
    }

    public func pollAtTime(time: LyrebirdFloat) -> LyrebirdFloat {
        if segments.count < 1 {
            return 0.0
        }
        var localTime = time
        var lastSegment: Segment?
        var lastDuration = 0.0
        for segment in segments {
            localTime = localTime - lastDuration
            lastSegment = segment
            if localTime > segment.duration {
                lastDuration = segment.duration
            } else {
                break
            }

        }
        return lastSegment?.pollAtTime(localTime) ?? 0.0

    }
}