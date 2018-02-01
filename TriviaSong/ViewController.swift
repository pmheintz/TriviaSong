//
//  ViewController.swift
//  TriviaSong
//
//  Created by Paul Heintz on 1/31/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import UIKit
// Import AVFoundation for playback of audio file
import AVFoundation

class ViewController: UIViewController {
    // Instantiate the audio player
    var songPlayer = AVAudioPlayer()
    @IBOutlet weak var positionSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare song for playback
        prepareSongAndSession()
        // Set infinite loops
        songPlayer.numberOfLoops = -1
        // Play the song
        songPlayer.play()
        
        // Set slider's max value to songs duration
        positionSlider.maximumValue = Float(songPlayer.duration)
        
        // Timer to update slider position
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Prepare song and session for audio playback
    func prepareSongAndSession() {
        do {
            // Insert song into player
            songPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "JeopardySong", ofType: "mp3")!))
            
            // Prepare song to be played
            songPlayer.prepareToPlay()
            
            // Create audio session
            let audioSession = AVAudioSession.sharedInstance()
            do {
                // Set session to playback music
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            } catch let sessionError { // catch session errors
                print(sessionError)
            }
        } catch let songPlayerError { // catch song player errors
            print(songPlayerError)
        }
    }

    @IBAction func playPause(_ sender: UIButton) {
        // Determine if song is playing and start or stop playback
        if songPlayer.isPlaying {
            songPlayer.pause()
            sender.setImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
        } else {
            songPlayer.play()
            sender.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
        }
    }
    
    @IBAction func restartSong(_ sender: UIButton) {
        // If song is playing, stop it, rewind to beginning, start playing
        if songPlayer.isPlaying {
            songPlayer.stop()
            songPlayer.currentTime = 0
            songPlayer.prepareToPlay()
            songPlayer.play()
        } else {
        // Song isn't playing, so return to beginning and start playing
            songPlayer.currentTime = 0
            songPlayer.prepareToPlay()
            songPlayer.play()
        }
    }
    
    @IBAction func changePlaybackTime(_ sender: UISlider) {
        // Stop playback to adjust time
        songPlayer.stop()
        // Convert slider value to time interval value
        songPlayer.currentTime = TimeInterval(positionSlider.value)
        songPlayer.prepareToPlay()
        songPlayer.play()
        
    }
    
    // Function to update slider. @objc attribute required for functionality
    @objc func updateSlider() {
        positionSlider.value = Float(songPlayer.currentTime)
    }
}

