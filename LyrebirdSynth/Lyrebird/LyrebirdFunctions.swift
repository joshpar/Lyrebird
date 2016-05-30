//
//  LyrebirdFunctions.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/4/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

func linearInterp(x1: LyrebirdFloat, x2: LyrebirdFloat, pct: LyrebirdFloat) -> LyrebirdFloat {
    return x1 + ((x2 - x1) * pct)
}

func calcSlope(startValue: LyrebirdFloat, endValue: LyrebirdFloat) -> LyrebirdFloat {
    return (endValue - startValue) * LyrebirdEngine.engine.iBlockSize
}

func sineLookup(sampleIdx: LyrebirdFloat, mask: LyrebirdInt, table: [LyrebirdFloat]) -> LyrebirdFloat {
    let floorIdx: LyrebirdFloat = floor( sampleIdx)
    let iIndexOne: LyrebirdInt = LyrebirdInt( floorIdx ) & mask
    let iIndexTwo: LyrebirdInt = LyrebirdInt( ceil( sampleIdx) ) & mask
    let pct: LyrebirdFloat = sampleIdx - floorIdx
    let valOne = table[iIndexOne]
    let valTwo = table[iIndexTwo]
    let returnVal = linearInterp(valOne, x2: valTwo, pct: pct)
    return returnVal
}
