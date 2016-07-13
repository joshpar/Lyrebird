//: Playground - noun: a place where people can play

import Cocoa
import Lyrebird



let a = LyrebirdInt(80)
80.floatValue(nil)
keynum_hz(69.1)
hz_keynum(440)

db_linamp(0)
linamp_db(2.0)

db_linamp(-12.0)

midi_ratio(12.0)
ratio_midi(0.5)

sig_sqrt(-4.0)


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

for (index, value) in arrayToShuffle.enumerate() {
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

scheduler.addEventToQueue(event)
//scheduler.queue

scheduler.updateCurTime(1.0)
scheduler.updateCurTime(2.001)
scheduler.updateCurTime(3.001)
scheduler.updateCurTime(3.001)
scheduler.updateCurTime(3.001)

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


var testUGen = NoiseWhite(rate: LyrebirdUGenRate.Audio)
var start  = NSDate.timeIntervalSinceReferenceDate()

for _ in 0 ..< 1000 {
    testUGen.next(64)
}
var end = NSDate.timeIntervalSinceReferenceDate()

end-start


let white = RandWhite(initSeed: 123)
white.next()
white.next()
white.next()
white.next()
white.next()
white.next()

let segment = Segment(start: 0.0, end: 1.0, curve: 0.0, duration: 1)
start  = NSDate.timeIntervalSinceReferenceDate()

for _ in 0 ..< 1000 {
    segment.pollAtTime(0.5)
}
end = NSDate.timeIntervalSinceReferenceDate()

end-start

start  = NSDate.timeIntervalSinceReferenceDate()
let env = Envelope(levels: [2.0, 0.0, 4.0], durations: [1.0, 2.0, 20.0], curve: 0.0)
env.pollAtTime(2)

for _ in 0 ..< 1000 {
    env.pollAtTime(20.5)
}
end = NSDate.timeIntervalSinceReferenceDate()

end-start




let seg = Segment(start: 2.0, end: 4.0, curve: 0.0, duration: 1.0)
seg.pollAtTime(1.5)

for idx in 1 ... 10 {
    if idx > 5 {
        break
    }
    print("\(idx)")
}
