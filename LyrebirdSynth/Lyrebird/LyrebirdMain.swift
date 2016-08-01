//
//  Lyrebird.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public class Lyrebird {
    
    
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
    
    public func startEngine(){
        Lyrebird.engine.delegate = self
        Lyrebird.engine.start()
    }
    
    public func stopEngine(){
        Lyrebird.engine.delegate = self
        Lyrebird.engine.stop()
    }
    
    public func runTests(){
        Lyrebird.engine.runTests()
    }
    
    public func processBlock(){
        // dummy for now
        Lyrebird.engine.processWithInputChannels([])
    }
    
    public func addNodeToHead(node: LyrebirdNode?){
        if let node = node {
            Lyrebird.engine.tree.defaultGroup.addNodeToHead(node)
        }
    }
    
    public func addNodeToTail(node: LyrebirdNode?){
        if let node = node {
            Lyrebird.engine.tree.defaultGroup.addNodeToTail(node)
        }
    }
    
    public func createParallelGroup() -> LyrebirdParallelGroup {
        let group = LyrebirdParallelGroup()
        Lyrebird.engine.tree.addParallelGroup(group)
        return group
    }
    
    public func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        Lyrebird.engine.tree.removeParallelGroup(parallelGroup)
    }
    
    public func freeAll(){
        Lyrebird.engine.tree.freeAll()
    }
    
    public func processWithInputChannels(inputChannels: [LyrebirdAudioChannel]){
        Lyrebird.engine.processWithInputChannels(inputChannels)
    }
    
    public func audioBlocks() -> [LyrebirdAudioChannel] {
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
