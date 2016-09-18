//
//  Lyrebird.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

open class Lyrebird {
    
    
    /// ---
    /// The number of audio channels (physical and internal) to support
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    fileprivate (set) open var numberOfAudioChannels          : LyrebirdInt
    
    /// ---
    /// number of physical input channels to account for
    ///
    
    fileprivate (set) open var numberOfInputChannels          : LyrebirdInt
    
    /// ---
    /// number of physical output channels to account for
    ///
    
    fileprivate (set) open var numberOfOutputChannels         : LyrebirdInt
    
    /// ---
    /// The number of control channels to support
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    fileprivate (set) open var numberOfControlChannels        : LyrebirdInt
    
    /// ---
    /// The number of wires for Graph audio communication
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    fileprivate (set) open var numberOfWires                  : LyrebirdInt
    
    /// ---
    /// The size of the internal control block
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    /// - Warning: this is NOT the size of the system callback size. This is internal only
    
    fileprivate (set) open var blockSize               : LyrebirdInt {
        didSet {
            self.iBlockSize = 1.0 / LyrebirdFloat(blockSize)
        }
    }
    
    /// ---
    /// A scaler for calculating steps for interpolation across control periods
    ///
    
    fileprivate var iBlockSize              : LyrebirdFloat = 1.0
    
    /// ---
    /// The audio sample rate, in HZ, the system is running at shuld be used for internal calculations
    ///
    
    fileprivate (set) open var sampleRate              : LyrebirdFloat = 44100.0
    
    fileprivate (set) open var iSampleRate              : LyrebirdFloat = 0.000022676
    
    /// ---
    /// The processing engine
    ///
    
    static let engine                                  : LyrebirdEngine = LyrebirdEngine.engine
    
    /**
Designated initializer for the main synth environment.
 
- parameter numberOfAudioChannels: the number of audio channels to allocate memory for
- parameter numberOfInputChannels: the number of physical input channels to reserve space for
     - parameter numberOfOutputChannels: the number of physical output channels to reserve space for
     - parameter numberOfControlChannels: the number of control channels to allocate
     - parameter numberOfWires: the number of audio wires to allocate, which is the limit for the number of interconnects in a graph
     - parameter internalMemoryPoolSize: the size of the preallocated internal memory pool for fast allocation
     - parameter controlBlockSize: the internal

- Returns:
 
- Throws:
*/

    public required init(numberOfAudioChannels: LyrebirdInt,
                         numberOfInputChannels: LyrebirdInt,
                         numberOfOutputChannels: LyrebirdInt,
                         numberOfControlChannels: LyrebirdInt,
                         sampleRate: LyrebirdFloat,
                         numberOfWires: LyrebirdInt,
                         blockSize: LyrebirdInt
        ){
        self.numberOfAudioChannels = numberOfAudioChannels
        self.numberOfInputChannels = numberOfInputChannels
        self.numberOfOutputChannels = numberOfOutputChannels
        self.numberOfControlChannels = numberOfControlChannels
        self.numberOfWires = numberOfWires
        self.blockSize = blockSize
        self.sampleRate = sampleRate
        self.iSampleRate = 1.0 / sampleRate
        self.iBlockSize = 1.0 / LyrebirdFloat(self.blockSize)
        Lyrebird.engine.numberOfAudioChannels = self.numberOfAudioChannels
        Lyrebird.engine.numberOfControlChannels  = self.numberOfControlChannels
        Lyrebird.engine.blockSize = self.blockSize
        Lyrebird.engine.iBlockSize = self.iBlockSize
        startEngine()
    }
    
    public convenience init() {
        self.init(numberOfAudioChannels: 128,
                  numberOfInputChannels: 2,
                  numberOfOutputChannels: 2,
                  numberOfControlChannels: 256,
                  sampleRate: 44100.0,
                  numberOfWires: 256,
                  blockSize: 64)
    }
    
    open func startEngine(){
        Lyrebird.engine.delegate = self
        Lyrebird.engine.start()
    }
    
    open func stopEngine(){
        Lyrebird.engine.delegate = self
        Lyrebird.engine.stop()
    }
    
    open func runTests(){
        Lyrebird.engine.runTests()
    }
    
    open func processBlock(){
        // dummy for now
        Lyrebird.engine.processWithInputChannels(inputChannels: [])
    }
    
    open func addNodeToHead(node: LyrebirdNode?){
        if let node = node {
            Lyrebird.engine.tree.defaultGroup.addNodeToHead(node: node)
        }
    }
    
    open func addNodeToTail(node: LyrebirdNode?){
        if let node = node {
            Lyrebird.engine.tree.defaultGroup.addNodeToTail(node: node)
        }
    }
    
    open func createParallelGroup() -> LyrebirdParallelGroup {
        let group = LyrebirdParallelGroup()
        Lyrebird.engine.tree.addParallelGroup(parallelGroup: group)
        return group
    }
    
    open func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        Lyrebird.engine.tree.removeParallelGroup(parallelGroup: parallelGroup)
    }
    
    open func freeAll(){
        Lyrebird.engine.tree.freeAll()
    }
    
    open func processWithInputChannels(inputChannels: [LyrebirdAudioChannel]){
        Lyrebird.engine.processWithInputChannels(inputChannels: inputChannels)
    }
    
    open func audioBlocks() -> [LyrebirdAudioChannel] {
        return Lyrebird.engine.audioBlock
    }

}

extension Lyrebird: LyrebirdEngineDelegate {
    func synthEngineHasStarted(engine: LyrebirdEngine) {
        
        print("Engine started!")
        //        if let inputChannels : [LyrebirdAudioChannel] = audioBlock[0 ..< 1] as? [LyrebirdAudioChannel] {
        //            engine.processWithInputChannels(inputChannels) { (finished) in
        //                print("\(finished)")
        //            }
        //        }
    }
    
    func synthEngineHasStopped(engine: LyrebirdEngine) {
        print("Engine quit!")
    }
}
