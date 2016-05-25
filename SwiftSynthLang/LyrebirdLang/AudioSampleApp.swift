//
//  AudioSampleApp.swift
//  LyrebirdSynthLang
//
//  Created by Joshua Parmenter on 5/14/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa
import Lyrebird
import AVFoundation

// The maximum number of audio buffers in flight. Setting to two allows one
// buffer to be played while the next is being written.
private let kInFlightAudioBuffers: Int = 2

// The number of audio samples per buffer. A lower value reduces latency for
// changes but requires more processing but increases the risk of being unable
// to fill the buffers in time. A setting of 1024 represents about 23ms of
// samples.
private let kSamplesPerBuffer: AVAudioFrameCount = 1024

public class LyrebirdTestSynthesizer {
    
    public static let sharedSynth: LyrebirdTestSynthesizer = LyrebirdTestSynthesizer()
    
    // The audio engine manages the sound system.
    private let engine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
    let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    
    // A circular queue of audio buffers.
    private var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
    
    // The index of the next buffer to fill.
    private var bufferIndex: Int = 0
    
    // The dispatch queue to render audio samples.
    private let audioQueue: dispatch_queue_t = dispatch_queue_create("LyrebirdQueue", DISPATCH_QUEUE_SERIAL)
    
    // A semaphore to gate the number of buffers processed.
    private let audioSemaphore: dispatch_semaphore_t = dispatch_semaphore_create(kInFlightAudioBuffers)
    
    private let lyrebird: LyrebirdMain = LyrebirdMain()
    
    private var demo: LyrebirdDemo? = nil

    // inits the CoreAudio engine, sets up LyrebirdMain and references our demo class
    private init() {
        // Create a pool of audio buffers.
        for _ in 0 ..< kInFlightAudioBuffers  {
            let audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: kSamplesPerBuffer)
            audioBuffers.append(audioBuffer)
        }
        
        // Attach and connect the player node.
        engine.attachNode(playerNode)
        engine.connect(playerNode, to: engine.outputNode, format: audioFormat)
        
        do {
            try engine.start()
        } catch _ {
            
        }
        
        playerNode.play()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LyrebirdTestSynthesizer.audioEngineConfigurationChange(_:)), name: AVAudioEngineConfigurationChangeNotification, object: engine)
        
        demo = LyrebirdDemo(lyrebird: lyrebird)
        demo?.runDemo()
        
    }
    
    
    public func play(){
        let blockSize = Int(self.lyrebird.blockSize)
        let numCycles = Int(kSamplesPerBuffer) / blockSize

        dispatch_async(audioQueue) {
            while true {
                // Wait for a buffer to become available.
                dispatch_semaphore_wait(self.audioSemaphore, DISPATCH_TIME_FOREVER)
                
                // Fill the buffer with new samples.
                let audioBuffer = self.audioBuffers[self.bufferIndex]
                let leftChannel = audioBuffer.floatChannelData[0]
                let rightChannel = audioBuffer.floatChannelData[1]

                for cycle in 0 ..< numCycles {
                    self.lyrebird.processWithInputChannels([])
                    let audioBlocks = self.lyrebird.audioBlocks()
                    let left = audioBlocks[0]
                    let right = audioBlocks[1]
                    let outputLeft = left.currentValues.map({Float($0)})
                    let outputRight = right.currentValues.map({Float($0)})
                    let offset = Int(cycle) * blockSize
                    for idx in 0 ..< blockSize {
                        leftChannel[offset + idx] = outputLeft[idx]
                        rightChannel[offset + idx] = outputRight[idx]
                    }
                }
                audioBuffer.frameLength = kSamplesPerBuffer
                
                // Schedule the buffer for playback and release it for reuse after
                // playback has finished.
                self.playerNode.scheduleBuffer(audioBuffer) {
                    dispatch_semaphore_signal(self.audioSemaphore)
                    return
                }
                
                self.bufferIndex = (self.bufferIndex + 1) % self.audioBuffers.count
            }
        }
        
    }
    
    @objc func audioEngineConfigurationChange(notification: NSNotification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
    
}



