//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//


import Foundation
import SwiftSyntax
import SwiftSyntaxParser


//super helpful web tool for understanding the type names
//https://swift-ast-explorer.com

public class MainEnumParser : SyntaxVisitor {
	
	public init(mainFile:String) {
		self.mainFile = mainFile
		super.init(viewMode: .fixedUp)
	}
	
	public var mainEnumDefinition:MainEnumSpec? {
		guard let parsedNode = try? SyntaxParser.parse(source: mainFile) else { return nil }
		self.walk(parsedNode)
		guard let elementName = enumName else { return nil }
		
		return MainEnumSpec(mainName: elementName
							,isPublic: isPublic
							,cases:cases
							,decodable:decodable
							,encodable:encodable
		)
	}
	
	var mainFile:String
	
	var cases:[CaseSpec] = []
	var enumName:String?
	var isPublic:Bool = false
	var decodable:Bool = false
	var encodable:Bool = false
	
	open override func visitPost(_ node: EnumCaseDeclSyntax) {
		super.visitPost(node)
		for element in node.elements {
			guard let parameterList = element.associatedValue?.parameterList else { continue }
			if parameterList.count == 0 {
				//fail for now, maybe support this one day?
				continue
			}
			else if parameterList.count == 1		//if there is one argument, and it is not labeled, we wrap everything up into a subtype
				,let firstParameter = parameterList.first
				,firstParameter.firstName == nil
				,let parameterType = firstParameter.type {
				cases.append(CaseSpec(name: element.identifier.description
									  ,associatedValueName: parameterType.withoutTrivia().description))
			}
			else {
				//unless we have a single unnamed argument, all must be labeled
				guard parameterList.filter({ $0.firstName == nil }).count == 0 else {
					continue
				}
				cases.append(CaseSpec(name: element.identifier.description
									  ,values: .multipleNamed(
										parameterList.map({ .init(label: $0.firstName!.withoutTrivia().text, typeName: $0.type!.withoutTrivia().description) })
									  )))
			}
		}
	}
	
	
	open override func visitPost(_ node: EnumDeclSyntax) {
		super.visitPost(node)
		enumName = node.identifier.withoutTrivia().description
		isPublic = node.modifiers?.filter({ $0.name.text == "public" }).first != nil
		decodable = node.isDecodable
		encodable = node.isEncodable
	}
	
}

public struct MainEnumSpec {
	public var mainName:String
	public var isPublic:Bool
	public var cases:[CaseSpec]
	public var decodable:Bool
	public var encodable:Bool
	public init(mainName: String
				,isPublic: Bool
				,cases: [CaseSpec]
				,decodable:Bool
				,encodable:Bool
	) {
		self.mainName = mainName
		self.isPublic = isPublic
		self.cases = cases
		self.decodable = decodable
		self.encodable = encodable
	}
}


extension TypeInheritanceClauseSyntax {
	func inherits(from typeName:String)->Bool {
		return inheritedTypeCollection.filter({ $0.typeName.withoutTrivia().lastToken?.text == typeName }).count > 0
	}
}

extension EnumDeclSyntax {
	var isDecodable:Bool {
		inheritanceClause?.inherits(from:"Codable") ?? false || inheritanceClause?.inherits(from:"Decodable") ?? false
	}
	var isEncodable:Bool {
		inheritanceClause?.inherits(from:"Codable") ?? false || inheritanceClause?.inherits(from:"Encodable") ?? false
	}
}

