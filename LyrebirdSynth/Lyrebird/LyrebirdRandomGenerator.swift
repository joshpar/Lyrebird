//
//  LyrebirdRandomGenerator.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public struct LyrebirdRandomNumberGenerator {
    public var seed: UInt32 = 0 {
        didSet {
            updateSeedGen()
        }
    }
    private var seedGen: [UInt16] = [0, 0, 0]
    
    mutating private func updateSeedGen(){
        var seedArr: [UInt16] = [0, 0, 0]
        for idx in 0...1 {
            seedArr[2 - idx] = UInt16(0x000FFF & seed >> UInt32(idx * 8))
        }
        seedGen = seedArr
    }
    
    public init(initSeed: UInt32){
        seed = initSeed
        updateSeedGen()
    }
    
    mutating public func next() -> LyrebirdFloat {
        return erand48(&seedGen)
    }
}
