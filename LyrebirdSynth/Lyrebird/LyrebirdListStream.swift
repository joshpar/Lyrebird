//
//  LyrebirdListStream.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/7/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//


open class LyrebirdStream {
    var finished: Bool = false
    
    open func reset() {
        finished = false
    }
}


open class LyrebirdListStream : LyrebirdStream {
    let list: [LyrebirdNumber]
    fileprivate (set) open var offset: LyrebirdInt
    fileprivate let listSize: LyrebirdInt
    fileprivate let initialOffset: LyrebirdInt
    
    open override func reset(){
        super.reset()
        offset = initialOffset
    }
    
    public init(list: [LyrebirdNumber] = [], offset: LyrebirdInt = 0){
        self.list = list
        self.offset = offset
        self.initialOffset = offset
        self.listSize = list.count
        super.init()
    }
    /*
    public override convenience init(){
        self.init(list: [], offset: 0)
    }
    */
    open func next() -> LyrebirdNumber? {
        if offset >= listSize {
            finished = true
            return nil
        }
        let returnValue = list[offset]
        offset = (offset + 1)
        return returnValue
    }
}

open class Sequence : LyrebirdListStream {
    
}

open class LyrebirdRepeatableListStream : LyrebirdListStream {
    let repeats: LyrebirdInt
    fileprivate var repetition: LyrebirdInt = 0
    
    public init(list: [LyrebirdNumber] = [], repeats: LyrebirdInt = 0, offset: LyrebirdInt = 0){
        self.repeats = repeats
        super.init(list: list, offset: offset)
    }
    
    open override func reset(){
        super.reset()
        repetition = 0
    }
    
    open override func next() -> LyrebirdNumber? {
        guard !finished else {
            return nil
        }
        if repetition > repeats {
            finished = true
            return nil
        }
        let returnValue = list[offset]
        offset = (offset + 1) % listSize
        if offset == initialOffset {
            repetition = repetition + 1
        }
        return returnValue
    }
}

open class LoopingSequence : LyrebirdRepeatableListStream {
    
}
