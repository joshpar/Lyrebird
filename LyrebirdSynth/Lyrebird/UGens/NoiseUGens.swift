//
//  NoiseUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public class NoiseGen : LyrebirdUGen {
    private var ranGen: LyrebirdRandomNumberGenerator = LyrebirdRandomNumberGenerator(initSeed: 0)
    public var seed: LyrebirdInt = 0 {
        didSet {
            ranGen.seed = UInt32(seed)
        }
    }
    
    static func dateSeed() -> LyrebirdInt {
        return LyrebirdInt(NSDate.timeIntervalSinceReferenceDate())
    }
}

public class NoiseWhite: NoiseGen {
    
    public required init(rate: LyrebirdUGenRate, seed: LyrebirdInt){
        super.init(rate: rate)
        self.seed = seed
    }
    
    required public convenience init(rate: LyrebirdUGenRate) {
        self.init(rate: rate, seed: NoiseGen.dateSeed())
    }
    
    override public func next(numSamples: LyrebirdInt) -> Bool {
        // get the audio wire to output
        guard let wire: LyrebirdWire = wireForIndex(0) else {
            return false
        }
        
        for sampleIdx: LyrebirdInt in 0 ..< numSamples {
            wire.currentSamples[sampleIdx] = ranGen.next()
        }
        
        return true
    }
}
