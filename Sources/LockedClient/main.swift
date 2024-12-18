//
//  main.swift
//
//  Created by Gray Campbell.
//  Copyright © 2024 Fetch.
//

import Locked
import Foundation

class SharedClass {
    @Locked(.ifAvailableChecked)
    var count: Int?
}
