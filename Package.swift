// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDecodableJSEnums",
	platforms: [
		.macOS(.v12),
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(
//            name: "SwiftDecodableJSEnumsLib",
//            targets: ["SwiftDecodableJSEnumsLib"]),
		.plugin(name: "SwiftDecodableJSEnums", targets: ["SwiftDecodableJSEnums"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//		.package(url: "https://github.com/apple/swift-format.git", from: "0.50700.1"),
		.package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50700.1"),
    ],
    targets: [
		.target(
			name: "SwiftDecodableJSEnumsLib"
			,dependencies: [
//				.target(name: "SwiftFormat", package: "swift-format"),
				.product(name: "SwiftSyntax", package: "swift-syntax"),
//				.product(name: "SwiftFormat", package: "swift-format"),
//				.product(name: "SwiftFormatParser", package: "swift-format"),
			]
		),
		.executableTarget(name: "SwiftDecodableJSEnumsExec"
				, dependencies: [.target(name: "SwiftDecodableJSEnumsLib")]),
		.plugin(name: "SwiftDecodableJSEnums"
				, capability: .buildTool()
				, dependencies: [
			.target(name: "SwiftDecodableJSEnumsExec"),
			.target(name: "SwiftDecodableJSEnumsLib"),
		]),
		
		//an example of how you would call this plug-in for an ios project
		.target(name: "ExampleProject"
				, plugins: [
					"SwiftDecodableJSEnums",
				]
		),
		
		//sample tests of ExampleProject to make it build
		.testTarget(name: "ExampleProjectTests"
					, dependencies: [
			.target(name: "ExampleProject")
		]),
    ]
)
