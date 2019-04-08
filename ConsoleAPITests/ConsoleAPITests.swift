//
//  ConsoleAPITests.swift
//  ConsoleAPITests
//
//  Created by Watanabe Toshinori on 4/10/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import XCTest
@testable import ConsoleAPI

class ConsoleAPITests: XCTestCase {
    
    var writer = VariableWriter()

    // MARK: - SetUp and TearDown
    
    override func setUp() {
        console = Console(writer: writer)
    }

    override func tearDown() {

    }
    
    // MARK: - Logging

    func testLogging() {
        console.log("log")
        console.info("info")
        console.debug("debug")
        console.warn("warn")
        console.error("error")

        XCTAssertEqual(writer.messages, [
            "log",
            "ℹ️ info",
            "▶️ debug",
            "⚠️ warn",
            "🛑 error"
        ])
    }
    
    func testCount() {
        console.count()
        console.count()
        console.count()
        
        XCTAssertEqual(writer.messages, [
            "Global: 1",
            "Global: 2",
            "Global: 3"
        ])
    }
    
    func testLabelCount() {
        console.count("aaa")
        console.count("aaa")
        console.count("bbb")
        
        XCTAssertEqual(writer.messages, [
            "aaa: 1",
            "aaa: 2",
            "bbb: 1"
        ])
    }
    
    func testCountReset() {
        console.count()
        console.count()
        console.countReset()
        console.count()

        XCTAssertEqual(writer.messages, [
            "Global: 1",
            "Global: 2",
            // Reset
            "Global: 1",
        ])
    }

    func testLabelCountReset() {
        console.count()
        console.count()
        console.count("aaa")
        console.count("aaa")
        console.count("bbb")
        console.count("bbb")
        console.countReset("aaa")
        console.count()
        console.count("aaa")
        console.count("bbb")

        XCTAssertEqual(writer.messages, [
            "Global: 1",
            "Global: 2",
            "aaa: 1",
            "aaa: 2",
            "bbb: 1",
            "bbb: 2",
            // Reset aaa
            "Global: 3",
            "aaa: 1",
            "bbb: 3",
        ])
    }
    
    func testGroup() {
        console.log("log")
        console.group()
        console.log("log")
        console.group("aaa")
        console.log("log")
        console.groupEnd()
        console.log("log")
        console.groupEnd()
        console.log("log")

        XCTAssertEqual(writer.messages, [
            "log",
            "🔽 ",
            "  log",
            "  🔽 aaa",
            "    log",
            "  log",
            "log",
        ])
    }
    
    func testTime() {
        console.time()
        console.timeEnd()
        console.time("aaa")
        console.time("bbb")
        console.timeEnd("aaa")
        console.timeEnd("bbb")
        
        XCTAssertNotNil(writer.messages[0].range(of: "Global: [0-9.]+", options: .regularExpression))
        XCTAssertNotNil(writer.messages[1].range(of: "aaa: [0-9.]+", options: .regularExpression))
        XCTAssertNotNil(writer.messages[2].range(of: "bbb: [0-9.]+", options: .regularExpression))
    }
    
    func testTrace() {
        console.trace()
        
        XCTAssertNotNil(writer.messages.first?.range(of: "---\n(.*\n)+---", options: .regularExpression))
    }
    
    func testTableFromArray() {
        console.table([1, 2, 3])
        
        let table = "(index) Values\n"
                    + "------- ------\n"
                    + "0       1     \n"
                    + "1       2     \n"
                    + "2       3     "

        let expectation = self.expectation(description: #function)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            expectation.fulfill()
        }
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        switch result {
        case .completed:
            XCTAssertEqual(writer.messages, [table])
        case .timedOut:
            XCTFail("Time out")
        default:
            XCTFail("Failure")
        }
    }

    func testTableFromArrayInArray() {
        console.table([1, 2, [3, 4]])
        
        let table = "(index) Values 0 1\n"
                  + "------- ------ - -\n"
                  + "0       1         \n"
                  + "1       2         \n"
                  + "2              3 4"
        
        waitAsyncResult {
            XCTAssertEqual(writer.messages, [table])
        }
    }

    func testTableFromDict() {
        console.table(["name": "John", "age": 20])
        
        let table = "(index) Values\n"
                  + "------- ------\n"
                  + "name    John  \n"
                  + "age     20    "
        
        waitAsyncResult {
            XCTAssertEqual(writer.messages, [table])
        }
    }

    func testTableFromDictArray() {
        console.table([["name": "John", "age": 20], ["name": "Michel", "age": 30]])
        
        let table = "(index) name   age\n"
                  + "------- ------ ---\n"
                  + "0       John   20 \n"
                  + "1       Michel 30 "
        
        waitAsyncResult {
            XCTAssertEqual(writer.messages, [table])
        }
    }
    
    func testTableFromDictInArray() {
        console.table([1, 2, ["name": "John"], ["age": 20]])
        
        let table = "(index) Values name age\n"
                  + "------- ------ ---- ---\n"
                  + "0       1              \n"
                  + "1       2              \n"
                  + "2              John    \n"
                  + "3                   20 "

        waitAsyncResult {
            XCTAssertEqual(writer.messages, [table])
        }
    }
    
    func testTableFromComplex() {
        console.table([1, 2, ["ccc": 4], [3, 4], ["bbb": "test"], [5, 6, 7]])
        
        let table = "(index) Values ccc 0 1 bbb  2\n"
                  + "------- ------ --- - - ---- -\n"
                  + "0       1                    \n"
                  + "1       2                    \n"
                  + "2              4             \n"
                  + "3                  3 4       \n"
                  + "4                      test  \n"
                  + "5                  5 6      7"

        waitAsyncResult {
            XCTAssertEqual(writer.messages, [table])
        }
    }

    // MARK: - Utility
    
    func waitAsyncResult(handler: () -> Void ) {
        let expectation = self.expectation(description: #function)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            expectation.fulfill()
        }
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        switch result {
        case .completed:
            handler()
        case .timedOut:
            XCTFail("Time out")
        default:
            XCTFail("Failure")
        }
    }
    
}
