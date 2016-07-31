//
//  RecentSearches.swift
//  Smashtag
//
//  Created by Florian Bienefelt on 7/8/16.
//  Copyright © 2016 Florian Bienefelt. All rights reserved.
//

import Foundation


extension NSUserDefaults {
    
    func addKeyAtTop (key: String) {
        let max = self.integerForKey("Max Recent")
        if self.stringForKey("1") != key {
            for ii in 1...max {
                let i = max - ii + 1
                if let storedKey = self.stringForKey(String(i)) {
                    if i != max {
                        self.setObject(storedKey, forKey: String(i+1))
                    }
                }
            }
            self.setObject(key, forKey: "1")
        }
    }
    
    func getAmountOfKeys() -> Int {
        let max = self.integerForKey("Max Recent")
        var count = 0
        for ii in 1...max {
            let i = max - ii + 1
            if (self.stringForKey(String(i)) != nil && self.stringForKey(String(i)) != "")  {
                count += 1
            }
        }
        return count
    }
}