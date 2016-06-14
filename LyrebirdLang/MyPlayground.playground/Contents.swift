//: Playground - noun: a place where people can play

import Cocoa
import Lyrebird
import LyrebirdSynthLang

var str = "Hello, playground"

var test: Int8 = 10
test = 127


var param: [String:Float?] = ["test": 1.0]
param["missing"]
param["missing"] = 10
param["missing"] = nil
param.count
param["missing"] = 10
param["missing"]
param.count


var testFloat: LyrebirdFloat = pow(2, 610)

var result: Float = 0.0


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
