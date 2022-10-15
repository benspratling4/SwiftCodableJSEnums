//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/14/22.
//

import Foundation
import PackagePlugin
//import SwiftDecodableJSEnumsLib


@main
struct SwiftXCAssetConstants: BuildToolPlugin {
	/// This entry point is called when operating on a Swift package.
	func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
		guard let target = target as? SourceModuleTarget else { return [] }
		let files = target.sourceFiles(withSuffix: "swiftJSEnum")
		print("relevant files \(files)")
		let enumSpecs = files
			.compactMap({ try? Data(contentsOf:URL(fileURLWithPath: $0.path.string) ) })
			.compactMap({ String(data:$0, encoding:.utf8) })
			.compactMap({ EnumTypesFile(fileContents: $0) })
			.flatMap({ $0.enums })
		
		print("found \(enumSpecs)")
		return try enumSpecs.map { enumSpec in
			//look for the source files
			guard let mainFile = target.sourceFiles.filter({ $0.path.lastComponent == enumSpec.enumName + ".swift" }).first else { throw GenericError.error }
			guard let typeFile = target.sourceFiles.filter({ $0.path.lastComponent == enumSpec.typeTypeName + ".swift" }).first else { throw GenericError.error }
			let base = mainFile.path.stem
			let appDir = context.pluginWorkDirectory.appending(target.moduleName)
			let output = appDir.appending(base + "+JSTypeDecodable.swift")
			//output file
			return .buildCommand(displayName: "Synthesize JS-compatible init(from:Decoder) method for \(base)"
								 ,executable: try context.tool(named: "SwiftDecodableJSEnumsExec").path
								 ,arguments:[mainFile.path.string, typeFile.path.string, output.string]
								 ,inputFiles: [mainFile.path, typeFile.path]
								 ,outputFiles: [output])
		}
		
		
		
		
		//now look for those files
		
//		return []
		
		//TODO: write me
		
//		fatalError("write me")
		
		/*
		return try target
			.sourceFiles(withSuffix: "xcassets")
			.enumerated()
			.map({ (offset, xsd) in
				let base = xsd.path.stem
				let input = xsd.path
				let appDir = context.pluginWorkDirectory.appending(target.moduleName)
				let output = appDir.appending("\(base)_ui_constants.swift")
//				print("working dir \(appDir)")
//				return .prebuildCommand(displayName: "Create UIColor and UIImage constants from \(base).xcassets"
//										, executable: try context.tool(named: "SwiftXCAssetConstantsExec").path
//										, arguments: [input.string, output.string]
//										, outputFilesDirectory: appDir)

				return .buildCommand(displayName: "Create UIColor and UIImage constants from \(base).xcassets"
									 ,executable: try context.tool(named: "SwiftXCAssetConstantsExec").path
									 ,arguments:[input.string, output.string]
									 ,inputFiles: [input]
									 ,outputFiles: [output])
			})
		 */
	}
}


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



enum GenericError : Error {
	case error
}
