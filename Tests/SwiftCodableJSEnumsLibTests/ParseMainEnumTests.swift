//
//  ParseMainEnumTests.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import XCTest
@testable import SwiftCodableJSEnumsLib

final class ParseMainEnumTests: XCTestCase {

	func testParsePublicDecodable () {
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
		
		XCTAssertTrue(definition.isPublic)
		XCTAssertTrue(definition.decodable)
		XCTAssertFalse(definition.encodable)
	}

	
	func testParsePublicEncodable () {
			let file = """
import Foundation

public enum Transaction : Encodable {
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
		
		XCTAssertTrue(definition.isPublic)
		XCTAssertFalse(definition.decodable)
		XCTAssertTrue(definition.encodable)
	}
	
	
	func testParseInternalCodable () {
			let file = """
import Foundation

enum Transaction : Codable {
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
		
		XCTAssertFalse(definition.isPublic)
		XCTAssertTrue(definition.decodable)
		XCTAssertTrue(definition.encodable)
	}
	
	
	func testParseInternalEncodableandDecodable () {
			let file = """
import Foundation

enum Transaction : Decodable, Encodable {
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
		
		XCTAssertFalse(definition.isPublic)
		XCTAssertTrue(definition.decodable)
		XCTAssertTrue(definition.encodable)
	}

}
