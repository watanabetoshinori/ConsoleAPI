//
//  PrintWriter.swift
//  ConsoleAPI
//
//  Created by Watanabe Toshinori on 4/9/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class PrintWriter: ConsoleOutputWriter {
    
    func write(_ message: String) {
        Swift.print(message)
    }
    
}
