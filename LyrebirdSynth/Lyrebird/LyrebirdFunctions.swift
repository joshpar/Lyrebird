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

func interpolatedSampleBlock(startValue: LyrebirdFloat, endValue: LyrebirdFloat) -> [LyrebirdFloat] {
    var start: LyrebirdFloat = startValue
    let blockSize: LyrebirdInt = LyrebirdEngine.engine.blockSize
    if(startValue == endValue){
        let block: [LyrebirdFloat] = [LyrebirdFloat](count: blockSize, repeatedValue: startValue )
        return block
    }
    var block: [LyrebirdFloat] = [LyrebirdFloat](count: blockSize, repeatedValue: 0.0 )
    let slope = calcSlope(startValue, endValue: endValue)
    for idx in 0 ..< blockSize {
        start = start + slope
        block[idx] = start
    }
    return block
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



