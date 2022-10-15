//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation


struct NewTransaction : Decodable {
	var name:String
}

struct TransactionChange : Decodable {
	var id:String
	var name:String
}

struct TransactionDeletion : Decodable {
	var id:String
}
