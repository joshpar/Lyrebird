//
//  AudioSampleGraphs.swift
//  LyrebirdSynthLang
//
//  Created by Joshua Parmenter on 5/15/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa
import Lyrebird

class LyrebirdTestGraph : LyrebirdGraph {
    
    // closure should refer to the graph, assign children and refer to args
    override func build (closure: LyrebirdGraphConstructionClosure) {
        self.buildClosure = closure
        closure()
    }
}