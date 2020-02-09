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
    var counter = 0.0
    var stopwatch = "00:00.0" {
        willSet {
            timerButton.setTitle(newValue, for: .normal)
        }
    }
    
    var stopwatches = [Stopwatch]() {
        willSet {
            if newValue.count == 0 {
                let emptyView = EmptyTableView.instanceFromNib()
                tableView.backgroundView = emptyView
            } else {
                tableView.backgroundView = nil
            }
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        fetchStopwatches()

        NotificationCenter.default.addObserver(self, selector: #selector(savePauseDate), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchStopwatches), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    
    
    func setUpGestureRecognizers() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        timerButton.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        timerButton.addGestureRecognizer(singleTap)
    }
    
    @objc func fetchStopwatches() {
        let allStopwatches = persistenceManager.fetch(Stopwatch.self)
        stopwatches = [Stopwatch]()
        for stopwatch in allStopwatches {
            if !stopwatch.isFinished {
                currentStopwatch = stopwatch
                setCurrentStopwatch()
            } else {
                stopwatches.append(stopwatch)
            }
        }
        tableView.reloadData()
    }
    
    func setCurrentStopwatch() {
        let fullTimeInterval = Date().timeIntervalSince(currentStopwatch!.startDate)
        if currentStopwatch!.isRunning {
            //RUNNING
        } else {
            //PAUSED
            let pauseDate = currentStopwatch!.pauseDate!
            let pauseToAdd = Date().timeIntervalSince(pauseDate)
            currentStopwatch!.totalPauseTime += pauseToAdd
            //adding exess pauseTime. Not working
            counter = fullTimeInterval - currentStopwatch!.totalPauseTime
            transformCounterToStopwatch()
        }
    }
    
    
    @objc func singleTapped() {
        if currentStopwatch == nil {
            currentStopwatch = Stopwatch(context: persistenceManager.context)
            currentStopwatch?.startDate = Date()
            currentStopwatch?.isRunning = true
            startTimer()
        }
        else if currentStopwatch!.isRunning {
            stopTimer()
            currentStopwatch?.pauseDate = Date()
        } else {
            startTimer()
            print(Date().timeIntervalSince(currentStopwatch!.pauseDate!))
            currentStopwatch?.totalPauseTime += Date().timeIntervalSince(currentStopwatch!.pauseDate!)
            print("Total pause time = ", currentStopwatch?.totalPauseTime)
        }
        persistenceManager.save()
    }
    
    
    @objc func doubleTapped() {
        stopTimer()
        currentStopwatch?.isFinished = true
        currentStopwatch?.finishTimeString = stopwatch
        currentStopwatch?.name = "My result"
        persistenceManager.save()
        counter = 0.0
        presentSaveAlert()
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        currentStopwatch?.isRunning = true
    }
    @objc func updateTimer() {
        counter += 0.1
        transformCounterToStopwatch()
    }
    
    func transformCounterToStopwatch() {
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
        currentStopwatch?.isRunning = false
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
            self.currentStopwatch?.name = name
            self.stopwatches.append(self.currentStopwatch!)
            self.currentStopwatch = nil
            self.persistenceManager.save()
            self.stopwatch = "00:00.0"
            self.tableView.reloadData()
        }
        ac.addAction(submitNameAction)
        present(ac, animated: true)
    }
    
    
    @objc func savePauseDate() {
        guard currentStopwatch != nil else { return }
        timer.invalidate()
        
        //currentStopwatch!.pauseDate = Date()
        persistenceManager.save()
    }
    
    
    
    

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopwatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopwatchCell") as! TimerTableViewCell
        cell.nameLabel.text = stopwatches[indexPath.row].name
        cell.timeLabel.text = stopwatches[indexPath.row].finishTimeString
        
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
