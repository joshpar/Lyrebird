//
//  LyrebirdControlChannel.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public class LyrebirdControlChannel {
    private (set) public var index: LyrebirdInt = 0
    private var iBlockSize: LyrebirdFloat = 0.0
    private (set) public var currentValues: LyrebirdFloat = 0.0
    
    // use inverse of block size to make interpolation internally easier later
    public required init(index: LyrebirdInt, iBlockSize: LyrebirdFloat){
        self.index = index
        self.iBlockSize = iBlockSize
    }
    
    public convenience init() {
        // default iBlockSize of 1/64
        self.init(index: 0, iBlockSize: 0.015625)
    }
}
