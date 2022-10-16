//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation


struct NewTransaction : Decodable, Encodable {
	var name:String
}

struct TransactionChange : Decodable, Encodable {
	var id:String
	var name:String
}

struct TransactionDeletion : Decodable, Encodable {
	var id:String
}
