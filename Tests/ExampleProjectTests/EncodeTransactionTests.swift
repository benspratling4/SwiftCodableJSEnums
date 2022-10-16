//
//  EncodeTransactionTests.swift
//  
//
//  Created by Benjamin Spratling on 10/16/22.
//

import XCTest
@testable import ExampleProject
import Foundation

final class EncodeTransactionTests: XCTestCase {
	
	func testEncoding() throws {
		let values:[Transaction] = [
			.add(NewTransaction(name: "New Transaction 0")),
			.update(TransactionChange(id: "0", name: "Changed Transaction Name")),
			.delete(TransactionDeletion(id: "0"))
		]
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys]
		let json = try encoder.encode(values)
		
		let stringVersion = String(data: json, encoding: .utf8)!
		let expectedOutput = """
  [{"name":"New Transaction 0","type":"create"},{"id":"0","name":"Changed Transaction Name","type":"update"},{"id":"0","type":"delete"}]
  """
		//useful for comparing unequal strings when debugging test failures
//		print(stringVersion)
//		print(expectedOutput)
		
		XCTAssertEqual(stringVersion, expectedOutput)
		
	}
	
	
}
