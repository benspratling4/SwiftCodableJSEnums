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
	}
	
	public var mainEnumDefinition:MainEnumSpec? {
		guard let parsedNode = try? SyntaxParser.parse(source: mainFile) else { return nil }
		self.walk(parsedNode)
		guard let elementName = enumName else { return nil }
		
		return MainEnumSpec(mainName: elementName, isPublic: isPublic, cases: cases)
	}
	
	var mainFile:String
	
	var cases:[CaseSpec] = []
	var enumName:String?
	var isPublic:Bool = false
	
	open override func visitPost(_ node: EnumCaseDeclSyntax) {
		super.visitPost(node)
		for element in node.elements {
			guard let firstParameter = element.associatedValue?.parameterList.first else {
				continue
			}
			cases.append(CaseSpec(name: element.identifier.description, associatedValueName: firstParameter.description))
		}
	}
	
	
	open override func visitPost(_ node: EnumDeclSyntax) {
		super.visitPost(node)
		enumName = node.identifier.withoutTrivia().description
		isPublic = node.modifiers?.filter({ $0.name.text == "public" }).count == 1
		
	}
	
}

public struct MainEnumSpec {
	public var mainName:String
	public var isPublic:Bool
	public var cases:[CaseSpec]
	public init(mainName: String, isPublic: Bool, cases: [CaseSpec]) {
		self.mainName = mainName
		self.isPublic = isPublic
		self.cases = cases
	}
}



