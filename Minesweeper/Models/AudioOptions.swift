//
//  AudioOptions.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation

struct AudioOptions: Codable {
    var isMusicEnabled: Bool = true
    var isSoundEffectsEnabled: Bool = true
    
    init(musicEnabled: Bool = true, sfxEnabled: Bool = true) {
        self.isMusicEnabled = musicEnabled
        self.isSoundEffectsEnabled = sfxEnabled
    }
}
