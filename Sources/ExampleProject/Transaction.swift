//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/15/22.
//

import Foundation


enum Transaction : Decodable {
	case add(NewTransaction)
	case update(TransactionChange)
	case delete(TransactionDeletion)
}
