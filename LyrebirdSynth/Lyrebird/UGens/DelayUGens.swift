//
//  DelayUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 7/16/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum DelayInterpolationType {
    case none, linear, cubic
}

open class DelayLine: LyrebirdUGen {
    fileprivate final var buffer: [LyrebirdFloat]
    fileprivate final let bufferSize: LyrebirdInt // should be a power of 2
    fileprivate final let mask: LyrebirdInt
    fileprivate final var readHead: LyrebirdFloat = 0.0
    fileprivate final var writeHead: LyrebirdInt = 0
    public final var interpolation: DelayInterpolationType
    public final var delayTime: LyrebirdValidUGenInput
    fileprivate final var lastDelayTime: LyrebirdFloat = 0.0
    public final var input: LyrebirdValidUGenInput
    
    
    public required init(rate: LyrebirdUGenRate,  input: LyrebirdValidUGenInput, delayTime: LyrebirdValidUGenInput, maxDelayTime: LyrebirdFloat = 1.0, interpolation: DelayInterpolationType = .none) {
        self.input = input
        self.delayTime = delayTime
        self.interpolation = interpolation
        self.bufferSize = LyrebirdInt(nextPowerOfTwo(value: LyrebirdInt(ceil(Lyrebird.engine.sampleRate * maxDelayTime))))
        self.mask = bufferSize - 1
        self.buffer = [LyrebirdFloat](repeating: 0.0, count: bufferSize)
        super.init(rate: rate)
        self.writeHead = LyrebirdInt(Lyrebird.engine.sampleRate * delayTime.floatValue(graph: graph))
        self.lastDelayTime = self.delayTime.floatValue(graph: graph)
    }
    
    public override final func next(numSamples: LyrebirdInt) -> Bool {
        var success = super.next(numSamples: numSamples)
        if(success){
            switch self.interpolation {
            case .linear:
                success = nextLinear(numSamples: numSamples)
                break
                
            case .none:
                success = nextNone(numSamples: numSamples)
                break
                
            case .cubic:
                success = nextCubic(numSamples: numSamples)
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
    
    fileprivate final func nextNone(numSamples: LyrebirdInt) -> Bool{
        let inputSamples = self.input.calculatedSamples(graph: graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph: graph)[0]
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
    
    fileprivate final func nextLinear(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph: graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph: graph)[0]
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
            samples[sampleIdx] = linearInterp(x1: buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    fileprivate final func nextCubic(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = self.input.calculatedSamples(graph: graph)[0]
        let delayTimes = self.delayTime.calculatedSamples(graph: graph)[0]
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
            samples[sampleIdx] = cubicInterp(ym1: buffer[bufferIdxM1], y0: buffer[bufferIdx], y1: buffer[bufferIdxP1], y2: buffer[bufferIdxP2], pct: bufferIdxPct)
            buffer[writeHead & mask] = inputSamples[sampleIdx]
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
}



open class DelayLineFeedback: LyrebirdUGen {
    fileprivate final var buffer: [LyrebirdFloat]
    fileprivate final let bufferSize: LyrebirdInt // should be a power of 2
    fileprivate final let mask: LyrebirdInt
    fileprivate final var readHead: LyrebirdFloat = 0.0
    fileprivate final var writeHead: LyrebirdInt = 0
    public final var interpolation: DelayInterpolationType
    public final var delayTime: LyrebirdValidUGenInput
    public final var decayTime: LyrebirdValidUGenInput
    fileprivate final var lastDelayTime: LyrebirdFloat = 0.0
    public final var input: LyrebirdValidUGenInput
    
    
    public required init(rate: LyrebirdUGenRate,  input: LyrebirdValidUGenInput, delayTime: LyrebirdValidUGenInput, decayTime: LyrebirdValidUGenInput = 0.0, maxDelayTime: LyrebirdFloat = 1.0, interpolation: DelayInterpolationType = .none) {
        self.input = input
        self.delayTime = delayTime
        self.decayTime = decayTime
        self.interpolation = interpolation
        self.bufferSize = LyrebirdInt(nextPowerOfTwo(value: LyrebirdInt(ceil(Lyrebird.engine.sampleRate * maxDelayTime))))
        self.mask = bufferSize - 1
        self.buffer = [LyrebirdFloat](repeating: 0.0, count: bufferSize)
        super.init(rate: rate)
        self.writeHead = LyrebirdInt(Lyrebird.engine.sampleRate * delayTime.floatValue(graph: graph))
        self.lastDelayTime = self.delayTime.floatValue(graph: graph)
    }
    
    public override final func next(numSamples: LyrebirdInt) -> Bool {
        var success = super.next(numSamples: numSamples)
        if(success){
            switch self.interpolation {
            case .linear:
                success = nextLinear(numSamples:  numSamples)
                break
                
            case .none:
                success = nextNone(numSamples:  numSamples)
                break
                
            case .cubic:
                success = nextCubic(numSamples:  numSamples)
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
    
    fileprivate final func nextNone( numSamples: LyrebirdInt) -> Bool{
        let inputSamples = input.calculatedSamples(graph: graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph: graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph: graph)[0]
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            let thisDelayTime = delayTimes[sampleIdx]
            let delayDiff = thisDelayTime - lastDelayTime
            lastDelayTime = thisDelayTime
            readHead = readHead + (delayDiff * Lyrebird.engine.sampleRate)
            let fReadHead: LyrebirdFloat = floor(readHead)
            let iReadHead: LyrebirdInt = LyrebirdInt(fReadHead) & mask
            samples[sampleIdx] = buffer[iReadHead]
            let feedbackAmt = feedbackCoef(delayTime: thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    fileprivate final func nextLinear(numSamples: LyrebirdInt) -> Bool {
        let inputSamples = input.calculatedSamples(graph: graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph: graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph: graph)[0]
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
            samples[sampleIdx] = linearInterp(x1: buffer[bufferIdx], x2: buffer[bufferIdxP1], pct: bufferIdxPct)
            let feedbackAmt = feedbackCoef(delayTime: thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
    
    fileprivate final func nextCubic(numSamples: LyrebirdInt) -> Bool {
        // TODO:: optimize for non-changing values
        let inputSamples = input.calculatedSamples(graph: graph)[0]
        let delayTimes = delayTime.calculatedSamples(graph: graph)[0]
        let decayTimes = decayTime.calculatedSamples(graph: graph)[0]
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
            samples[sampleIdx] = cubicInterp(ym1: buffer[bufferIdxM1], y0: buffer[bufferIdx], y1: buffer[bufferIdxP1], y2: buffer[bufferIdxP2], pct: bufferIdxPct)
            let feedbackAmt = feedbackCoef(delayTime: thisDelayTime, decayTime: decayTimes[sampleIdx], targetAmp: 0.001)
            buffer[writeHead & mask] = inputSamples[sampleIdx] + (samples[sampleIdx] * feedbackAmt)
            readHead = readHead + 1.0
            writeHead = writeHead + 1
        }
        return true
    }
}
