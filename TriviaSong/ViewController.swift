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
    // Variable to return playback to previous state
    var wasPlaying: Bool!
    @IBOutlet weak var positionSlider: UISlider!
    @IBOutlet weak var playPauseBtn: UIButton!
    
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
            playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
        } else {
            songPlayer.play()
            playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
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
            playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
            songPlayer.prepareToPlay()
            songPlayer.play()
        }
    }
    
    @IBAction func onTouchDown(_ sender: UISlider) {
        // Set playback state to return to it after slide is released
        // and stop playback while touching the slider
        if songPlayer.isPlaying {
            wasPlaying = true
        } else {
            wasPlaying = false
        }
        songPlayer.stop()
    }
    
    @IBAction func changePlaybackTime(_ sender: UISlider) {
        // Convert slider value to time interval value
        songPlayer.currentTime = TimeInterval(positionSlider.value)
        // Prepare song to play at new time position
        songPlayer.prepareToPlay()
    }
    
    @IBAction func onSliderRelease(_ sender: UISlider) {
        // If song was playing before adjusting the slider,
        // resume on touch up or touch up outside
        if wasPlaying {
            songPlayer.play()
        }
    }
    
    // Function to update slider. @objc attribute required for functionality
    @objc func updateSlider() {
        positionSlider.value = Float(songPlayer.currentTime)
    }
    
    // Function to observe audio interruptions
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
    }
    
    // Function to handle interruptions
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions
            if (songPlayer.isPlaying) {
                wasPlaying = true
                songPlayer.pause()
                playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
            } else {
                wasPlaying = false
            }
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    songPlayer.play()
                    playPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
                } else {
                    // Interruption Ended - playback should NOT resume
                    songPlayer.stop()
                    playPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
                }
            }
        }
    }
}

