//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation

enum TransactionType : String, Decodable, Encodable {
	case add = "create"
	case update
	case delete
}
