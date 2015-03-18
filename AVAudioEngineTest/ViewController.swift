//
//  ViewController.swift
//  AVAudioEngineTest
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var engine: AVAudioEngine!
    var node: AVAudioPlayerNode!
    
    @IBOutlet weak var audioControl: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the session
        setupSession()
        // set up the engine
        setupEngine()
    }

    @IBAction func toggleAudio(sender: UIButton) {
        if (self.node.playing) {
            node.pause()
            self.audioControl.setTitle("Play", forState: UIControlState.Normal)
        } else {
            node.play()
            self.audioControl.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    private func setupSession() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        // Setup notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleInterruption:", name: AVAudioSessionInterruptionNotification, object: session)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRouteChange:", name: AVAudioSessionRouteChangeNotification, object: session)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMediaServicesReset:", name: AVAudioSessionMediaServicesWereResetNotification, object: session)
    }
    
    private func setupEngine() {
        self.engine = AVAudioEngine()
        
        initialiseNode("drumLoop", loop: true)
        
        var error: NSError?
        self.engine.startAndReturnError(&error)
        // Setup notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConfigurationChange:", name: AVAudioEngineConfigurationChangeNotification, object: engine)
    }
    
    private func initialiseNode(filename: String, loop: Bool) {
        var fileError: NSError?
        let file = AVAudioFile(forReading: NSURL(
            fileURLWithPath: NSBundle.mainBundle().pathForResource(filename, ofType: "caf")!), error: &fileError
        )
        
        node = AVAudioPlayerNode()
        
        engine.attachNode(node)
        engine.connect(node, to: engine.mainMixerNode, format: file.processingFormat)
        
        let fileCapacity = UInt32(file.length)
        let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: fileCapacity)
        var bufferError: NSError?
        file.readIntoBuffer(buffer, error:&bufferError)
        node.scheduleBuffer(buffer!, atTime: nil, options: .Loops, completionHandler: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleConfigurationChange(notif: NSNotification) {
        println("Called handleConfigurationChange")
    }
    
    func handleRouteChange(notif: NSNotification) {
        println("Called handleRouteChange")
    }
    
    func handleMediaServicesReset(notif: NSNotification) {
        println("Called handleMediaServicesReset")
    }
    
    func handleInterruption(notif: NSNotification) {
        println("Called handleInterruption")
    }


}

