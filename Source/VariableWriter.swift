//
//  VariableWriter.swift
//  ConsoleAPI
//
//  Created by Watanabe Toshinori on 4/9/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class VariableWriter: ConsoleOutputWriter {
    
    var messages = [String]()
    
    func write(_ message: String) {
        messages.append(message)
    }
    
}
