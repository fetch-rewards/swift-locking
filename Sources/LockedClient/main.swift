//
//  main.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

import Locked

class SharedClass {
    @Locked(.checked)
    var count = Int.zero

    init(count: Int) {
        self.count = count
    }
}
