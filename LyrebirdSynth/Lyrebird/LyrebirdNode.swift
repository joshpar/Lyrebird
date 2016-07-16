//
//  LyrebirdNode.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/2/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public enum LyrebirdTreeError : ErrorType {
    case AlreadyProcessing
}

public typealias LyrebirdNodeTreeCompletionBlock = (nodeTree: LyrebirdNodeTree, finished: Bool) -> Void
typealias LyrebirdParallelGroupCompletionBlock = () -> Void
typealias LyrebirdInternalTreeCompletionBlock = () -> Void
/**
 LyrebirdNodeTree handles the main interaction with order of execution, and signal processing
 */
public class LyrebirdNodeTree {

    /// ---
    /// The single Node in the system which contains any parallel groups of nodes to be processed
    ///
    /// This node can be replaced with a new LyrebirdRootNode to completely clear all processing!

    private var root: LyrebirdRootNode = LyrebirdRootNode() {
        didSet {
            defaultGroup = root.parallelGroups[0].rootGroup
        }
    }
    
    //TODO:: make this a group that can only add head or tail - all other groups can have groups or nodes placed before or after them

    /// ---
    /// Stores a reference to a default group that can be quickly accessed
    ///
    /// For many applications, adding notes to the head of the defaultGroup should do what you need. If you don't add any ParallelGroups, build your tree by adding nodes into this group

    public var defaultGroup: LyrebirdGroup
    
    /// ---
    /// prevents the tree from being processed twice at the same time
    private var processing: Bool = false
    
    public init(){
        defaultGroup = root.parallelGroups[0].rootGroup
    }
    
    /**
     Processes all ParallelGroups, and their children
     
     - parameter completion: a block to execute when the control period has finished processing
     */

    public func processTree(completion: LyrebirdNodeTreeCompletionBlock) throws {
        if !processing {
            processing = true
            root.processTree({ 
                self.processing = false
                completion(nodeTree: self, finished: true)
            })
        } else {
            throw LyrebirdTreeError.AlreadyProcessing
        }
    }
    
    /**
     Removes ALL groups and nodes from the processing chain.
     
     - Warning: Seriously - this invalidates all references to notes, groups and nodes you previously had. Use it if you mean it.
     */

    public func freeAll(){
        root = LyrebirdRootNode()
    }
    
    /**
     Adds a new ParallelGroup to the processing chain
     
     - parameter parallelGroup:
     */

    public func addParallelGroup(parallelGroup: LyrebirdParallelGroup){
        root.addParallelGroup(parallelGroup)
    }

    /**
     removes a new ParallelGroup from the processing chain
     
     - parameter parallelGroup:
     */

    public func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        root.removeParallelGroup(parallelGroup)
    }
    
}

class LyrebirdRootNode {
    
    private var parallelGroups      : [LyrebirdParallelGroup] = [LyrebirdParallelGroup()]
    
    func addParallelGroup(parallelGroup: LyrebirdParallelGroup){
        parallelGroups.append(parallelGroup)
    }
    
    func removeParallelGroup(parallelGroup: LyrebirdParallelGroup){
        
//        if let index: Int = parallelGroups.indexOf(parallelGroup) {
//            parallelGroups.removeAtIndex(index)
//        }
    }
    
    func processTree(completion: LyrebirdInternalTreeCompletionBlock ){
        for parallelGroup: LyrebirdParallelGroup in parallelGroups {
            parallelGroup.processParallelGroup({ 
                let allDone: Bool = self.isFinished()
                if allDone {
                    completion()
                }
            })
        }
    }
    
    private func isFinished() -> Bool {
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
public class LyrebirdParallelGroup {
    var finished        : Bool = true
    var rootGroup       : LyrebirdGroup = LyrebirdGroup()
    
    func processParallelGroup(completion: LyrebirdParallelGroupCompletionBlock){
        
        rootGroup.processChildren()
        
        completion()
    }
}

public typealias LyrebirdNodeFinishBlock = (node: LyrebirdNode) -> Void

public class LyrebirdNode {
    var nextNode                        : LyrebirdNode?
    var previousNode                    : LyrebirdNode?
    var parent                          : LyrebirdGroup?
    public var finishBlock              : LyrebirdNodeFinishBlock?

    public func addNodeAfter(node: LyrebirdNode){
        if let nextNode: LyrebirdNode = node.nextNode {
            node.nextNode = nextNode
            nextNode.previousNode = node
        }
        self.nextNode = node
        node.previousNode = node
        node.parent = self.parent
    }
    
    public func addNodeBefore(node: LyrebirdNode){
        if let previousNode: LyrebirdNode = self.previousNode {
            node.previousNode = previousNode
            previousNode.nextNode = node
        }
        node.nextNode = self
        self.previousNode = node
        node.parent = self.parent
    }
    
    public func next(numSamples: LyrebirdInt){
        
    }
    
    public func free(){
        if let previousNode = previousNode {
            previousNode.nextNode = nextNode
        } else {
            parent?.nextNode = nextNode
        }
        finishBlock?(node: self)
    }
}

public class LyrebirdGroup: LyrebirdNode {
    
    public func addNodeToHead(node: LyrebirdNode){
        node.nextNode = nextNode
        nextNode?.previousNode = node
        nextNode = node
        node.parent = self
    }
    
    public func addNodeToTail(node: LyrebirdNode){
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
    
    public func processChildren(){
        var node: LyrebirdNode? = nextNode
        let blockSize = LyrebirdEngine.engine.blockSize
        while node != nil {
            // get the CURRENT next node
            let tmp = node?.nextNode
            node?.next(blockSize)
            node = tmp
        }
    
    }
}

/**
 A note represents an instance of a graph. When the node tree is traversed, the next function is called on the graph AFTER parameters are updated (if any need to be)
 */
public class LyrebirdNote: LyrebirdNode {
    
    /// ---
    /// The graph representing this note
    ///
    /// - Warning: a COPY of the graph you supply is used for each note. Any values that change in the parameter for the graph will update only for that instance
    
    public var graph                           : LyrebirdGraph
    
    /// ---
    /// by default, nodes that are added to the node tree will calculate samples
    ///
    /// setting 'running' to false can keep the node in the tree, but keep if from calculating its samples
    
    var running                         : Bool = true
    
    private var processing              : Bool = false
    
    private var queuedParameterChanges  : [String: LyrebirdValidUGenInput] = [:]
    
    private var hasQueuedChanges        : Bool  = false
    
    public var outputOffsetSamples      : LyrebirdInt = 0
    
    public var shouldFree               : Bool = false
    
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
    
    public func updateParameter(key: LyrebirdKey, value: LyrebirdValidUGenInput){
        if !processing {
            self.graph.parameters[key] = value
        } else {
            hasQueuedChanges = true
            queuedParameterChanges[key] = value
        }
    }

    override public func next(numSamples: LyrebirdInt){
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
                    self.graph.next(sampleCount)
                } else {
                    self.graph.next(numSamples)
                }
                processing = false
                if hasQueuedChanges {
                    for (key, value) in queuedParameterChanges {
                        self.updateParameter(key, value: value)
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
