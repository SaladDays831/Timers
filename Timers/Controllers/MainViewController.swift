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
    
    @IBOutlet weak var tutorial1Label: UILabel!
    @IBOutlet weak var tutorial2Label: UILabel!
    
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
        if UserDefaults.standard.bool(forKey: "showTutorial") {
            tutorial1Label.isHidden = false
            tutorial2Label.isHidden = false
            UserDefaults.standard.set(false, forKey: "showTutorial")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestureRecognizers()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        NotificationCenter.default.addObserver(self, selector: #selector(performCloseActions), name: UIApplication.willResignActiveNotification, object: nil)
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
        if currentStopwatch!.isRunning {
            counter = currentStopwatch!.counter + Date().timeIntervalSince(currentStopwatch!.breakDate!)
            startTimer()
        } else {
            counter = currentStopwatch!.counter
            transformCounterToStopwatch()
        }
    }
    
    
    @objc func singleTapped() {
        if !tutorial1Label.isHidden {
            hideTutorial()
        }
        if currentStopwatch == nil {
            currentStopwatch = Stopwatch(context: persistenceManager.context)
            startTimer()
        }
        else if currentStopwatch!.isRunning {
            stopTimer()
        } else {
            startTimer()
        }
        persistenceManager.save()
    }
    
    
    @objc func doubleTapped() {
        stopTimer()
        currentStopwatch?.isFinished = true
        currentStopwatch?.finishedTimeString = stopwatch
        currentStopwatch?.name = "My result"
        persistenceManager.save()
        counter = 0.0
        presentSaveAlert()
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
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
    
    
    @objc func performCloseActions() {
        guard currentStopwatch != nil else { return }
        timer.invalidate()
        currentStopwatch?.counter = counter
        if currentStopwatch!.isRunning {
            currentStopwatch!.breakDate = Date()
        }
        persistenceManager.save()
    }
    
    func hideTutorial() {
        UIView.animate(withDuration: 1, animations: {
            self.tutorial2Label.alpha = 0
            self.tutorial1Label.alpha = 0
        }) { (success) in
            if success {
                self.tutorial2Label.isHidden = true
                self.tutorial1Label.isHidden = true
            }
        }
    }
    
    
    
    

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopwatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopwatchCell") as! TimerTableViewCell
        cell.nameLabel.text = stopwatches[indexPath.row].name
        cell.timeLabel.text = stopwatches[indexPath.row].finishedTimeString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            persistenceManager.delete(stopwatches[indexPath.row])
            persistenceManager.save()
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
