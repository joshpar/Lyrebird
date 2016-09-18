//
//  LyrebirdNode.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum LyrebirdTreeError : Error {
    case alreadyProcessing
}

public typealias LyrebirdNodeTreeCompletionBlock = (_ nodeTree: LyrebirdNodeTree, _ finished: Bool) -> Void
typealias LyrebirdParallelGroupCompletionBlock = () -> Void
typealias LyrebirdInternalTreeCompletionBlock = () -> Void
/**
 LyrebirdNodeTree handles the main interaction with order of execution, and signal processing
 */
open class LyrebirdNodeTree {
    
    /// ---
    /// The single Node in the system which contains any parallel groups of nodes to be processed
    ///
    /// This node can be replaced with a new LyrebirdRootNode to completely clear all processing!
    
    fileprivate var root: LyrebirdRootNode = LyrebirdRootNode() {
        didSet {
            defaultGroup = root.parallelGroups[0].rootGroup
        }
    }
    
    //TODO:: make this a group that can only add head or tail - all other groups can have groups or nodes placed before or after them
    
    /// ---
    /// Stores a reference to a default group that can be quickly accessed
    ///
    /// For many applications, adding notes to the head of the defaultGroup should do what you need. If you don't add any ParallelGroups, build your tree by adding nodes into this group
    
    open var defaultGroup: LyrebirdGroup
    
    /// ---
    /// prevents the tree from being processed twice at the same time
    fileprivate var processing: Bool = false
    
    public init(){
        defaultGroup = root.parallelGroups[0].rootGroup
    }
    
    /**
     Processes all ParallelGroups, and their children
     
     - parameter completion: a block to execute when the control period has finished processing
     */
    
    open func processTree(completion: @escaping LyrebirdNodeTreeCompletionBlock) throws {
        if !processing {
            processing = true
            root.processTree(completion: {
                self.processing = false
                completion(self, true)
            })
        } else {
            throw LyrebirdTreeError.alreadyProcessing
        }
    }
    
    /**
     Removes ALL groups and nodes from the processing chain.
     
     - Warning: Seriously - this invalidates all references to notes, groups and nodes you previously had. Use it if you mean it.
     */
    
    open func freeAll(){
        root = LyrebirdRootNode()
    }
    
    /**
     Adds a new ParallelGroup to the processing chain
     
     - parameter parallelGroup:
     */
    
    open func addParallelGroup(parallelGroup: LyrebirdParallelGroup){
        root.addParallelGroup(parallelGroup: parallelGroup)
    }
    
    /**
     removes a new ParallelGroup from the processing chain
     
     - parameter parallelGroup:
     */
    
    open func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        root.removeParallelGroup(parallelGroup: parallelGroup)
    }
    
}

class LyrebirdRootNode {
    
    fileprivate var parallelGroups      : [LyrebirdParallelGroup] = [LyrebirdParallelGroup()]
    
    func addParallelGroup(parallelGroup: LyrebirdParallelGroup){
        parallelGroups.append(parallelGroup)
    }
    
    func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        
        //        if let index: Int = parallelGroups.indexOf(parallelGroup) {
        //            parallelGroups.removeAtIndex(index)
        //        }
    }
    
    func processTree(completion: @escaping LyrebirdInternalTreeCompletionBlock ){
        for parallelGroup: LyrebirdParallelGroup in parallelGroups {
            parallelGroup.processParallelGroup(completion: {
                let allDone: Bool = self.isFinished()
                if allDone {
                    completion()
                }
            })
        }
    }
    
    fileprivate func isFinished() -> Bool {
        var allDone: Bool = true
        for parallelGroup: LyrebirdParallelGroup in parallelGroups {
            if !parallelGroup.finished {
                allDone = false
                break
            }
        }
        return allDone
    }
    
}

// represents a thread independent node of values to process
open class LyrebirdParallelGroup {
    var finished        : Bool = true
    var rootGroup       : LyrebirdGroup = LyrebirdGroup()
    
    func processParallelGroup(completion: LyrebirdParallelGroupCompletionBlock){
        
        rootGroup.processChildren()
        
        completion()
    }
}

public typealias LyrebirdNodeFinishBlock = (_ node: LyrebirdNode) -> Void

open class LyrebirdNode {
    var nextNode                        : LyrebirdNode?
    var previousNode                    : LyrebirdNode?
    var parent                          : LyrebirdGroup?
    open var finishBlock              : LyrebirdNodeFinishBlock?
    
