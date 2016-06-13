//
//  LyrebirdTimer.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/5/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

/**
 A function wrapper for queued delays
 
 - parameter delay: in Seconds
 - parameter queue: the dispatch queue to schedule on 
 - parameter closure: the block to evaluate
 
 - Returns: nothing

 */

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

/**
 The block structure used for LyrebirdTimer's repeated function.
 Well, crap, this needs to be clock independant - so it can be scheduled on RT and NRT fashions. crap crap crap
 - parameter curTime: The current time, in seconds, since execution of the timer began
 - parameter inc: The number of times (0 based) that the timer has executed this block
 
 - Returns: Optional LyrebirdFloat in seconds. If the block returns a value greater than 0.0, execution of the block is scheduled for repeition
 */

public typealias LyrebirdTimerBlock = (curTime: LyrebirdFloat, inc: LyrebirdInt) -> LyrebirdFloat?

/**
 The block structure used for LyrebirdTimer's finalizer function. This block is fired once and only once as the LyrebirdTimerBlock either returns nil or <= 0.0 for repeptiion, or when the block is removed
 
 - parameter curTime: The current time, in seconds, since execution of the timer began
 
 - Returns: Nothing
 */

public typealias LyrebirdTimerFinalizerBlock = (curTime: LyrebirdFloat) -> Void

/**
 The base class for handling timed and repeated execution of a block
 */

public final class LyrebirdTimer {
    /// ---
    /// the closure the execute every time the timer runs. If the optional return is a float > 0.0, repeition is scheduled for that time in seconds
    ///
    
    public var block: LyrebirdTimerBlock? = nil
    
    /// ---
    /// a closure to be executed when no repetitions are scheduled OR if the block has been removed from this instance of a LyrebirdTimer
    ///
    public var finalizerBlock: LyrebirdTimerFinalizerBlock? = nil
    
    /// ---
    /// The time in seconds to delay the start of the timer execution.
    ///
    /// Note: This time is NOT included in the curTime value passed in to a LyrebirdTimerBlock
    public var delayStartTime: LyrebirdFloat = 0.0
    
    /// ---
    /// The internal start time for the execution of the first iteration of the block
    ///
    private var startTime: LyrebirdFloat = -1.0
    
    /// ---
    /// The name of this instance's thread that is visible in stack traces and debugging
    ///
    private var idString: String = "LyrebirdTimer"

    /// ---
    /// The queue for this thread.
    ///
    /// Note: LyrebirdTimer threads are concurrent.
    private var queue: dispatch_queue_t
    
    /// ---
    /// Internal keeper for the number of iterations of the block that have been performed.
    ///
    /// Note: The incrementer is zero based
    private var inc: LyrebirdInt = 0
    
    /// ---
    /// A time stamp to compare to actual execution time. Differences between this and actual time will be removed during scheduling of the next repeition
    ///
    private var nextExpectedTime: LyrebirdFloat = 0.0
    
    /**
     Convenience init that uses a 0.0 delay time and a default idString
     
     - parameter none:
    */

    public convenience init(){
        self.init(delayStartTime: 0.0, idString: "LyrebirdTimer")
    }
    
    /**
     Custom init that uses a given delay time and a custom idString
     
     - parameter delayStartTime: in seconds, the initial amount of time to wait before performing blocks
     - parameter idString: a custom identifier that helps find a thread in debugging tools or stack traces
     
     Note: the delayStartTime is NOT included in the curTime values passed into the blocks that are run. curTime starts at 0.0
     */
    
    public required init(delayStartTime: LyrebirdFloat, idString: String){
        self.idString = idString
        self.delayStartTime = delayStartTime
        queue = dispatch_queue_create(self.idString, DISPATCH_QUEUE_CONCURRENT)
        let q: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        dispatch_set_target_queue(queue, q)
    }
    
    /**
     Starts execution of the timer. The first block will be performed after any delayStartTime
     
     - parameter none:
     */

    
    public final func run() {
        delay(self.delayStartTime, queue: queue) { 
            if (self.startTime < 0.0) {
                self.startTime = NSDate.timeIntervalSinceReferenceDate()
                self.nextExpectedTime = 0.0
            }
            self.next()
        }
    }
    
    /**
     The internal method that the internal thread fires over again. If a block returns a float greater than 0.0, the thread is scheduled for another execution. Because of execution time of the block and other timing considerations, the next function also tries to figure out how much error there is between the expected run time of a block, and compensates for it on the next iteration.
     
     - parameter none:
     */

    private final func next() {
        let curTime = NSDate.timeIntervalSinceReferenceDate() - self.startTime
        let error = self.nextExpectedTime - curTime
        if let block = block {
            let nextTime: LyrebirdFloat? = block(curTime: curTime, inc: self.inc)
            if let nextTime = nextTime {
                self.inc = self.inc + 1
                self.nextExpectedTime = self.nextExpectedTime + nextTime
                let now = NSDate.timeIntervalSinceReferenceDate() - self.startTime
                let delayTime = (nextTime - (now - curTime)) + error
                delay(delayTime, queue: queue, closure: { self.next() })
            } else {
                finalizerBlock?(curTime: curTime)
            }
        } else {
            finalizerBlock?(curTime: 0.0)
        }
    }
}
