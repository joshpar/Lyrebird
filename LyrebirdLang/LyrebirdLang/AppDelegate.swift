//
//  AppDelegate.swift
//  LyrebirdLang
//
//  Created by Joshua Parmenter on 5/1/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    ///var audioSample: AudioSampleApp = AudioSampleApp()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
   //     audioSample.runSample()
        LyrebirdTestSynthesizer.sharedSynth.play()
   
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

