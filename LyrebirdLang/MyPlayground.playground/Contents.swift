//: Playground - noun: a place where people can play

import Cocoa
import Lyrebird


exp((log( 0.001 ) * 0.2) / 1.0)


isPowerOfTwo(value: 127)

nextPowerOfTwo(value: 128)

cubicInterp(ym1: 10.0, y0: 2.0, y1: 0.0, y2: 1.0, pct: 0.0)

let a = LyrebirdInt(80)
80.floatValue(graph: nil)
keynum_hz(keynum: 69.1)
hz_keynum(hz: 440)

db_linamp(db: 0)
linamp_db(linamp: 2.0)

db_linamp(db: -12.0)

midi_ratio(midi: 12.0)
ratio_midi(ratio: 0.5)

sig_sqrt(value: -4.0)


var array = [1, 2, 3]
var array2 = array
array2[2] = 300

print("\(array, array2)")


var list = LoopingSequence(list: [0.0, 1.1, 2.2, 3.3], repeats: 1)
list.next()
list.next()
list.next()
list.next()
list.next()
list.next()
list.reset()
list.next()
list.next()
list.next()
list.next()
list.next()
list.next()
list.next()
list.next()
list.next()


var arrayToShuffle = [1, 2, 3, 4, 5, 6];

for (index, value) in arrayToShuffle.enumerated() {
    print("\(value)")
}


var z = LyrebirdRandomNumberGenerator(initSeed: 123)
z.next()


var scheduler = LyrebirdScheduler()
let event = LyrebirdScheduledEvent(startTime: 2.0) { (curTime, iteration) -> LyrebirdFloat? in
    print("\(curTime, iteration)")
    if iteration < 10 {
        return 1.0
    }
    return nil
}

scheduler.addEventToQueue(event: event)
//scheduler.queue

scheduler.updateCurTime(newCurTime: 1.0)
scheduler.updateCurTime(newCurTime: 2.001)
scheduler.updateCurTime(newCurTime: 3.001)
scheduler.updateCurTime(newCurTime: 3.001)
scheduler.updateCurTime(newCurTime: 3.001)

event.iteration

struct TestMe {
    var array: [Int]
    init(array: [Int]){
        self.array = array
    }
    
    mutating func updateArray(){
        var newArray: [Int] = []
        for val: Int in array {
            newArray.append(val + 2)
            }
        array = newArray
    }
}

var testMe: TestMe = TestMe(array: [0, 1, 2, 3])
testMe.array
testMe.updateArray()
testMe.array
testMe.updateArray()
testMe.array

var testMe2: TestMe = TestMe(array: testMe.array)
testMe.array
testMe2.array
testMe2.updateArray()

testMe.array
testMe2.array
testMe2.updateArray()
testMe2.array

var testMe3 = testMe2
testMe2.updateArray()
testMe2.array

testMe3.array


var testUGen = NoiseWhite(rate: LyrebirdUGenRate.audio)
var start  = Date.timeIntervalSinceReferenceDate

for _ in 0 ..< 1000 {
    testUGen.next(numSamples: 64)
}
var end = Date.timeIntervalSinceReferenceDate

end-start


let white = RandWhite(initSeed: 123)
white.next()
white.next()
white.next()
white.next()
white.next()
white.next()

let segment = Segment(start: 0.0, end: 1.0, curve: 0.0, duration: 1)
start  = NSDate.timeIntervalSinceReferenceDate

for _ in 0 ..< 1000 {
    segment.poll(atTime: 0.5)
}
end = NSDate.timeIntervalSinceReferenceDate

end-start

start  = NSDate.timeIntervalSinceReferenceDate
let env = Envelope(levels: [2.0, 0.0, 4.0], durations: [1.0, 2.0, 20.0], curve: 0.0)
env.poll(atTime: 2)


for _ in 0 ..< 1000 {
    feedbackCoef(delayTime: 0.1, decayTime: 10.0, targetAmp: 0.001)
    feedbackCoef(delayTime: 0.1, decayTime: 10.0, targetDB: -60.0)
}

end = NSDate.timeIntervalSinceReferenceDate

end-start




let seg = Segment(start: 2.0, end: 4.0, curve: 0.0, duration: 1.0)
seg.poll(atTime: 1.5)

for (index, idx) in (1 ... 10).enumerated() {
    if idx > 5 {
        break
    }
    print("\(index, idx)")
}
