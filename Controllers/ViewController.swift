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
    var stopwatch = "00:00.0" {
        willSet {
            timerButton.setTitle(newValue, for: .normal)
        }
    }
    
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
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    @objc func doubleTapped() {
        //save timer value
        print(stopwatch)
        stopTimer()
        stopwatch = "00:00.0"
        counter = 0.0
        presentSaveAlert()
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isRunning = true
    }
    @objc func updateTimer() {
        counter += 0.1
        let floored = Int(floor(counter))
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
        stopwatch = "\(minuteString):\(secondString).\(rest)"
        //timerButton.setTitle(stopwatch, for: .normal)
    }
    func stopTimer() {
        timer.invalidate()
        isRunning = false
    }
    
    
    func presentSaveAlert() {
        let ac = UIAlertController(title: "Save your result", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter a name"
        }
        let submitNameAction = UIAlertAction(title: "OK", style: .default) { [unowned ac] _ in
            var name: String {
                if let goodName = ac.textFields![0].text, !goodName.isEmpty {
                    return goodName
                } else {
                    return "My result"
                }
            }
            //let name = ac.textFields![0].text
            
            print(name)
        }
        ac.addAction(submitNameAction)
        present(ac, animated: true)
    }
    
    
    
    
    
    
    
    

}
