//
//  LyrebirdAudioChannel.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

open class LyrebirdAudioChannel {
    static var zeroedValues: [LyrebirdFloat] = []
    fileprivate (set) open var index: LyrebirdInt = 0
    open var currentValues: [LyrebirdFloat] = []
    var touched: Bool = false
    
    public required init(index: LyrebirdInt, blockSize: LyrebirdInt){
        self.index = index
        if let count: LyrebirdInt = blockSize {
            if count != LyrebirdAudioChannel.zeroedValues.count  {
                LyrebirdAudioChannel.zeroedValues = [LyrebirdFloat](repeating: 0.0, count: Int(count))
            }
        }
        touched = true
        self.zeroValues()
    }
    
    public convenience init() {
        self.init(index: 0, blockSize: 1024)
    }
    
    open func zeroValues(){
        if touched {
            currentValues = LyrebirdAudioChannel.zeroedValues
            touched = false
        }
    }
}
