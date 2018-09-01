//
//  wetter_model.swift
//  WetterMH
//
//  Created by Michael Holzinger on 18.08.18.
//  Copyright © 2018 Michael Holzinger. All rights reserved.
//

import Foundation

struct Wetter {
    
    var zeit : [String]
    var datum: [String]
    var temp : [Double]
    var luft: [Double]
    
    init() {
        self.zeit = []
        self.datum = []
        self.luft = []
        self.temp = []
    }
 
}
