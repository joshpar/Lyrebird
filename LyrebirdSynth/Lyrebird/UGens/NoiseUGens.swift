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
}

public class NoiseWhite: NoiseGen {
    
    public required init(rate: LyrebirdUGenRate){
        super.init(rate: rate)
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