    open func addNodeAfter(node: LyrebirdNode?){
        if let node = node {
            if let nextNode: LyrebirdNode = node.nextNode {
                node.nextNode = nextNode
                nextNode.previousNode = node
            }
            self.nextNode = node
            node.previousNode = node
            node.parent = self.parent
        }
    }
    
    open func addNodeBefore(node: LyrebirdNode?){
        if let node = node {
            if let previousNode: LyrebirdNode = self.previousNode {
                node.previousNode = previousNode
                previousNode.nextNode = node
            }
            node.nextNode = self
            self.previousNode = node
            node.parent = self.parent
        }
    }
    
    open func next(numSamples: LyrebirdInt){
        
    }
    
    open func free(){
        if let previousNode = previousNode {
            previousNode.nextNode = nextNode
        } else {
            parent?.nextNode = nextNode
        }
        finishBlock?(self)
    }
}

open class LyrebirdGroup: LyrebirdNode {
    
    open func addNodeToHead(node: LyrebirdNode?){
        if let node = node {
            node.nextNode = nextNode
            nextNode?.previousNode = node
            nextNode = node
            node.parent = self
        }
    }
    
    open func addNodeToTail(node: LyrebirdNode?){
        if let node = node {
            if var finalNode: LyrebirdNode = nextNode {
                while finalNode.nextNode != nil {
                    finalNode = finalNode.nextNode!
                }
                finalNode.nextNode  = node
                node.previousNode = finalNode
                return
            }
            nextNode = node
            node.parent = self
        }
    }
    
    open func processChildren(){
        var node: LyrebirdNode? = nextNode
        let blockSize = Lyrebird.engine.blockSize
        while node != nil {
            // get the CURRENT next node
            let tmp = node?.nextNode
            node?.next(numSamples: blockSize)
            node = tmp
        }
        
    }
}

/**
 A note represents an instance of a graph. When the node tree is traversed, the next function is called on the graph AFTER parameters are updated (if any need to be)
 */
open class LyrebirdNote: LyrebirdNode {
    
    /// ---
    /// The graph representing this note
    ///
    /// - Warning: a COPY of the graph you supply is used for each note. Any values that change in the parameter for the graph will update only for that instance
    
    open var graph                           : LyrebirdGraph
    
    /// ---
    /// by default, nodes that are added to the node tree will calculate samples
    ///
    /// setting 'running' to false can keep the node in the tree, but keep if from calculating its samples
    
    var running                         : Bool = true
    
    fileprivate var processing              : Bool = false
    
    fileprivate var queuedParameterChanges  : [String: LyrebirdValidUGenInput] = [:]
    
    fileprivate var hasQueuedChanges        : Bool  = false
    
    open var outputOffsetSamples      : LyrebirdInt = 0
    
    open var shouldFree               : Bool = false
    
    public required init(graph: LyrebirdGraph?){
        if let graphCopy: LyrebirdGraph = graph!.copyGraph() {
            self.graph = graphCopy
        } else {
            self.graph = LyrebirdGraph()
        }
        super.init()
        self.graph.note = self
    }
    
    public override convenience init(){
        self.init(graph: LyrebirdGraph())
    }
    
    open func updateParameter(key: LyrebirdKey, value: LyrebirdValidUGenInput){
        if !processing {
            self.graph.parameters[key] = value
        } else {
            hasQueuedChanges = true
            queuedParameterChanges[key] = value
        }
    }
    
    override open func next(numSamples: LyrebirdInt){
        if running {
            // prevent processing if, for some reason, it already is
            if !processing {
                if outputOffsetSamples > numSamples {
                    outputOffsetSamples = outputOffsetSamples - numSamples
                    return
                }
                processing = true
                if (outputOffsetSamples > 0){
                    let sampleCount = numSamples - outputOffsetSamples
                    outputOffsetSamples = 0
                    self.graph.next(numSamples: sampleCount)
                } else {
                    self.graph.next(numSamples: numSamples)
                }
                processing = false
                if hasQueuedChanges {
                    for (key, value) in queuedParameterChanges {
                        self.updateParameter(key: key, value: value)
                    }
                    hasQueuedChanges = false
                    queuedParameterChanges.removeAll()
                }
                // shouldFree can be set by a notes processing function internally
                // such as after envelopes finish
                if shouldFree {
                    self.free()
                }
            }
        }
    }
}
