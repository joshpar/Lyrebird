//: Playground - noun: a place where people can play

import Cocoa
import Lyrebird
import LyrebirdSynthLang

var str = "Hello, playground"

var test: Int8 = 10
test = 127


var param: [String:Float] = ["test": 1.0]
param["missing"]
param["missing"] = 10


for i in 0 ..< 10 {
    i
}

var testFloat: LyrebirdFloat = pow(2, 6128)

var result: Float = 0.0

