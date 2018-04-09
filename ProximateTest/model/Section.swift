//
//  Section.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 08/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit
import FMDB

class Section: NSObject {
    var idSection:Int64
    var sectionName:String
    var abbrev:String
    
    override init() {
        idSection = 0
        sectionName = ""
        abbrev = ""
    }
    
    func bindResultSet(resultsSection: FMResultSet){
        idSection = Int64(resultsSection.int(forColumn: sFieldIdSection))
        sectionName = resultsSection.string(forColumn: sFieldSectionName) ?? ""
        abbrev = resultsSection.string(forColumn: sFieldAbbrev) ?? ""
    }
    
    func parseFromDictionary(dictResult: Dictionary<String,AnyObject>) {
        idSection = dictResult["id"] as? Int64 ?? 0
        sectionName = dictResult["seccion"] as? String ?? ""
        abbrev = dictResult["abrev"] as? String ?? ""
    }
}
