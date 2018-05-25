//
//  GameTimer.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation

protocol GameTimerDelegate {
    func onTimerUpdate(seconds: Int, timeString: String) -> Void
}

class GameTimer {
    private var gameTimer: Timer?
    private var delegate: GameTimerDelegate?
    private var seconds: Int = 0
    
    init(_ handler: GameTimerDelegate) {
        self.delegate = handler
    }
    
    func startTimer() {
        self.gameTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true)
    }
    
    func resumeTimer() {
        self.startTimer()
    }
    
    func pauseTimer() {
        self.gameTimer?.invalidate()
    }
    
    func resetTimer() {
        self.seconds = 0
        self.gameTimer?.invalidate()
    }
    
    func restartTimer() {
        self.resetTimer()
        self.startTimer()
    }
    
    func stopTimer() {
        self.pauseTimer()
        self.resetTimer()
    }
    
    @objc private func updateCounter() {
        self.seconds += 1
        let time = self.getPrettyTime(from: self.seconds)
        self.delegate?.onTimerUpdate(seconds: self.seconds, timeString: time)
    }
    
    private func getPrettyTime(from seconds: Int) -> String {
        var outputTime = ""
        
        let hourDigit: Int = seconds / 3600
        let minuteDigit: Int = (seconds / 60) % 60
        let secondDigit = seconds % 60
        
        if hourDigit > 0 {
            var hourString = String(describing: hourDigit)
            
            if hourString.count < 2 {
                hourString = "0\(hourString)"
            }
            
            outputTime.append("\(hourString):")
        }
        
        var minuteString = String(describing: minuteDigit)
        
        if minuteString.count < 2 {
            minuteString = "0\(minuteString)"
        }
        
        var secondString = String(describing: secondDigit)
        
        if secondString.count < 2 {
            secondString = "0\(secondString)"
        }
        
        outputTime.append("\(minuteString):\(secondString)")
        
        return outputTime
    }
}

