//
//  ViewController.swift
//  Timers
//
//  Created by Danil Kurilo on 07.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var persistenceManager: PersistenceManager!
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var pastTimersView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()
    var currentStopwatch: Stopwatch?
    var isRunning = false
    var counter = 0.0
    var stopwatch = "00:00.0" {
        willSet {
            timerButton.setTitle(newValue, for: .normal)
        }
    }
    
    var stopwatches = [Stopwatch]()
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        timerButton.makeSoft()
        pastTimersView.makeSoft()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestureRecognizers()
        tableView.delegate = self
        tableView.dataSource = self
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
        persistenceManager.save()
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
        counter = 0.0
        presentSaveAlert()
    }
    
    
    func startTimer() {
        //create new stopwatch if current is empty
        if currentStopwatch == nil {
            //currentStopwatch = Stopwatch(isRunning: true, isFinished: false, startDate: Date())
        }
        //stopwatches.append(currentStopwatch!)
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
    }
    func stopTimer() {
        timer.invalidate()
        isRunning = false
        //currentStopwatch?.isRunning = false
    }
    
    
    func presentSaveAlert() {
        let ac = UIAlertController(title: "Save your result", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter a name"
            textField.delegate = self
        }
        let submitNameAction = UIAlertAction(title: "OK", style: .default) { [unowned ac] _ in
            var name: String {
                if let goodName = ac.textFields![0].text, !goodName.isEmpty {
                    return goodName
                } else {
                    return "My result"
                }
            }
            //do stuff with name
            //let finishedStopwatch = Stopwatch(time: self.stopwatch, name: name)
            //self.pastStopwatches.append(finishedStopwatch)
            self.stopwatch = "00:00.0"
            self.tableView.reloadData()
        }
        ac.addAction(submitNameAction)
        present(ac, animated: true)
    }
    
    
    
    
    
    
    
    

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopwatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopwatchCell") as! TimerTableViewCell
        //cell.nameLabel.text = stopwatches[indexPath.row].name
        //cell.timeLabel.text = stopwatches[indexPath.row].time
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            stopwatches.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        }
    }
    
}


extension MainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 15
    }
    
    
}
