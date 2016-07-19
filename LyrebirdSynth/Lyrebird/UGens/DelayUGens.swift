//
//  DelayUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/16/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum DelayInterpolationType {
    case None, Linear, Cubic
}

public class DelayLine: LyrebirdUGen {
    private final var buffer: [LyrebirdFloat]
    private final let bufferSize: LyrebirdInt // should be a power of 2
    private final let mask: LyrebirdInt
    private final var readHead: LyrebirdFloat = 0.0
    private final var writeHead: LyrebirdInt = 0
    public final var interpolation: DelayInterpolationType
    public final var delayTime: LyrebirdValidUGenInput
    private final var lastDelayTime: LyrebirdFloat = 0.0
    public final var input: LyrebirdValidUGenInput
    
    
    public required init(rate: LyrebirdUGenRate,  input: LyrebirdValidUGenInput, delayTime: LyrebirdValidUGenInput, maxDelayTime: LyrebirdFloat = 1.0, interpolation: DelayInterpolationType = .None) {
        self.input = input
        self.delayTime = delayTime
        self.interpolation = interpolation
        self.bufferSize = LyrebirdInt(nextPowerOfTwo(LyrebirdInt(ceil(Lyrebird.engine.sampleRate * maxDelayTime))))
        self.mask = bufferSize - 1
        self.buffer = [LyrebirdFloat](count: bufferSize, repeatedValue: 0.0)
        super.init(rate: rate)
        self.writeHead = LyrebirdInt(Lyrebird.engine.sampleRate * delayTime.floatValue(graph))
        self.lastDelayTime = self.delayTime.floatValue(graph)
    }
    
    public override final func next(numSamples: LyrebirdInt) -> Bool {
        var success = super.next(numSamples)
        if(success){
            switch self.interpolation {
            case .Linear:
                success = nextLinear(numSamples)
                break
                
            case .None:
                success = nextNone(numSamples)
                break
                
            case .Cubic:
                success = nextCubic(numSamples)
                break
            }
            while readHead > LyrebirdFloat(mask) {
                readHead = readHead - LyrebirdFloat(bufferSize)
            }
            if writeHead > mask {
                writeHead = writeHead & mask
            }
        }
        return success
    }
    
    private final func nextNone(numSamples: LyrebirdInt) -> Bool{
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead) & mask
            samples[sampleIdx] = buffer[iReadHead]
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextLinear(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            samples[sampleIdx] = linearInterp(buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextCubic(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxM1: LyrebirdInt = (iReadHead - 1) & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            let bufferIdxP2: LyrebirdInt = (iReadHead + 2) & mask
            samples[sampleIdx] = cubicInterp(buffer[bufferIdxM1], y0: buffer[bufferIdx], y1: buffer[bufferIdxP1], y2: buffer[bufferIdxP2], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
}



public class DelayLineFeedback: LyrebirdUGen {
    private final var buffer: [LyrebirdFloat]
    private final let bufferSize: LyrebirdInt // should be a power of 2
    private final let mask: LyrebirdInt
    private final var readHead: LyrebirdFloat = 0.0
    private final var writeHead: LyrebirdInt = 0
    public final var interpolation: DelayInterpolationType
    public final var delayTime: LyrebirdValidUGenInput
    public final var decayTime: LyrebirdValidUGenInput
    private final var lastDelayTime: LyrebirdFloat = 0.0
    public final var input: LyrebirdValidUGenInput
    
    
    public required init(rate: LyrebirdUGenRate,  input: LyrebirdValidUGenInput, delayTime: LyrebirdValidUGenInput, decayTime: LyrebirdValidUGenInput = 0.0, maxDelayTime: LyrebirdFloat = 1.0, interpolation: DelayInterpolationType = .None) {
        self.input = input
        self.delayTime = delayTime
        self.decayTime = decayTime
        self.interpolation = interpolation
        self.bufferSize = LyrebirdInt(nextPowerOfTwo(LyrebirdInt(ceil(Lyrebird.engine.sampleRate * maxDelayTime))))
        self.mask = bufferSize - 1
        self.buffer = [LyrebirdFloat](count: bufferSize, repeatedValue: 0.0)
        super.init(rate: rate)
        self.writeHead = LyrebirdInt(Lyrebird.engine.sampleRate * delayTime.floatValue(graph))
        self.lastDelayTime = self.delayTime.floatValue(graph)
    }
    
    public override final func next(numSamples: LyrebirdInt) -> Bool {
        var success = super.next(numSamples)
        if(success){
            switch self.interpolation {
            case .Linear:
                success = nextLinear(numSamples)
                break
                
            case .None:
                success = nextNone(numSamples)
                break
                
            case .Cubic:
                success = nextCubic(numSamples)
                break
            }
            while readHead > LyrebirdFloat(mask) {
                readHead = readHead - LyrebirdFloat(bufferSize)
            }
            if writeHead > mask {
                writeHead = writeHead & mask
            }
        }
        return success
    }
    
    private final func nextNone(numSamples: LyrebirdInt) -> Bool{
        let inputSamples = input.calculatedSamples(graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead) & mask
            samples[sampleIdx] = buffer[iReadHead]
            let feedbackAmt = feedbackCoef(thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextLinear(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = input.calculatedSamples(graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            samples[sampleIdx] = linearInterp(buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            let feedbackAmt = feedbackCoef(thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    private final func nextCubic(numSamples: LyrebirdInt) -> Bool {
        // TODO:: optimize for non-changing values
        let inputSamples = input.calculatedSamples(graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead)
            let bufferIdxPct: LyrebirdFloat = readHead - fReadHead
            let bufferIdx: LyrebirdInt = iReadHead & mask
            let bufferIdxM1: LyrebirdInt = (iReadHead - 1) & mask
            let bufferIdxP1: LyrebirdInt = (iReadHead + 1) & mask
            let bufferIdxP2: LyrebirdInt = (iReadHead + 2) & mask
            samples[sampleIdx] = cubicInterp(buffer[bufferIdxM1], y0: buffer[bufferIdx], y1: buffer[bufferIdxP1], y2: buffer[bufferIdxP2], pct: bufferIdxPct)
            let feedbackAmt = feedbackCoef(thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
}
