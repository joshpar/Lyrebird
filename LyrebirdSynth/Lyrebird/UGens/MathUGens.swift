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
    var wire: LyrebirdWire?
    
    public required init(rate: LyrebirdUGenRate, lhs: LyrebirdValidUGenInput, rhs: LyrebirdValidUGenInput){
        self.lhs = lhs
        self.rhs = rhs
        super.init(rate: rate)
        self.wire = wireForIndex(0)
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
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
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
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
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
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
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
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
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

public class UnaryOpUGen : LyrebirdUGen {
    let input: LyrebirdValidUGenInput
    var wire: LyrebirdWire?
    
    public required init(rate: LyrebirdUGenRate, input: LyrebirdValidUGenInput){
        self.input = input
        super.init(rate: rate)
        self.wire = wireForIndex(0)
    }
    
    public required convenience init(rate: LyrebirdUGenRate){
        self.init(rate: rate, input: 0.0)
    }
}

public class Abs : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = fabs(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Negative : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = -inputSamples[index]
                }
            }
        }
        return success
    }
}

public class Sin : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = sin(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Cos : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = cos(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Tan : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = tan(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Atan : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = atan(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Asin : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = asin(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Acos : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = acos(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Sinh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = sinh(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Cosh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = cosh(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Tanh : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    wire.currentSamples[index] = tanh(inputSamples[index])
                }
            }
        }
        return success
    }
}

public class Squared : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    let val = inputSamples[index]
                    wire.currentSamples[index] = val * val
                }
            }
        }
        return success
    }
}

public class Cubed : UnaryOpUGen {
    public override func next(numSamples: LyrebirdInt) -> Bool {
        let success: Bool = super.next(numSamples)
        if(success){
            if let wire: LyrebirdWire = wire {
                let inputSamples: [LyrebirdFloat] = input.calculatedSamples(self.graph)[0]
                for index in 0 ..< numSamples {
                    let val = inputSamples[index]
                    wire.currentSamples[index] = val * val * val 
                }
            }
        }
        return success
    }
}
