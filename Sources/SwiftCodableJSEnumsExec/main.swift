import Foundation
import SwiftCodableJSEnumsLib

let arguments = ProcessInfo.processInfo.arguments
guard arguments.count >= 4 else {
	fatalError("arguments.count = \(arguments.count), should be at least 4")
}

let mainEnumTypeFilePath = arguments[1]
let typeEnumTypeFilePath = arguments[2]
let outputFilePath = arguments[3]
let extensionFilePath = arguments[4]


//read main type
let mainUrl = URL(fileURLWithPath: mainEnumTypeFilePath)
guard let mainData = try? Data(contentsOf:mainUrl) else {
	fatalError("unable to read file \(mainUrl.path)")
}
guard let mainString = String(data:mainData, encoding:.utf8) else {
	fatalError("unable to interpret main source code file as UTF-8 string")
}
guard let mainDef = MainEnumParser(mainFile: mainString).mainEnumDefinition else {
	fatalError("Unable to read main enum definition")
}

//read type type
let typeUrl = URL(fileURLWithPath: typeEnumTypeFilePath)
guard let typeData = try? Data(contentsOf:typeUrl) else {
	fatalError("unable to read file \(typeUrl.path)")
}
guard let typeString = String(data:typeData, encoding:.utf8) else {
	fatalError("unable to interpret type source code file as UTF-8 string")
}
guard let typeDef = TypeEnumParser(typeFile: typeString).typeEnumDefinition else {
	fatalError("unable to remain type enum definition")
}

//read type property extension file
let extensionUrl = URL(fileURLWithPath: extensionFilePath)
guard let extensionData = try? Data(contentsOf:extensionUrl) else {
	fatalError("unable to read file \(extensionUrl.path)")
}
guard let extensionString = String(data:extensionData, encoding:.utf8) else {
	fatalError("unable to interpret extension source code file as UTF-8 string")
}
let extensionDef = EnumTypesFile(fileContents: extensionString)
guard let typePropertyName = extensionDef.enums.filter({ $0.enumName == mainDef.mainName }).first?.typePropertyName else {
	fatalError("unable to find extension for main enum")
}

let shouldDecode = mainDef.decodable && typeDef.decodable
let shouldEncode = mainDef.encodable && typeDef.encodable
//create the output file
let outputFile = DefaultCodableJSCreator(
	EnumCoderSpec(imports: extensionDef.imports
		,mainTypeName: mainDef.mainName
		,mainTypeIsPublic: mainDef.isPublic
		,typePropertyName: typePropertyName
		,typeTypeName: typeDef.mainName
		,typeTypeIsPublic:typeDef.isPublic
		,cases: mainDef.cases
		,createDecode:shouldDecode
		,createEncode:shouldEncode
	)
)
	.outputFile
	.data(using: .utf8)!

try outputFile.write(to: URL(fileURLWithPath: outputFilePath))
