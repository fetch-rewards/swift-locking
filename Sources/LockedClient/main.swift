//
//  main.swift
//  LockedClient
//
//  Created by Gray Campbell on 7/20/24.
//

import Locked

class SharedClass {
    @Locked(.checked)
    var mutableProperty: Int = 5

    init(value: Int) {
        self.mutableProperty = value
    }
}
