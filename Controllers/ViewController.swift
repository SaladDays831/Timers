//
//  ViewController.swift
//  Timers
//
//  Created by Danil Kurilo on 07.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var pastTimersView: UIView!
    
    var timer = Timer()
    var isRunning = false
    var counter = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        timerButton.makeSoft()
        pastTimersView.makeSoft()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestureRecognizers()
    }

    func setUpGestureRecognizers() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        timerButton.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        timerButton.addGestureRecognizer(singleTap)
    }
    
    
    @objc func singleTapped() {
        //Pause timer. If paused - play
        startTimer()
    }
    
    @objc func doubleTapped() {
        //save timer value
        //Set to 0
        //Present alert
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isRunning = true
        
    }
    
    
    
    
    
    @objc func updateTimer() {
        counter += 0.1
        let floored = Int(floor(counter))
        //let hour = floored / 3600
        let minute = (floored % 3600) / 60
        var minuteString = String(minute)
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        let second = (floored % 3600) % 60
        var secondString = String(second)
        if second < 10 {
            secondString = "0\(second)"
        }
        let rest = String(format: "%.1f", counter).components(separatedBy: ".").last!
        let stopwatch = "\(minuteString):\(secondString).\(rest)"
        timerButton.setTitle(stopwatch, for: .normal)
    }
    
    
    
    
    
    
    
    

}


extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}
