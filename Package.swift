// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftCodableJSEnums",
	platforms: [
		//copied from swift-syntax
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
		.macCatalyst(.v13),
	],
    products: [
		.plugin(name: "SwiftCodableJSEnums", targets: ["SwiftCodableJSEnums"]),
		.executable(name: "SwiftCodableJSEnumsExec", targets:["SwiftCodableJSEnumsExec"]),
		.library(name: "ExampleProject", targets: ["ExampleProject"]),
    ],
    dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", exact: "508.0.0"),
    ],
    targets: [
		//The main product of this pakage, a plugin which creates alternate default decodable implementations
		.plugin(name: "SwiftCodableJSEnums"
				, capability: .buildTool()
				, dependencies: [
			.target(name: "SwiftCodableJSEnumsExec"),
		]),
		
		//an example of how you would call this plug-in for an project
		.target(name: "ExampleProject"
				, plugins: [
					"SwiftCodableJSEnums",
				]
		),
		
		//sample tests of ExampleProject to make it build, and so you can see it in action
		.testTarget(name: "ExampleProjectTests"
					, dependencies: [
			.target(name: "ExampleProject")
		]),
		
		//an underlying library which does the manipulation
		.target(
			name: "SwiftCodableJSEnumsLib"
			,dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxParser", package: "swift-syntax"),
			]
		),
		
		//en executable, required for plugins, which wraps calls to the library
		.executableTarget(name: "SwiftCodableJSEnumsExec"
				, dependencies: [
					.target(name: "SwiftCodableJSEnumsLib"),
					.product(name: "SwiftSyntax", package: "swift-syntax"),
					.product(name: "SwiftSyntaxParser", package: "swift-syntax"),
				]
						  //https://www.polpiella.dev/embedding-a-dylib-in-a-swift-package/
//						  ,linkerSettings: [
//							.unsafeFlags(["-rpath","/${BUILD_DIR}/${CONFIGURATION}/"])
//						  ]
						 ),
		
		//Unit Tests for the library
		.testTarget(name: "SwiftCodableJSEnumsLibTests"
					, dependencies: [
			.target(name: "SwiftCodableJSEnumsLib")
		]),
    ]
)
