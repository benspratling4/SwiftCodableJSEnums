import Foundation

public struct EnumSpec {
	public var enumName:String
	public var typePropertyName:String
	public var typeTypeName:String
	public var isPublic:Bool = false
	
	public init(enumName: String, typePropertyName: String, typeTypeName: String, isPublic: Bool) {
		self.enumName = enumName
		self.typePropertyName = typePropertyName
		self.typeTypeName = typeTypeName
		self.isPublic = isPublic
	}
	
}


public struct EnumTypesFile {
	public var imports:[String] = []
	public var enums:[EnumSpec] = []
	
	public init(imports: [String], enums: [EnumSpec]) {
		self.imports = imports
		self.enums = enums
	}
	
	public init(fileContents:String) {
		//find imports - we may need these
		self.imports = fileContents
			.regExMatches(#"(^|\n|;[\s]+)import[\s]+.+(\n|$)"#)
			.compactMap({ $0.valueOfSwiftImport() })
		
		//find extensions
		self.enums = fileContents
			.regExMatches(#"extension[\s]+[\S]+[\s]*\{[\s]*var[\s]+[\S]+[\s]*:[\s]*[\S]+[\s]*\}"#)
			.compactMap({ $0.valueOfSwiftEnumExtension() })
	}
	
}


extension String {
	func rangesOfRegExMatches(_ regex:String)->[Range<String.Index>] {
		var startIndex = startIndex
		var matchingRanges:[Range<String.Index>] = []
		while let foundRange = range(of:regex, options:[.regularExpression], range:startIndex..<endIndex) {
			defer {
				startIndex = foundRange.upperBound
			}
			matchingRanges.append(foundRange)
		}
		return matchingRanges
	}
	
	func regExMatches(_ regex:String)->[String] {
		return rangesOfRegExMatches(regex).map { String(self[$0]) }
	}
	
	//provide an array of regex's, get back the things from in bewteen them
	func componentsInBetweenRegExes(_ regExes:[String])->[String]? {
		var cursorIndex = startIndex
		var foundComponents:[String] = []
		for (componentIndex, componentRegEx) in regExes.enumerated() {
			guard let newFoundRange = self.range(of: componentRegEx
												 , options: [.regularExpression]
												 , range: cursorIndex..<endIndex)
				else { return nil }
			defer {
				cursorIndex = newFoundRange.upperBound
			}
			guard componentIndex != 0 else { continue }
			//collected the intermediate string
			let fragmentRange = cursorIndex..<newFoundRange.lowerBound
			guard !fragmentRange.isEmpty else { return nil }
			let fragment = String(self[fragmentRange])
			foundComponents.append(fragment)
		}
		return foundComponents
	}
	
	fileprivate func valueOfSwiftImport()->String? {
		return componentsInBetweenRegExes([#"import[\s]+"#, #"(\n|$)"#])?.first
	}
	
	fileprivate func valueOfSwiftEnumExtension()->EnumSpec? {
		guard let components = self.componentsInBetweenRegExes([#"extension[\s]+"#, #"[\s]*\{[\s]*var[\s]+"#, #"[\s]*:[\s]*"#, #"[\s]*\}"#])
			,components.count == 3
			else { return nil }
		//TODO: read publicness
		return EnumSpec(enumName: components[0], typePropertyName: components[1], typeTypeName: components[2], isPublic: false)
	}
	
	
}
