# ConsoleAPI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

ConsoleAPI is a framework that allows you to write information to the Xcode console. 
This framework inspired by the JavaScript Console API.

- [Features](#Features)
- [Getting Started](#getting-started)
    - [Requirements](#requirements)
    - [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Logging](#loggin)
    - [Count](#count)
    - [Group](#group)
    - [Time](#time)
    - [Table](#table)
    - [Trace](#trace)
- [Author](#author)
- [License](#license)

## Features
- [x] log / info / debug / warn / error
- [x] count / countEnd
- [x] group / groupEnd
- [x] time / timeEnd
- [x] table
- [x] trace

## Getting Started

### Requirements

* iOS 12.0+
* Xcode 10.0+
* Swift 4.2+

### Installation

**[Cocoa Pods](https://cocoapods.org)**

```sh
pod "ConsoleAPI", :git => 'https://github.com/watanabetoshinori/ConsoleAPI.git', :branch => 'master'
```

## Usage

### Initialization

```swift
import ConsoleAPI
```

### Logging

Display the message.

```swift
console.log("Hello, Logs!")	// Hello, Logs!

console.info("This is info.")	// ℹ️ This is info.

console.debug("This is debug.")	// ▶️ This is debug.

console.warn("This is warn.")	// ⚠️ This is warn.

console.error("This is error.")	// 🛑 This is error.
```

### Count

Display the number of times that count has been invoked.

```swift
console.count()	// Global: 1

console.count()	// Global: 2

console.countReset()

console.count()	// Global: 1
```

### Group

Indent the message when starting a new group.

```swift
console.group() 
console.log("This is log.")
console.groupEnd()
console.log("This is log.")

// 🔽
//   This is log.
// This is log.
```

### Time

Display the elapsed time from `time` to `timeEnd`.

```swift
console.time()

console.timeEnd()	// Global: 0.123
```

### Table

Display an array of objects as a table.

```swift
console.table([1, 2, 3])

// (index) Values
// ------- ------
// 0       1
// 1       2
// 2       3

console.table([1, 2, ["name": "John"], [3, 4], ["country": "Japan", "year": 2019]])

// (index) Values name 0 1 country year
// ------- ------ ---- - - ------- ----
// 0       1                    
// 1       2                    
// 2              John            
// 3                   3 4       
// 4                       Japan   2019
```

### Trace

Display the stack trace.

```swift
console.trace()
```

## Author

Watanabe Toshinori – toshinori_watanabe@tiny.blue

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
