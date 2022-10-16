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
		
		guard case .add(let payload) = values[0] else {
			XCTFail("first value was not add")
			return
		}
		XCTAssertEqual(payload.name, "New Transation 0")
		
		guard case .update(let payload) = values[1] else {
			XCTFail("second value was not an update")
			return
		}
		XCTAssertEqual(payload.id, "0")
		XCTAssertEqual(payload.name, "Changed Transaction Name")
		
		guard case .delete(id: let payload) = values[2] else {
			XCTFail("second value was not an delete")
			return
		}
		XCTAssertEqual(payload, "0")
		
	}
	
}
