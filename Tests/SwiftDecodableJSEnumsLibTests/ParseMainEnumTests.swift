//
//  ParseMainEnumTests.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import XCTest
@testable import SwiftDecodableJSEnumsLib

final class ParseMainEnumTests: XCTestCase {

	func testParseMainEnum () {
			let file = """
import Foundation

public enum Transaction : Decodable {
	case add(NewTransaction)
	case update(TransactionChange)
	case delete(TransactionDeletion)
}

"""
		let parser =  MainEnumParser(mainFile: file)
		
		guard let definition = parser.mainEnumDefinition else {
			XCTFail("didn't parse main enum")
			return
		}
		
		XCTAssertEqual(definition.mainName, "Transaction")
		XCTAssertEqual(definition.cases.count, 3)
		XCTAssertEqual(definition.cases[0].name, "add")
		XCTAssertEqual(definition.cases[0].associatedValueName, "NewTransaction")
		
		XCTAssertEqual(definition.cases[1].name, "update")
		XCTAssertEqual(definition.cases[1].associatedValueName, "TransactionChange")
		
		XCTAssertEqual(definition.cases[2].name, "delete")
		XCTAssertEqual(definition.cases[2].associatedValueName, "TransactionDeletion")
	}

}
