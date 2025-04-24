//
//  main.swift
//
//  Copyright © 2025 Fetch.
//

import Synchronization

class SharedClass {
    @Locked(.checked)
    var count: Int

    init(count: Int) {
        self.count = count
    }
}
