//
//  LyrebirdAudioChannel.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public class LyrebirdAudioChannel: NSObject {
    static var zeroedValues: [LyrebirdFloat] = []
    private (set) public var index: LyrebirdInt = 0
    public var currentValues: [LyrebirdFloat] = []
    var touched: Bool = false
    
    public required init(index: LyrebirdInt, blockSize: LyrebirdInt){
        self.index = index
        if let count: LyrebirdInt = blockSize {
            if count != LyrebirdAudioChannel.zeroedValues.count  {
                LyrebirdAudioChannel.zeroedValues = [LyrebirdFloat](count: Int(count), repeatedValue: 0.0)
            }
        }
        super.init()
        touched = true
        self.zeroValues()
    }
    
    public override convenience init() {
        self.init(index: 0, blockSize: 1024)
    }
    
    public func zeroValues(){
        if touched {
            currentValues = LyrebirdAudioChannel.zeroedValues
            touched = false
        }
    }
}
