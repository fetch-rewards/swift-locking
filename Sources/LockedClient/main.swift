//
//  main.swift
//  LockedClient
//
//  Created by Gray Campbell on 7/20/24.
//

import Locked

class SharedClass {
    @Locked(.checked)
    var count = Int.zero

    init(count: Int) {
        self.count = count
    }
}
