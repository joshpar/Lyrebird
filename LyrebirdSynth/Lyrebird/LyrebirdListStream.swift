//
//  LyrebirdListStream.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/7/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public struct LyrebirdListStream {
    let list: [LyrebirdNumber]
    private (set) public var offset: LyrebirdInt
    private let listSize: LyrebirdInt
    private var finished: Bool
    
    
    public init(list: [LyrebirdNumber], offset: LyrebirdInt = 0){
        self.list = list
        self.offset = offset
        self.listSize = list.count
        self.finished = false
    }
    
    public init(){
        self.init(list: [], offset: 0)
    }
    
    public mutating func next() -> LyrebirdNumber? {
        if offset >= listSize {
            finished = true
            return nil
        }
        let returnValue = list[offset]
        offset = (offset + 1)
        return returnValue
    }
}

public struct LyrebirdRepeatableListStream {
    let list: [LyrebirdNumber]
    let repeats: LyrebirdInt
    private (set) public var offset: LyrebirdInt
    private let initialOffset: LyrebirdInt
    private var repetition: LyrebirdInt = 0
    private let listSize: LyrebirdInt
    private var finished: Bool
    
    public init(list: [LyrebirdNumber], repeats: LyrebirdInt = 0, offset: LyrebirdInt = 0){
        self.list = list
        self.repeats = repeats
        self.offset = offset
        initialOffset = offset
        listSize = list.count
        finished = false
    }
    
    public init(){
        self.init(list: [], repeats: 0, offset: 0)
    }
    
    public mutating func next() -> LyrebirdNumber? {
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
