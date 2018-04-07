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
    static let shared: DBManager = DBManager()
    
    let databaseFileName = "proximateDB.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    let tableName = "user"
    
    let fieldUserId = "userId"
    let fieldName = "name"
    let fieldAge = "age"
    let fieldJob = "job"
    let fieldIntroduction = "introduction"
    let fieldPathPicture = "pathPicture"
    let fieldLatitude = "latitude"
    let fieldLongitude = "longitude"
    
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
                    let createUserTableQuery = "CREATE TABLE \(tableName) (\(fieldUserId) INTEGER PRIMARY KEY NOT NULL, \(fieldName) TEXT, \(fieldAge) INTEGER, \(fieldJob) TEXT, \(fieldIntroduction) TEXT, \(fieldPathPicture) TEXT, \(fieldLatitude) DOUBLE, \(fieldLongitude) DOUBLE)"
                    
                    do {
                        try database.executeUpdate(createUserTableQuery, values: nil)
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
    
    func insertUserData(userData:(name:String, age:Int, job:String, introduction:String, picturePath:String, latitude:Double, longitude:Double)){
        if openDatabase(){
            let query = "INSERT INTO \(tableName) (\(fieldUserId), \(fieldName),\(fieldAge),\(fieldJob),\(fieldIntroduction),\(fieldPathPicture),\(fieldLatitude),\(fieldLongitude)) VALUES (null, '\(userData.name)', \(userData.age), '\(userData.job)', '\(userData.introduction)', '\(userData.picturePath)',\(userData.latitude),\(userData.longitude))"
            
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
        }
    }
    
    func loadUserData() -> (idUser:Int,name:String, age:Int, job:String, introduction:String, picturePath:String, latitude: Double, longitude: Double)?{
        var tuple: (idUser:Int,name:String, age:Int, job:String, introduction:String, picturePath:String, latitude: Double, longitude: Double)? = nil
        
        if openDatabase() {
            let query = "select * from \(tableName) order by \(fieldUserId) asc"
            
            do {
                let results = try database.executeQuery(query, values: nil)
                
                if results.next() {
                    tuple = (idUser: Int(results.int(forColumn: fieldUserId)),
                             name:results.string(forColumn: fieldName) ?? "",
                             age: Int(results.int(forColumn: fieldAge)),
                             job:results.string(forColumn: fieldJob) ?? "",
                             introduction:results.string(forColumn: fieldIntroduction) ?? "",
                             picturePath:results.string(forColumn: fieldPathPicture) ?? "",
                             latitude: results.double(forColumn: fieldLatitude),
                             longitude: results.double(forColumn: fieldLongitude))
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
            database.close()
        }
        
        return tuple
    }
    
    func updateUserData(userData:(idUser:Int, picturePath:String, latitude: Double, longitude: Double)){
        if openDatabase() {
            let query = "UPDATE \(tableName) SET \(fieldPathPicture)=?, \(fieldLatitude)=?, \(fieldLongitude)=? where \(fieldUserId)=?"
            
            do {
                try database.executeUpdate(query, values: [userData.picturePath, userData.latitude, userData.longitude, userData.idUser,])
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
            let query = "DELETE FROM \(tableName)"
            
            do {
                try database.executeUpdate(query, values: nil)
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
