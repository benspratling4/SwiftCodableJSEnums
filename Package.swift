// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftDecodableJSEnums",
	platforms: [
		.macOS(.v12),
	],
    products: [
		.plugin(name: "SwiftDecodableJSEnums", targets: ["SwiftDecodableJSEnums"])
    ],
    dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50700.1"),
    ],
    targets: [
		//The main product of this pakage, a plugin which creates alternate default decodable implementations
		.plugin(name: "SwiftDecodableJSEnums"
				, capability: .buildTool()
				, dependencies: [
			.target(name: "SwiftDecodableJSEnumsExec"),
		]),
		
		//an example of how you would call this plug-in for an project
		.target(name: "ExampleProject"
				, plugins: [
					"SwiftDecodableJSEnums",
				]
		),
		
		//sample tests of ExampleProject to make it build, and so you can see it in action
		.testTarget(name: "ExampleProjectTests"
					, dependencies: [
			.target(name: "ExampleProject")
		]),
		
		//an underlying library which does the manipulation
		.target(
			name: "SwiftDecodableJSEnumsLib"
			,dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxParser", package: "swift-syntax"),
			]
		),
		
		//en executable, required for plugins, which wraps calls to the library
		.executableTarget(name: "SwiftDecodableJSEnumsExec"
				, dependencies: [
					.target(name: "SwiftDecodableJSEnumsLib"),
					.product(name: "SwiftSyntax", package: "swift-syntax"),
					.product(name: "SwiftSyntaxParser", package: "swift-syntax"),
				]
						  //https://www.polpiella.dev/embedding-a-dylib-in-a-swift-package/
						  ,linkerSettings: [
							.unsafeFlags(["-rpath","/${BUILD_DIR}/${CONFIGURATION}/"])
						  ]
						 ),
		
		//Unit Tests for the library
		.testTarget(name: "SwiftDecodableJSEnumsLibTests"
					, dependencies: [
			.target(name: "SwiftDecodableJSEnumsLib")
		]),
    ]
)
