import Foundation
import SwiftDecodableJSEnumsLib

let arguments = ProcessInfo.processInfo.arguments
guard arguments.count >= 4 else {
	fatalError("arguments.count = \(arguments.count), should be at least 5")
}


let mainEnumTypeFilePath = arguments[1]
let typeEnumTypeFilePath = arguments[2]
let outputFilePath = arguments[3]
//let extensionFilePath = arguments[4]	//TODO: get type property name and is public, maybe send path to .swiftJSEnum file?


let mainUrl = URL(fileURLWithPath: mainEnumTypeFilePath)
let originalEnum = mainUrl.deletingPathExtension().lastPathComponent

let typeUrl = URL(fileURLWithPath: typeEnumTypeFilePath)
let typeEnum = typeUrl.deletingPathExtension().lastPathComponent

//TODO: fix type property name and isPublic to be correct
//TODO: support arbitrary imports
let spec = EnumSpec(enumName: originalEnum, typePropertyName: "type", typeTypeName: typeEnum, isPublic: false)

//this is a static sample to test output incrementally
let outputFile = DefaultDecodableJSCreator(EnumDecoderSpec(imports: []
														   , mainTypeName: "Transaction"
														   , mainTypeIsPublic: false	//TODO: fix me
														   , typePropertyName: "type"
														   , typeTypeName: "TransactionType"
														   ,typeTypeIsPublic:false	//TODO: fix me
														   , cases: [
															CaseSpec(name: "add", associatedValueName: "NewTransaction"),
															CaseSpec(name: "update", associatedValueName: "TransactionChange"),
															CaseSpec(name: "delete", associatedValueName: "TransactionDeletion"),
														   ]))
	.outputFile
	.data(using: .utf8)!

try outputFile.write(to: URL(fileURLWithPath: outputFilePath))

/*
try XCAssetAnalyzer(urlToXCAsset: URL(fileURLWithPath: inputFilePath)
					, context: isXcodeProject ? .xcodeProject : .swiftPackage)
	.fileContents()
	.write(to: URL(fileURLWithPath: outputFilePath))
*/
