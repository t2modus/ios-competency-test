//
//  Directory.swift
//  DirectoryListing
//
//  Created by Michael Steele on 2/21/17.
//
//

import UIKit
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm

class Directory: BaseEntity {
    var individuals : List<Individual> = List<Individual>()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        individuals <- (map["individuals"], ListTransform<Individual>()) // TODO: Remove
        //individuals <- (map, ListTransform<Individual>()) // TODO: Doesn't work right now with realm.  Need to research.  Usually we use a key for each data set.

    }

}
