//
//  DBManager.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit
import FMDB

class DBManager: NSObject {
    let databaseFileName = "proximateDB.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    static let shared: DBManager = DBManager()
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    let createUserTableQuery = "CREATE TABLE \(tableUser) (\(uFieldIdUser) INTEGER PRIMARY KEY NOT NULL, \(uFieldNames) TEXT, \(uFieldLastnames) TEXT, \(uFieldEmail) TEXT, \(uFieldDocNumber) TEXT, \(uFieldLastLogin) TEXT, \(uFieldDeleted) INTEGER, \(uFieldIdDocuments) INTEGER, \(uFieldDocumentsAbb) TEXT, \(uFieldDocumentsLabel) TEXT, \(uFieldUserStatusLabel) TEXT, \(uFieldPathPicture) TEXT, \(uFieldLatitude) DOUBLE, \(uFieldLongitude) DOUBLE)"
                    
                    let createSectionTableQuery = "CREATE TABLE \(tableSection) (\(sFieldIdSection) INTEGER PRIMARY KEY NOT NULL, \(sFieldSectionName) TEXT, \(sFieldAbbrev) TEXT)"
                    
                    let createUserSectionTableQuery = "CREATE TABLE \(tableUserSection) (\(usFieldIdUserSection) INTEGER PRIMARY KEY NOT NULL, \(usFieldIdUser) INTEGER NOT NULL, \(usFieldIdSection) INTEGER NOT NULL, FOREIGN KEY (\(usFieldIdUser)) REFERENCES \(tableUser), FOREIGN KEY (\(usFieldIdSection)) REFERENCES \(tableSection))"
                    
                    do {
                        try database.executeUpdate(createUserTableQuery, values: nil)
                        try database.executeUpdate(createSectionTableQuery, values: nil)
                        try database.executeUpdate(createUserSectionTableQuery, values: nil)
                        
                        created = true
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        
        return created
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
    func insertUserData(userData:User){
        if openDatabase(){
            let queryUser = "INSERT INTO \(tableUser) (\(uFieldIdUser), \(uFieldNames), \(uFieldLastnames), \(uFieldEmail), \(uFieldDocNumber), \(uFieldLastLogin) , \(uFieldDeleted), \(uFieldIdDocuments), \(uFieldDocumentsAbb), \(uFieldDocumentsLabel), \(uFieldUserStatusLabel), \(uFieldPathPicture), \(uFieldLatitude), \(uFieldLongitude)) VALUES (\(userData.idUser), '\(userData.names)', '\(userData.lastnames)', '\(userData.email)', '\(userData.documentNumber)', '\(userData.lastLogin)', \(userData.deleted),\(userData.idDocuments),'\(userData.documentsAbb)','\(userData.documentsLabel)', '\(userData.userStatusLabel)','\(userData.pathPicture)', \(userData.latitude), \(userData.longitude))"
            
            if !database.executeStatements(queryUser) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
                
                return
            }
            
            for (_,section) in userData.sections.enumerated() {
                let querySection = "INSERT INTO \(tableSection) (\(sFieldIdSection), \(sFieldSectionName), \(sFieldAbbrev)) VALUES (\(section.idSection), '\(section.sectionName)', '\(section.abbrev)')"
                
                if !database.executeStatements(querySection) {
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                    
                    break
                }
                
                let queryUserSection = "INSERT INTO \(tableUserSection) (\(usFieldIdUserSection), \(usFieldIdUser), \(usFieldIdSection)) VALUES (null, \(userData.idUser), \(section.idSection))"
                
                if !database.executeStatements(queryUserSection) {
                    print("Failed to insert initial data into the database.")
                    print(database.lastError(), database.lastErrorMessage())
                }
            }
        }
    }
    
    func loadUserData() -> User?{
        var user: User? = nil
        
        if openDatabase() {
            let queryUser = "select * from \(tableUser) order by \(uFieldIdUser) asc"
            
            do {
                let resultsUser = try database.executeQuery(queryUser, values: nil)
                
                if resultsUser.next() {
                    user = User()
                    
                    user?.bindResultSet(resultsUser: resultsUser)
                    
                    let querySection = "select s.\(sFieldIdSection) as \(sFieldIdSection), s.\(sFieldSectionName) as \(sFieldSectionName), s.\(sFieldAbbrev) as \(sFieldAbbrev) from \(tableSection) as s, \(tableUserSection) as us, \(tableUser) as u where s.\(sFieldIdSection) = us.\(usFieldIdSection) and us.\(usFieldIdUser) = u.\(usFieldIdUser) and u.\(usFieldIdUser) = ?"
                    
                    let resultsSection = try database.executeQuery(querySection, values: [user!.idUser])
                    
                    while resultsSection.next() {
                        let section = Section()
                        
                        section.bindResultSet(resultsSection: resultsSection)
                        
                        user?.sections.append(section)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return user
    }
    
    func updateUserData(userData:(idUser:Int64, picturePath:String, latitude: Double, longitude: Double)){
        if openDatabase() {
            let query = "UPDATE \(tableUser) SET \(uFieldPathPicture)=?, \(uFieldLatitude)=?, \(uFieldLongitude)=? where \(usFieldIdUser)=?"
            
            do {
                try database.executeUpdate(query, values: [userData.picturePath, userData.latitude, userData.longitude, userData.idUser])
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
    }
    
    func deleteUser() -> Bool {
        var deleted = false
        
        if openDatabase() {
            let queryDeleteUser = "DELETE FROM \(tableUser)"
            let queryDeleteSection = "DELETE FROM \(tableSection)"
            let queryDeleteUserSection = "DELETE FROM \(tableUserSection)"
            
            do {
                try database.executeUpdate(queryDeleteUser, values: nil)
                try database.executeUpdate(queryDeleteSection, values: nil)
                try database.executeUpdate(queryDeleteUserSection, values: nil)
                deleted = true
            }
            catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return deleted
    }
}
