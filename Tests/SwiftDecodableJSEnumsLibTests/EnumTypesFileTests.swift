//
//  EnumTypesFileTests.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import XCTest
import SwiftDecodableJSEnumsLib

final class EnumTypesFileTests: XCTestCase {

	func testEnumTypesFile() {
		let file = """
import Foundation

import CustomFramework
import CGGraphics.MacExtensions


other code


public extension Transaction {
	var type:TransactionType
}
"""
		
		let enumsSpec = EnumTypesFile(fileContents: file)
		XCTAssertEqual(enumsSpec.imports.count, 3)
		XCTAssertEqual(enumsSpec.imports[0], "Foundation")
		XCTAssertEqual(enumsSpec.imports[1], "CustomFramework")
		XCTAssertEqual(enumsSpec.imports[2], "CGGraphics.MacExtensions")
		
		XCTAssertEqual(enumsSpec.enums.count, 1)
		XCTAssertEqual(enumsSpec.enums[0].enumName, "Transaction")
		XCTAssertEqual(enumsSpec.enums[0].typePropertyName, "type")
		XCTAssertEqual(enumsSpec.enums[0].typeTypeName, "TransactionType")
		
	}
	

}
