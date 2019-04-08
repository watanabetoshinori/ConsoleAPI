//
//  Console.swift
//  ConsoleAPI
//
//  Created by Watanabe Toshinori on 4/8/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

public var console = Console()

public class Console: NSObject {
    
    private var writer: ConsoleOutputWriter!

    private var countStore = [String: Int]()
    
    private var timeStore = [String: Date]()
    
    private var groupStore = [String]()
    
    // MARK: - Initialize Console
    
    init(writer: ConsoleOutputWriter = PrintWriter()) {
        self.writer = writer
    }
    
    // MARK: - Log
    
    public func log(_ items: Any...) {
        _log(items)
    }
    
    public func info(_ items: Any...) {
        _log(items, symbol: "ℹ️")
    }
    
    public func debug(_ items: Any...) {
        _log(items, symbol: "▶️")
    }
    
    public func warn(_ items: Any...) {
        _log(items, symbol: "⚠️")
    }
    
    public func error(_ items: Any...) {
        _log(items, symbol: "🛑")
    }
    
    // MARK: - Count
    
    public func count(_ label: String = "Global") {
        mainAsync {
            var count = self.countStore[label] ?? 0
            count += 1
            self.countStore[label] = count
            
            self._log(["\(label): \(count)"])
        }
    }
    
    public func countReset(_ label: String = "Global") {
        mainAsync {
            self.countStore[label] = 0
        }
    }
    
    // MARK: - Group
    
    public func group(_ name: String = "") {
        mainAsync {
            self._log(["\(name)"], symbol: "🔽")
            self.groupStore.append(name)
        }
    }
    
    public func groupEnd() {
        mainAsync {
            self.groupStore.removeLast()
        }
    }
    
    // MARK: - Time

    public func time(_ label: String = "Global") {
        mainAsync {
            self.timeStore[label] = Date()
        }
    }
    
    public func timeEnd(_ label: String = "Global") {
        mainAsync {
            let now = Date()
            let date = self.timeStore.removeValue(forKey: label) ?? now
            let interval = now.timeIntervalSince(date)
            
            self._log(["\(label): \(interval)"])
        }
    }
    
    // MARK: - Trace
    
    public func trace() {
        _log(["---\n" + Thread.callStackSymbols.joined(separator: "\n") + "\n---"])
    }
    
    // MARK: - Table

    public func table(_ array: [Any]) {
        DispatchQueue.global().async {
            self._table(array)
        }
    }
    
    public func table(_ dict: [AnyHashable: Any]) {
        DispatchQueue.global().async {
            self._table(dict)
        }
    }

    public func _table(_ array: [Any]) {
        var headers = [Any]()
        var items = [[Any]]()
        
        var hasNonCollectionValue = false

        array.enumerated().forEach { (item) in
            let index = item.offset
            let value = item.element

            var values = [Any]()

            values.append(index)

            if let dict = value as? [AnyHashable: Any] {
                // Dictionary

                if hasNonCollectionValue {
                    values.append("")
                }

                headers.forEach({ (header) in
                    if let key = header as? AnyHashable, let value = dict[key] {
                        values.append(value)
                    } else {
                        values.append("")
                    }
                })
                
                dict.keys.forEach({ (key) in
                    if headers.first(where: { ($0 as? AnyHashable) == key }) == nil, let value = dict[key] {
                        headers.append(key)
                        values.append(value)
                    }
                })
                
            } else if let array = value as? [Any] {
                // Array

                if hasNonCollectionValue {
                    values.append("")
                }

                headers.forEach({ (header) in
                    if let index = header as? Int, array.count > index {
                        values.append(array[index])
                    } else {
                        values.append("")
                    }
                })
                
                array.enumerated().forEach({ (obj) in
                    let index = obj.offset
                    let value = obj.element
                    
                    if headers.first(where: { ($0 as? Int) == index }) == nil {
                        headers.append(index)
                        values.append(value)
                    }
                })

            } else {
                // Others

                hasNonCollectionValue = true
                
                values.append(value)
            }
            
            items.append(values)
        }
        
        headers.insert("(index)", at: 0)
        if hasNonCollectionValue {
            headers.insert("Values", at: 1)
        }

        var length = headers.map({ "\($0)".count })
        
        let rows = items.map { (row) in
            return (0..<headers.count).map({ (index) -> String in
                let value = (row.count > index) ? "\(row[index])" : ""
                length[index] = max(length[index], value.count)
                return value
            })
        }
    
        _table(headers: headers.map({ "\($0)" }), rows: rows, length: length)
    }
    
    private func _table(_ dict: [AnyHashable: Any]) {
        let headers = ["(index)", "Values"]

        var rows = [[String]]()
        var length = headers.map({ "\($0)".count })
        
        dict.keys.forEach { (key) in
            let row = ["\(key)", "\(dict[key] ?? "")"]
            rows.append(row)
            
            length = [max(length[0], row[0].count), max(length[1], row[1].count)]
        }

        _table(headers: headers, rows: rows, length: length)
    }
    
    private func _table(headers: [String], rows: [[String]], length: [Int]) {
        var lines = [String]()

        // Header
        lines.append(
            headers.enumerated()
                .reduce(into: [String](), { $0.append($1.element.padding(toLength: length[$1.offset], withPad: " ", startingAt: 0)) })
                .joined(separator: " ")
        )
        
        // Separator
        lines.append(
            headers.enumerated()
                .reduce(into: [String](), { $0.append(String(repeating: "-", count: length[$1.offset])) })
                .joined(separator: " ")
        )
        
        // Rows
        lines += rows.map({
            $0.enumerated()
                .reduce(into: [String](), { $0.append($1.element.padding(toLength: length[$1.offset], withPad: " ", startingAt: 0)) })
                .joined(separator: " ")
        })

        DispatchQueue.main.async {
            self._log([lines.joined(separator: "\n")])
        }
    }
    
    // MARK: - Private methods
    
    func _log(_ items: [Any], symbol: String = "") {
        let indent = String(repeating: "  ", count: groupStore.count)
        let prefix = symbol.isEmpty == false ? symbol + " " : ""
        let message = indent + prefix + items.map { "\($0)" }.joined(separator: " ")
        writer.write(message)
    }

    private func mainAsync(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }

}
