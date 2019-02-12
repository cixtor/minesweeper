//
//  PersistableService.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import CoreData

class PersistableService {
    enum Constants {
        static let gameOptionsKey = "gameOptions"
        static let audioOptionsKey = "audioOptions"
        static let coreDataName = "Database"
    }
    
    static let shared = PersistableService()
    
    private let coreDataManager = Database(name: Constants.coreDataName)
    
    private init(){
        self.setupPersistOnAppExit()
    }
    
    // MARK: - CoreData
    private func setupPersistOnAppExit() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(commitAllChangesToDisk),
                                       name: UIApplication.willTerminateNotification, object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(commitAllChangesToDisk),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func selectManagedContext() -> NSManagedObjectContext {
        if let backgroundContext = self.coreDataManager.backgroundManagedObjectContext {
            return backgroundContext
        }
        
        if let mainContext = self.coreDataManager.mainManagedObjectContext {
            return mainContext
        }
        
        return self.coreDataManager.memoryManagedObjectContext
    }
    
    @objc func commitAllChangesToDisk() {
        self.coreDataManager.commitAllChangesToDisk()
    }
    
    // MARK: - UserDefaults
    static func saveAudioOptions(to userDefaults: UserDefaults = UserDefaults.standard, audioOptions: AudioOptions) {
        if let encodedData = try? JSONEncoder().encode(audioOptions) {
            userDefaults.set(encodedData, forKey: Constants.audioOptionsKey)
            userDefaults.synchronize()
        }
    }
    
    static func getAudioOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> AudioOptions {
        if let decoded  = userDefaults.object(forKey: Constants.audioOptionsKey) as? Data,
            let audioOptions = try? JSONDecoder().decode(AudioOptions.self, from: decoded) {
            return audioOptions
        }
        
        return AudioOptions()
    }
    
    static func saveGameOptions(to userDefaults: UserDefaults = UserDefaults.standard, gameOptions: GameOptions) {
        if let encodedData = try? JSONEncoder().encode(gameOptions) {
            userDefaults.set(encodedData, forKey: Constants.gameOptionsKey)
            userDefaults.synchronize()
        }
    }
    
    static func getGameOptions(from userDefaults: UserDefaults = UserDefaults.standard) -> GameOptions {
        if let decoded  = userDefaults.object(forKey: Constants.gameOptionsKey) as? Data,
            let gameOptions = try? JSONDecoder().decode(GameOptions.self, from: decoded) {
            return gameOptions
        }
        
        return GameOptions()
    }
}
