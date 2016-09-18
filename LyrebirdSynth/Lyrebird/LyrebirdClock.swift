//
//  LyrebirdClock.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/10/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public let LyrebirdDefaultClockResolution: LyrebirdFloat = 0.01

public struct LyrebirdScheduler {
    var curTime: LyrebirdFloat
    public var queue: [LyrebirdScheduledEvent]

    public init(){
        curTime = 0.0
        queue = []
    }
    
    public mutating func updateCurTime(newCurTime: LyrebirdFloat) {
        curTime = newCurTime
        var indiciesToRemove: [Int] = []
        if queue.count > 0 {
            for index in 0 ..< queue.count {
                var event = queue[index]
                if curTime > event.startTime! {
                    event.run(curTime: curTime)
                    if let nextTime = event.nextTime {
                        event.startTime = curTime + nextTime
                    } else {
                        indiciesToRemove.append(index)
                    }
                }
            }
            for index in indiciesToRemove {
                queue.remove(at: index)
            }
        }
        //print("\(queue)")
    }
    
    public mutating func addEventToQueue(event: LyrebirdScheduledEvent) {
        queue.append(event)
    }
}


public typealias LyrebirdEventBlock = (_ curTime: LyrebirdFloat, _ iteration: LyrebirdInt) -> LyrebirdFloat?

public struct LyrebirdScheduledEvent {
    public var startTime: LyrebirdFloat?
    var nextTime: LyrebirdFloat?
    var eventBlock: LyrebirdEventBlock
    public var iteration: LyrebirdInt
    
    public init(startTime: LyrebirdFloat, eventBlock: @escaping LyrebirdEventBlock){
        iteration = 0
        self.startTime = startTime
        self.eventBlock = eventBlock
    }
    
    mutating func run(curTime: LyrebirdFloat){
        nextTime = eventBlock(curTime, iteration)
        iteration = iteration + 1
    }
}
