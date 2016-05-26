//
//  MathUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/19/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public class BinaryOpUGen : LyrebirdUGen {
    let lhs: LyrebirdValidUGenInput
    let rhs: LyrebirdValidUGenInput

    public required init(rate: LyrebirdUGenRate, lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput){
        self.lhs = lhs
        self.rhs = rhs
        super.init(rate: rate)
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, lhs: 0.0, rhs: 0.0)
    }
    
}

// math support

public func * (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return MulOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

public func / (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return DivOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

public func - (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return SubOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

public func + (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return AddOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}


public class MulOpUGen : BinaryOpUGen {
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wireForIndex(0){
                
                let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
                let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
                for (index, currentSampleValue) in lhsSamples.enumerate() {
                    wire.currentSamples[index] = currentSampleValue * rhsSamples[index]
                }
            }
        }
        return success
    }
}

public class DivOpUGen : BinaryOpUGen {
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wireForIndex(0){
                
                let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
                let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
                for (index, currentSampleValue) in lhsSamples.enumerate() {
                    let divisor = rhsSamples[index]
                    if divisor != 0.0 {
                        wire.currentSamples[index] = currentSampleValue * rhsSamples[index]
                    } else {
                        wire.currentSamples[index] = 0.0
                    }
                }
            }
        }
        return success
    }
}

public class AddOpUGen : BinaryOpUGen {
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wireForIndex(0){
                
                let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
                let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
                for (index, currentSampleValue) in lhsSamples.enumerate() {
                    wire.currentSamples[index] = currentSampleValue + rhsSamples[index]
                }
            }
        }
        return success
    }
}

public class SubOpUGen : BinaryOpUGen {
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        var success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wireForIndex(0){
                
                let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
                let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
                for (index, currentSampleValue) in lhsSamples.enumerate() {
                    wire.currentSamples[index] = currentSampleValue - rhsSamples[index]
                }
            }
        }
        return success
    }
}