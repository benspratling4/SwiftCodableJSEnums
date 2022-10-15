//
//  TypeEnumParser.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser


public class TypeEnumParser : SyntaxVisitor {
	
	public init(typeFile:String) {
		self.typeFile = typeFile
	}
	
	public var typeEnumDefinition:TypeEnumSpec? {
		guard let parsedNode = try? SyntaxParser.parse(source: typeFile) else { return nil }
		self.walk(parsedNode)
		guard let elementName = enumName else { return nil }
		
		return TypeEnumSpec(mainName: elementName, isPublic: isPublic)
	}
	var typeFile:String
	
	var enumName:String?
	var isPublic:Bool = false
	
	open override func visitPost(_ node: EnumDeclSyntax) {
		super.visitPost(node)
		enumName = node.identifier.withoutTrivia().description
		isPublic = node.modifiers?.filter({ $0.name.description == "public" }).count == 1
		
	}
	
}


public struct TypeEnumSpec {
	public var mainName:String
	public var isPublic:Bool
	//must have all the same cases as the main enum
	public init(mainName: String, isPublic: Bool) {
		self.mainName = mainName
		self.isPublic = isPublic
	}
}
