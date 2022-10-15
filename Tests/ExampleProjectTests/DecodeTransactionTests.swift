//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation
import XCTest
@testable import ExampleProject


class DecodeTransactionTests : XCTestCase {
	
	
	
	func testDecoding()throws {
		let json:Data = """
[
{"type":"create", "name":"New Transation 0"},
{"type":"update", "id":"0", "name":"Changed Transaction Name"},
{"type":"delete", "id":"0"},
]
""".data(using: .utf8)!
		
		let values = try JSONDecoder().decode([Transaction].self, from: json)
		XCTAssertEqual(values.count, 3)
		
		
		
	}
	
	
}
