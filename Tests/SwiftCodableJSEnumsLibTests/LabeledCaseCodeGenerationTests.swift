//
//  LabeledCaseCodeGenerationTests.swift
//  
//
//  Created by Benjamin Spratling on 10/16/22.
//

import XCTest
@testable import SwiftCodableJSEnumsLib

final class LabeledCaseCodeGenerationTests: XCTestCase {

	func testGeneratingSimpleDecode() {
		let caseSpec = CaseSpec(name: "text", associatedValueName: "String")
		XCTAssertNil(caseSpec.additionalTypeName)
		XCTAssertNil(caseSpec.additionalTypeDefinition(decodable: true, encodable: true))
		
		XCTAssertEqual(caseSpec.decodingCaseCode, """
			case .text:
				self = .text(try decoder.singleValueContainer().decode(String.self))

""")
	}
	
	func testGeneratingSimpleEncode() {
		let caseSpec = CaseSpec(name: "text", associatedValueName: "String")
		XCTAssertNil(caseSpec.additionalTypeName)
		XCTAssertNil(caseSpec.additionalTypeDefinition(decodable: true, encodable: true))
		
		XCTAssertEqual(caseSpec.encodingCaseCode, """
			case .text(let value):
				try container.encode(value)

""")
	}
	
	
	func testGeneratingComplexDecoder() {
		let caseSpec = CaseSpec(name: "text"
								,values: CaseValues.multipleNamed([
									.init(label: "text", typeName: "String"),
									.init(label: "id", typeName: "String"),
								]))
		XCTAssertEqual(caseSpec.additionalTypeName, "CaseTextAssociatedValuesContainer")
		XCTAssertEqual(caseSpec.additionalTypeDefinition(decodable: true, encodable: true), """
private struct CaseTextAssociatedValuesContainer : Decodable, Encodable {
	var text:String
	var id:String
}

""")
		
		XCTAssertEqual(caseSpec.additionalTypeDefinition(decodable: true, encodable: false), """
private struct CaseTextAssociatedValuesContainer : Decodable {
	var text:String
	var id:String
}

""")
		
		XCTAssertEqual(caseSpec.additionalTypeDefinition(decodable: false, encodable: true), """
private struct CaseTextAssociatedValuesContainer : Encodable {
	var text:String
	var id:String
}

""")
		
		XCTAssertEqual(caseSpec.decodingCaseCode, """
			case .text:
				let value = try decoder.singleValueContainer().decode(CaseTextAssociatedValuesContainer.self)
				self = .text(text:value.text, id:value.id)

""")
		
	}
	
	
	func testComplexEncode() {
		let caseSpec = CaseSpec(name: "text"
								,values: CaseValues.multipleNamed([
									.init(label: "text", typeName: "String"),
									.init(label: "id", typeName: "String"),
								]))
		XCTAssertEqual(caseSpec.additionalTypeName, "CaseTextAssociatedValuesContainer")
		
		XCTAssertEqual(caseSpec.encodingCaseCode, """
			case .text(text:let textValue, id:let idValue):
				let payload = CaseTextAssociatedValuesContainer(text:textValue, id:idValue)
				try container.encode(payload)

""")
	}
	
}
