//
//  LyrebirdMain.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public class LyrebirdMain {
    
    
    /// ---
    /// The number of audio channels (physical and internal) to support
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    private (set) public var numberOfAudioChannels          : LyrebirdInt
    
    /// ---
    /// number of physical input channels to account for
    ///
    
    private (set) public var numberOfInputChannels          : LyrebirdInt
    
    /// ---
    /// number of physical output channels to account for
    ///
    
    private (set) public var numberOfOutputChannels         : LyrebirdInt
    
    /// ---
    /// The number of control channels to support
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    private (set) public var numberOfControlChannels        : LyrebirdInt
    
    /// ---
    /// The number of wires for Graph audio communication
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    private (set) public var numberOfWires                  : LyrebirdInt
    
    /// ---
    /// The size of the internal pre-allocated memory pool
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    
    private (set) public var internalMemoryPoolSize         : LyrebirdInt
    
    /// ---
    /// The size of the internal control block
    ///
    /// - Warning: keep these values as powers of 2 for efficiency reasons!
    /// - Warning: this is NOT the size of the system callback size. This is internal only
    
    private (set) public var blockSize               : LyrebirdInt {
        didSet {
            self.iBlockSize = 1.0 / LyrebirdFloat(blockSize)
        }
    }
    
    /// ---
    /// A scaler for calculating steps for interpolation across control periods
    ///
    
    private var iBlockSize              : LyrebirdFloat = 1.0
    
    /// ---
    /// The audio sample rate, in HZ, the system is running at shuld be used for internal calculations
    ///
    
    private (set) public var sampleRate              : LyrebirdFloat = 44100.0
    
    private (set) public var iSampleRate              : LyrebirdFloat = 0.000022676
    
    /// ---
    /// The processing engine
    ///
    
    private let engine                                : LyrebirdEngine = LyrebirdEngine.engine
    
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
                         internalMemoryPoolSize: LyrebirdInt,
                         blockSize: LyrebirdInt
        ){
        self.numberOfAudioChannels = numberOfAudioChannels
        self.numberOfInputChannels = numberOfInputChannels
        self.numberOfOutputChannels = numberOfOutputChannels
        self.numberOfControlChannels = numberOfControlChannels
        self.numberOfWires = numberOfWires
        self.internalMemoryPoolSize = internalMemoryPoolSize
        self.blockSize = blockSize
        self.sampleRate = sampleRate
        self.iSampleRate = 1.0 / sampleRate
        self.iBlockSize = 1.0 / LyrebirdFloat(self.blockSize)
        engine.numberOfAudioChannels = self.numberOfAudioChannels
        engine.numberOfControlChannels  = self.numberOfControlChannels
        engine.numberOfWires = self.numberOfWires
        engine.internalMemoryPoolSize = self.internalMemoryPoolSize
        engine.blockSize = self.blockSize
        engine.iBlockSize = self.iBlockSize
        startEngine()
    }
    
    public convenience init() {
        self.init(numberOfAudioChannels: 128,
                  numberOfInputChannels: 2,
                  numberOfOutputChannels: 2,
                  numberOfControlChannels: 256,
                  sampleRate: 44100.0,
                  numberOfWires: 256,
                  internalMemoryPoolSize: 32768,
                  blockSize: 64)
    }
    
    public func startEngine(){
        self.engine.delegate = self
        self.engine.start()
    }
    
    public func stopEngine(){
        self.engine.delegate = self
        self.engine.stop()
    }
    
    public func runTests(){
        self.engine.runTests()
    }
    
    public func processBlock(){
        // dummy for now
        engine.processWithInputChannels([])
    }
    
    public func addNodeToHead(node: LyrebirdNode){
        engine.tree.defaultGroup.addNodeToHead(node)
    }
    
    public func addNodeToTail(node: LyrebirdNode){
        engine.tree.defaultGroup.addNodeToTail(node)
    }
    
    public func createParallelGroup() -> LyrebirdParallelGroup {
        let group = LyrebirdParallelGroup()
        engine.tree.addParallelGroup(group)
        return group
    }
    
    public func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        engine.tree.removeParallelGroup(parallelGroup)
    }
    
    public func freeAll(){
        engine.tree.freeAll()
    }
    
    public func processWithInputChannels(inputChannels: [LyrebirdAudioChannel]){
        engine.processWithInputChannels(inputChannels)
    }
    
    public func audioBlocks() -> [LyrebirdAudioChannel] {
        return engine.audioBlock
    }

}

extension LyrebirdMain: LyrebirdEngineDelegate {
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
