//
//  LyrebirdTimer.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/5/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public typealias LyrebirdTimerBlock = (curTime: LyrebirdFloat) -> LyrebirdFloat?
public typealias LyrebirdTimerFinalizerBlock = (curTime: LyrebirdFloat) -> LyrebirdFloat?

func delay(delay: Double, queue: dispatch_queue_t, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        queue,
        closure
    )
}

public final class LyrebirdTimer : NSObject {
    public var block: LyrebirdTimerBlock? = nil
    public var finalizerBlock: LyrebirdTimerBlock? = nil
    private var startTime: LyrebirdFloat = -1.0
    private var idString: String = "LyrebirdTimer"
    private var queue: dispatch_queue_t
    
    public convenience override init(){
        self.init(idString: "LyrebirdTimer")
    }
    
    public required init(idString: String){
        self.idString = idString
        queue = dispatch_queue_create(self.idString, DISPATCH_QUEUE_SERIAL)
        super.init()
    }
    
    public final func next() {
        if (startTime < 0.0) {
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
        if let block = block {
            let curTime = NSDate.timeIntervalSinceReferenceDate() - self.startTime
            let nextTime: LyrebirdFloat? = block(curTime: curTime)
            if let nextTime = nextTime {
                delay(nextTime, queue: queue, closure: { self.next() })
            } else {
                finalizerBlock?(curTime: curTime)
            }
        } else {
            finalizerBlock?(curTime: 0.0)
        }
    }
}
