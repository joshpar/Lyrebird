//
//  MathUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/19/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

/**
 The basic UGen used for binary math operations on other UGens. Since math on UGens needs to operate on the samples in a wire, special UGens for accessing the samples or interpolating for changing values across control periods is needed
 */
public class BinaryOpUGen : LyrebirdUGen {
    /// ---
    /// The left hand side of the operation
    ///
    let lhs: LyrebirdValidUGenInput
    /// ---
    /// The right hand side of the operation
    ///
    let rhs: LyrebirdValidUGenInput
    /// ---
    /// TODO:: to be changed later as multi-channel expansion comes into play with wires
    ///
    var wire: LyrebirdWire?
    
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
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, lhs: 0.0, rhs: 0.0)
    }
}


/**
 multiply function that translates the '*' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
*/

public func * (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return MulOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

/**
 addition function that translates the '+' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func + (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return AddOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

/**
 division function that translates the '/' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func / (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return DivOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
}

/**
 subtraction function that translates the '-' operator into a Binary Op UGen
 
 - parameter lhs: left hand side of the operation
 - parameter rhs: right hand side of the operation
 
 - Returns: The resulting MulOpUGen
 */

public func - (lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput) -> BinaryOpUGen {
    return SubOpUGen(rate: LyrebirdUGenRate.Audio, lhs: lhs, rhs: rhs)
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
        let success: Bool = super.next(numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
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

public class DivOpUGen : BinaryOpUGen {

    /**
     DivOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */

    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
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

public class AddOpUGen : BinaryOpUGen {

    /**
     AddOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
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

public class SubOpUGen : BinaryOpUGen {
    
    /**
     SubOpUGen next that calculates a new wire with the result of the input's wires values for this operation
     
     - parameter numSamples: the number of samples to calculate
     
     - Returns: boolean with success
     */
    
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let lhsSamples: [LyrebirdFloat] = lhs.calculatedSamples(self.graph)[0]
            let rhsSamples: [LyrebirdFloat] = rhs.calculatedSamples(self.graph)[0]
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

public class UnaryOpUGen : LyrebirdUGen {
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
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, input: 0.0)
    }
}

/**
 The absolute value implementation for UGen math operations
 */

public class Abs : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Negative : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Sin : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Cos : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Tan : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Atan : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Asin : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Acos : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Sinh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Cosh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Tanh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Squared : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class SigSquared : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
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

public class Cubed : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
            for index in 0 ..< numSamples {
                let val = inputSamples[index]
                samples[index] = val * val * val
            }
        }
        return success
    }
}
