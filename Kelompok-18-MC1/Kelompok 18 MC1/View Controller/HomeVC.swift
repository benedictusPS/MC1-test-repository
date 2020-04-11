//
//  HomeVC.swift
//  Kelompok 18 MC1 Napp
//
//  Created by Yosua Marchel on 07/04/20.
//  Copyright © 2020 Yosua Marchel. All rights reserved.
//

import UIKit
import AVFoundation

class HomeVC: UIViewController {
    
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timerProgress: UIProgressView!
    @IBOutlet weak var nappyImage: UIImageView!
    @IBOutlet weak var timerBackgroundImage: UIImageView!
    
    
    //for Timer
    var seconds: Int64 = 0 //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var resumeTapped = false
    
    //progress bar
    var progress = Progress(totalUnitCount: 0)
    var totalTime : Int64 = 0
    
    //for Music
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //label and image
        topTextLabel.text = "Ready for napnap?"
        timerLabel.text = "Get comfy before we nap. Worry not, Nappy will wake you up!"
        timerLabel.font = timerLabel.font.withSize(21)
        nappyImage.image = UIImage(named: "NappyRevisi-1")
        timerBackgroundImage.layer.cornerRadius = 30
        
        //progress bar
        timerProgress.transform = timerProgress.transform.scaledBy(x: 1, y: 3)
        timerProgress.isHidden = true
        
        //slider
        slider.isHidden = false
        
        //buttons
        stopButton.isEnabled = false
        stopButton.isHidden = true
        resumeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let currentValue = Int64(sender.value) * 60
        seconds = currentValue
        timerLabel.text = timeString(time: TimeInterval(seconds))
        topTextLabel.text = "How long will you nap?"
        nappyImage.image = UIImage(named: "NappyRevisi-8")
        timerLabel.font = timerLabel.font.withSize(36)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        totalTime = seconds //for progress bar
        if seconds == 0 {  //check if the timer set or not
            showAlertTimerNotSet()
        }else{
            timerProgress.isHidden = false
            slider.isHidden = true
            startButton.isEnabled = false
            startButton.isHidden = true
            topTextLabel.text = "Sleep tight, buddy!"
            nappyImage.image = UIImage(named: "NappyRevisi-5")
            if isTimerRunning == false {
                self.progress = Progress(totalUnitCount: totalTime)
                timerProgress.progress = 0.0
                self.progress.completedUnitCount = 0
                runTimer()
            }
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        if self.resumeTapped == false {
            if seconds < 1 {
                resetHome()
            }else{
                timer.invalidate()
                self.resumeTapped = true
                resumeButton.isHidden = false
                resumeButton.isEnabled = true
                resetButton.isHidden = false
                stopButton.isHidden = true
                nappyImage.image = UIImage(named: "NappyRevisi-8")
            }
        }
    }
    
    @IBAction func resumeButtonTapped(_ sender: UIButton) {
        if self.resumeTapped == true {
            runTimer()
            self.resumeTapped = false
            resumeButton.isHidden = true
            resetButton.isHidden = true
            stopButton.isHidden = false
            nappyImage.image = UIImage(named: "NappyRevisi-5")
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetHome()
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            nappyImage.image = UIImage(named: "NappyRevisi-6")
            topTextLabel.text = "Wakey wakey, Sleepyhead!"
            
            //Send alert to indicate "time's up!"
            //showAlertTimesUp()
            
            //play alarm sound
            let path = Bundle.main.path(forResource: "bensound-creativeminds", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer =  try AVAudioPlayer(contentsOf: url)
            } catch {
                print("error")
            }
            audioPlayer.play()
        } else {
            seconds -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds))
            
            //progress bar
            self.progress.completedUnitCount = progress.totalUnitCount - seconds
            self.timerProgress.setProgress(Float(self.progress.fractionCompleted), animated: true)
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeVC.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        stopButton.isEnabled = true
        stopButton.isHidden = false
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func resetHome(){
        timer.invalidate()
        audioPlayer.stop()
        
        //variable reset
        seconds = 0
        slider.value = 0
        isTimerRunning = false
        resumeTapped = false
        
        //label and image reset
        timerLabel.text = timeString(time: TimeInterval(seconds))
        topTextLabel.text = "Ready for napnap?"
        timerLabel.text = "Get comfy ok? Worry not, Nappy will wake you up!"
        timerLabel.font = timerLabel.font.withSize(21)
        nappyImage.image = UIImage(named: "NappyRevisi-1")
        
        //timer progress reset
        timerProgress.progress = 0.0
        self.progress.completedUnitCount = 0
        
        //button, slider, label setting
        stopButton.isEnabled = false
        stopButton.isHidden = true
        startButton.isEnabled = true
        startButton.isHidden = false
        resetButton.isHidden = true
        resumeButton.isHidden = true
        slider.isHidden = false
        timerProgress.isHidden = true
    }
    
    //alert setting
    func showAlertTimerNotSet() {
        let alert = UIAlertController(title: "Message", message: "Set the timer first!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
//    func showAlertTimesUp() {
//        let alert = UIAlertController(title: "Message", message: "Come on wake up!", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }
    
}
