//
//  MathUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/19/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

/**
 The basic UGen used for binary math operations on other UGens. Since math on UGens needs to operate on the samples in a wire, special UGens for accessing the samples or interpolating for changing values across control periods is needed
 */
open class BinaryOpUGen : LyrebirdUGen {
    /// ---
    /// The left hand side of the operation
    ///
    let lhs: LyrebirdValidUGenInput
    /// ---
    /// The right hand side of the operation
    ///
    let rhs: LyrebirdValidUGenInput
    
    /**
     init for all BinaryOpUGens
     
     - parameter rate: LyrebirdUGenRate to run the unit at
     - parameter lhs: left hand side of the operation
     - parameter rhs: right hand side of the operation
     
     - Returns: An instance of a BinaryOpUGen - the result of the operation is stored in the UGen's wire
     */

    public required init(rate: LyrebirdUGenRate, lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput){
        self.lhs = lhs
        self.rhs = rhs
        super.init(rate: rate)
    }
    
//    public required convenience init(rate: LyrebirdUGenRate){
//        self.init(rate: rate, lhs: 0.0, rhs: 0.0)
//    }
}


/**
 multiply function that translates the '*' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
*/

public func * (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return MulOpUGen(rate: LyrebirdUGenRate.audio, lhs: lhs, rhs: rhs)
}

/**
 addition function that translates the '+' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func + (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return AddOpUGen(rate: LyrebirdUGenRate.audio, lhs: lhs, rhs: rhs)
}

/**
 division function that translates the '/' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func / (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return DivOpUGen(rate: LyrebirdUGenRate.audio, lhs: lhs, rhs: rhs)
}

/**
 subtraction function that translates the '-' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func - (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return SubOpUGen(rate: LyrebirdUGenRate.audio, lhs: lhs, rhs: rhs)
}


/**
 The multiply implementation for UGen math operations
 */

public final class MulOpUGen : BinaryOpUGen {
    
    /**
     MulOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */

    public override final func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(graph: graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(graph: graph)[0]
            for index in 0 ..< lhsSamples.count {
                samples[index] = lhsSamples[index] * rhsSamples[index]
            }
        }
        return success
    }
}

/**
 The division implementation for UGen math operations
 */

open class DivOpUGen : BinaryOpUGen {

    /**
     DivOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */

    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(graph: graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(graph: graph)[0]
            for index in 0 ..< lhsSamples.count {
                let divisor = rhsSamples[index]
                if divisor != 0.0 {
                    samples[index] = lhsSamples[index] / rhsSamples[index]
                } else {
                    samples[index] = 0.0
                }
            }
        }
        return success
    }
}

/**
 The addition implementation for UGen math operations
 */

open class AddOpUGen : BinaryOpUGen {

    /**
     AddOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */
    
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(graph: graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(graph: graph)[0]
            for index in 0 ..< lhsSamples.count {
                samples[index] = lhsSamples[index] + rhsSamples[index]
            }
        }
        return success
    }
}


/**
 The subtraction implementation for UGen math operations
 */

open class SubOpUGen : BinaryOpUGen {
    
    /**
     SubOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */
    
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(graph: graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(graph: graph)[0]
            for index in 0 ..< lhsSamples.count {
                samples[index] = lhsSamples[index] - rhsSamples[index]
            }
        }
        return success
    }
}

/**
 The basic UGen used for unary math operations on other UGens. Since math on UGens needs to operate on the samples in a wire, special UGens for accessing the samples or interpolating for changing values across control periods is needed
 */

open class UnaryOpUGen : LyrebirdUGen {
    /// ---
    /// The LyrebirdValidUGenInput input to operate on
    ///
    let input: LyrebirdValidUGenInput
    
    /**
     init for all BinaryOpUGens
     
     - parameter rate: LyrebirdUGenRate to run the unit at
     - parameter input: The UGen to get values from
     
     - Returns: An instance of a BinaryOpUGen - the result of the operation is stored in the UGen's wire
     */
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput){
        self.input = input
        super.init(rate: rate)
    }
}

/**
 The absolute value implementation for UGen math operations
 */

open class Abs : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = fabs(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The negation operation (value * -1) implementation for UGen math operations
 */

open class Negative : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = -inputSamples[index]
            }
        }
        return success
    }
}

/**
 The sin(x) implementation for UGen math operations
 */

open class Sin : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = sin(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The cos(x) implementation for UGen math operations
 */

open class Cos : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = cos(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The tan(x) implementation for UGen math operations
 */

open class Tan : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = tan(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The atan(x) (arc tan) implementation for UGen math operations
 */

open class Atan : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = atan(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The asin(x) (arc sine) implementation for UGen math operations
 */

open class Asin : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = asin(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The acos(x) (arc cosine) implementation for UGen math operations
 */

open class Acos : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = acos(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The sinh(x) (hyperbolic sine) implementation for UGen math operations
 */

open class Sinh : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = sinh(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The cosh(x) (hyperbolic cosine) implementation for UGen math operations
 */

open class Cosh : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = cosh(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The tanh(x) (hyperbolic tan) implementation for UGen math operations
 */

open class Tanh : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                samples[index] = tanh(inputSamples[index])
            }
        }
        return success
    }
}

/**
 The squaring implementation for UGen math operations
 */

open class Squared : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                samples[index] = val * val
            }
        }
        return success
    }
}

/**
 The squaring implementation for UGen math operations where sign is retained
 */

open class SigSquared : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                let sign: LyrebirdFloat = val < 0.0 ? -1.0 : 1.0
                samples[index] = (val * val) * sign
            }
        }
        return success
    }
}

/**
 The cubing implementation for UGen math operations where sign is retained
 */

open class Cubed : UnaryOpUGen {
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                samples[index] = val * val * val
            }
        }
        return success
    }
}


open class Range : LyrebirdUGen {
    let input: LyrebirdValidUGenInput
    
    var low: LyrebirdValidUGenInput
    fileprivate var lastLow: LyrebirdFloat = 0.0
    
    var high: LyrebirdValidUGenInput
    fileprivate var lastHigh: LyrebirdFloat = 0.0
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, low: LyrebirdValidUGenInput, high: LyrebirdValidUGenInput){
        self.input = input
        self.low = low
        self.high = high
        super.init(rate: rate)
        self.lastLow = low.floatValue(graph: graph)
        self.lastHigh = high.floatValue(graph: graph)
    }
    
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            let highSamples = high.calculatedSamples(graph: graph)[0]
            let lowSamples = low.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                let newHigh = highSamples[index]
                let newLow = lowSamples[index]
                let scaler = (newHigh - newLow) * 0.5 // TODO:: assuming bipolar
                let offset = newLow;
                samples[index] = (val * scaler) + offset
            }
        }
        return success
    }
}

open class MulAdd : LyrebirdUGen {
    let input: LyrebirdValidUGenInput
    
    var mul: LyrebirdValidUGenInput
    var add: LyrebirdValidUGenInput
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput, mul: LyrebirdValidUGenInput, add: LyrebirdValidUGenInput){
        self.input = input
        self.mul = mul
        self.add = add
        super.init(rate: rate)
    }
    
    open override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples: numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(graph: graph)[0]
            let mulSamples = mul.calculatedSamples(graph: graph)[0]
            let addSamples = add.calculatedSamples(graph: graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                let scaler = mulSamples[index]
                let offset = addSamples[index]
                samples[index] = (val * scaler) + offset
            }
        }
        return success
    }
}
