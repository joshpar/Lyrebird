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

// returns a value for a point between y0 and y1

public func cubicInterp(ym1: LyrebirdFloat, y0: LyrebirdFloat, y1: LyrebirdFloat, y2: LyrebirdFloat, pct: LyrebirdFloat) -> LyrebirdFloat
{
    let c0 = y0;
    let c1 = (0.5 * (y1 - ym1));
    let c2 = ym1 - (2.5 * y0) + (2.0 * y1) - (0.5 * y2);
    let c3 = (0.5 * (y2 - ym1)) + (1.5 * (y0 - y1));
    return (((((c3 * pct) + c2) * pct) + c1) * pct) + c0;
}

func calcSlope(startValue: LyrebirdFloat, endValue: LyrebirdFloat) -> LyrebirdFloat {
    return (endValue - startValue) * Lyrebird.engine.iBlockSize
}

func calcSlope(startValue: LyrebirdFloat, endValue: LyrebirdFloat, numSamples: LyrebirdFloat) -> LyrebirdFloat {
    if numSamples != 0.0 {
        return (endValue - startValue) / numSamples
    } else {
        return 0.0
    }
}

func interpolatedSampleBlock(startValue: LyrebirdFloat, endValue: LyrebirdFloat) -> [LyrebirdFloat] {
    var start: LyrebirdFloat = startValue
    let blockSize: LyrebirdInt = Lyrebird.engine.blockSize
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



public func db_linamp(db: LyrebirdFloat) -> LyrebirdFloat {
    return pow(10.0, db * 0.05)
}

public func linamp_db(linamp: LyrebirdFloat) -> LyrebirdFloat {
    return log10(linamp) * 20.0
}

public func keynum_hz(keynum: LyrebirdFloat) -> LyrebirdFloat {
    return 440.0 * pow(2.0, (keynum - 69.0) * 0.08333333333333333333333333)
}

public func hz_keynum(hz: LyrebirdFloat) -> LyrebirdFloat {
    return (log2(hz * 0.002272727272727272727272727) * 12.0) + 69.0;
}

public func midi_ratio(midi: LyrebirdFloat) -> LyrebirdFloat {
    return pow(2.0, midi * 0.08333333333333333333333333);
}

public func ratio_midi(ratio: LyrebirdFloat) -> LyrebirdFloat {
    return 12.0 * log2(ratio)
}

public func reciprocal(value: LyrebirdFloat) -> LyrebirdFloat {
    return 1.0 / value
}

public func isPowerOfTwo(value: LyrebirdInt) -> Bool {
    let nextPowTwo = nextPowerOfTwo(value)
    return value == nextPowTwo
}

public func nextPowerOfTwo(value: LyrebirdInt) -> LyrebirdInt {
    let n = LyrebirdFloat(value)
    let nextPowTwo = pow(2, ceil(log2(n)))
    return LyrebirdInt(nextPowTwo)
}

// MARK: functions to work on audio values and signals (retain sign for negative values)

public func sig_sqrt(value: LyrebirdFloat) -> LyrebirdFloat {
    if value >= 0.0 {
        return sqrt(value)
    } else {
        return -sqrt(-value)
    }
}
