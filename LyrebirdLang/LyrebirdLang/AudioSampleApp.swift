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
import AudioToolbox

// The maximum number of audio buffers in flight. Setting to two allows one
// buffer to be played while the next is being written.
private let kInFlightAudioBuffers: Int = 2

// The number of audio samples per buffer. A lower value reduces latency for
// changes but requires more processing but increases the risk of being unable
// to fill the buffers in time. A setting of 1024 represents about 23ms of
// samples.
private let kSamplesPerBuffer: AVAudioFrameCount = 1024

open class LyrebirdTestSynthesizer {
    
    open static let sharedSynth: LyrebirdTestSynthesizer = LyrebirdTestSynthesizer()
    
    // The audio engine manages the sound system.
    fileprivate let engine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    fileprivate let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
    var audioFormat : AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    
    // A circular queue of audio buffers.
    fileprivate var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
    
    // The index of the next buffer to fill.
    fileprivate var bufferIndex: Int = 0
    
    // The dispatch queue to render audio samples.
    fileprivate let audioQueue: DispatchQueue = DispatchQueue(label: "LyrebirdQueue", attributes: [])
    
    // A semaphore to gate the number of buffers processed.
    fileprivate let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: kInFlightAudioBuffers)
    
    fileprivate let lyrebird: Lyrebird = Lyrebird()
    
    fileprivate var demo: LyrebirdDemo? = nil
    
    fileprivate var inputChannels: [[LyrebirdFloat]] = [[LyrebirdFloat](repeating: 0.0, count: Int(kSamplesPerBuffer)), [LyrebirdFloat](repeating: 0.0, count: Int(kSamplesPerBuffer))]
    
    // inits the CoreAudio engine, sets up Lyrebird and references our demo class
    fileprivate init() {
        // Create a pool of audio buffers.
        
        audioFormat = engine.inputNode!.outputFormat(forBus: 0)
        
        for _ in 0 ..< kInFlightAudioBuffers  {
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kSamplesPerBuffer)
            audioBuffers.append(audioBuffer)
        }
        
        // Attach and connect the player node.
        engine.attach(playerNode)
        
        
        //  engine.connect(engine.inputNode!, to: playerNode, format: audioFormat)
        
        
        engine.connect(playerNode, to: engine.outputNode, format: audioFormat)
        
        if let inputNode: AVAudioInputNode = engine.inputNode {
            inputNode.installTap(onBus: 0, bufferSize: kSamplesPerBuffer, format: audioFormat, block: { (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
                
                //  print("buffer channel \(buffer.format.settings)")
                if let leftChannelData = buffer.floatChannelData?[0] {
                    if let rightChannelData = buffer.floatChannelData?[1] {
                        
                        for idx: Int in 0 ..< Int(kSamplesPerBuffer) {
                            self.inputChannels[0][idx] = LyrebirdFloat(leftChannelData[idx])
                            self.inputChannels[1][idx] = LyrebirdFloat(rightChannelData[idx])
                        }
                    }
                }
            })
            
        }
        
        
        do {
            try engine.start()
        } catch _ {
            
        }
        
        playerNode.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LyrebirdTestSynthesizer.audioEngineConfigurationChange(_:)), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: engine)
        
        demo = LyrebirdDemo(lyrebird: lyrebird)
        demo?.runDemo()
        
    }
    
    
    open func play(){
        let blockSize = Int(lyrebird.blockSize)
        let numCycles = Int(kSamplesPerBuffer) / blockSize
        
        audioQueue.async {
            while true {
                // Wait for a buffer to become available.
                self.audioSemaphore.wait(timeout: DispatchTime.distantFuture)
                
                // Fill the buffer with new samples.
                let audioBuffer = self.audioBuffers[self.bufferIndex]
                let leftChannel = audioBuffer.floatChannelData?[0]
                let rightChannel = audioBuffer.floatChannelData?[1]
                
                var leftInAudio = self.inputChannels[0]
                var rightInAudio = self.inputChannels[1]
                
                for cycle in 0 ..< numCycles {
                    let offset = Int(cycle) * blockSize
                    let audioBlocks = self.lyrebird.audioBlocks()
                    let leftInput = audioBlocks[2]
                    let rightInput = audioBlocks[3]
                    for idx: Int in 0 ..< blockSize {
                        leftInput.currentValues[idx] = LyrebirdFloat(leftInAudio[(blockSize * cycle) + idx])
                        rightInput.currentValues[idx] = LyrebirdFloat(rightInAudio[(blockSize * cycle) + idx])
                    }
                    self.lyrebird.processWithInputChannels(inputChannels: [])
                    let left = audioBlocks[0]
                    let right = audioBlocks[1]
                    let outputLeft = left.currentValues.map({Float($0)})
                    let outputRight = right.currentValues.map({Float($0)})
                    for idx in 0 ..< blockSize {
                        leftChannel![offset + idx] = outputLeft[idx]
                        rightChannel![offset + idx] = outputRight[idx]
                    }
                }
                audioBuffer.frameLength = kSamplesPerBuffer
                
                self.bufferIndex = (self.bufferIndex + 1) % self.audioBuffers.count
                
                // Schedule the buffer for playback and release it for reuse after
                // playback has finished.
                self.playerNode.scheduleBuffer(audioBuffer) {
                    self.audioSemaphore.signal()
                    return
                }
                
            }
        }
        
    }
    
    @objc func audioEngineConfigurationChange(_ notification: Notification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
    
}



