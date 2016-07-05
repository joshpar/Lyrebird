//
//  LyrebirdRandomGenerator.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public class LyrebirdRandomNumberGenerator {
    public var seed: UInt32 = 0 {
        didSet {
            updateSeedGen()
        }
    }
    private var seedGen: [UInt16] = [0, 0, 0]
    
    private func updateSeedGen(){
        var seedArr: [UInt16] = [0, 0, 0]
        for idx in 0...1 {
            seedArr[2 - idx] = UInt16(0x000FFF & seed >> UInt32(idx * 8))
        }
        seedGen = seedArr
    }
    
    public init(initSeed: UInt32? = nil){
        seed = initSeed ?? UInt32(NSDate.timeIntervalSinceReferenceDate())
        updateSeedGen()
    }
    
    public func next() -> LyrebirdFloat {
        return erand48(&seedGen)
    }
}

public class RandWhite {
    private var randGen: LyrebirdRandomNumberGenerator
    var lower: LyrebirdNumber
    var upper: LyrebirdNumber
    var difference: LyrebirdFloat
    
    public init(initSeed: UInt32? = nil, lower: LyrebirdNumber = 0.0, upper: LyrebirdNumber = 1.0){
        randGen = LyrebirdRandomNumberGenerator(initSeed: initSeed)
        self.lower = lower
        self.upper = upper
        self.difference = (upper.numberValue() - lower.numberValue())
    }
    
    public func next() -> LyrebirdNumber {
        return (randGen.next() * difference) + lower.numberValue()
    }
}
