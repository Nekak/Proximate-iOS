//
//  User.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 08/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit
import FMDB

class User: NSObject {
    var idUser:Int64
    var names:String
    var lastnames:String
    var email:String
    var documentNumber:String
    var lastLogin:String
    var deleted:Int64
    var idDocuments:Int64
    var documentsAbb:String
    var documentsLabel:String
    var userStatusLabel:String
    var sections:Array<Section>
    
    var pathPicture: String
    var latitude: Double
    var longitude: Double
    
    override init() {
        idUser = 0
        names = ""
        lastnames = ""
        email = ""
        documentNumber = ""
        lastLogin = ""
        deleted = 0
        idDocuments = 0
        documentsAbb = ""
        documentsLabel = ""
        userStatusLabel = ""
        sections = Array<Section>()
        
        pathPicture = ""
        latitude = 0
        longitude = 0
    }
    
    func bindResultSet(resultsUser: FMResultSet){
        idUser = Int64(resultsUser.int(forColumn: uFieldIdUser))
        names = resultsUser.string(forColumn: uFieldNames) ?? ""
        lastnames = resultsUser.string(forColumn: uFieldLastnames) ?? ""
        email = resultsUser.string(forColumn: uFieldEmail) ?? ""
        documentNumber = resultsUser.string(forColumn: uFieldDocNumber) ?? ""
        lastLogin = resultsUser.string(forColumn: uFieldLastLogin) ?? ""
        deleted = Int64(resultsUser.int(forColumn: uFieldDeleted))
        idDocuments = Int64(resultsUser.int(forColumn: uFieldIdDocuments))
        documentsAbb = resultsUser.string(forColumn: uFieldDocumentsAbb) ?? ""
        documentsLabel = resultsUser.string(forColumn: uFieldDocumentsLabel) ?? ""
        userStatusLabel = resultsUser.string(forColumn: uFieldUserStatusLabel) ?? ""
        
        pathPicture = resultsUser.string(forColumn: uFieldPathPicture) ?? ""
        latitude = resultsUser.double(forColumn: uFieldLatitude)
        longitude = resultsUser.double(forColumn: uFieldLongitude)
    }
    
    func parseFromDictionary(dictResult: Dictionary<String,AnyObject>) {
        idUser = dictResult["id"] as? Int64 ?? 0
        names = dictResult["nombres"] as? String ?? ""
        lastnames = dictResult["apellidos"] as? String ?? ""
        email = dictResult["correo"] as? String ?? ""
        documentNumber = dictResult["numero_documento"] as? String ?? ""
        lastLogin = dictResult["ultima_sesion"] as? String ?? ""
        deleted = dictResult["eliminado"] as? Int64 ?? 0
        idDocuments = dictResult["documentos_id"] as? Int64 ?? 0
        documentsAbb = dictResult["documentos_abrev"] as? String ?? ""
        documentsLabel = dictResult["documentos_label"] as? String ?? ""
        userStatusLabel = dictResult["estados_usuarios_label"] as? String ?? ""
        
        if let arrSections = dictResult["secciones"] as? Array<Dictionary<String,AnyObject>> {
            for (_,dictSection) in arrSections.enumerated() {
                let section = Section()
                
                section.parseFromDictionary(dictResult: dictSection)
                
                sections.append(section)
            }
        }
    }
}
