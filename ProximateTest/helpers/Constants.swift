//
//  Constants.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import Foundation

let URL_BASE = "https://serveless.proximateapps-services.com.mx"
let END_POINT_LOGIN = "/catalog/dev/webadmin/authentication/login"
let END_POINT_PROFILE_DATA = "/catalog/dev/webadmin/users/getdatausersession"

let LOGOUT = "GO_TO_LOGOUT"
let LOGIN_DONE = "LOGIN_DONE"

let USER_DEFAULTS = "user_proximate"
let PASSWORD_DEFAULTS = "password_proximate"
let TOKEN_DEFAULTS = "token_proximate"

//MARK: - Database
let tableUser = "user"
let tableSection = "section"
let tableUserSection = "user_section"

//MARK: - Table user
let uFieldIdUser = "id_user"
let uFieldNames = "names"
let uFieldLastnames = "lastnames"
let uFieldEmail = "email"
let uFieldDocNumber = "document_number"
let uFieldLastLogin = "lastLogin"
let uFieldDeleted = "deleted"
let uFieldIdDocuments = "idDocuments"
let uFieldDocumentsAbb = "documents_abb"
let uFieldDocumentsLabel = "documents_label"
let uFieldUserStatusLabel = "user_status_label"
let uFieldPathPicture = "path_picture"
let uFieldLatitude = "latitude"
let uFieldLongitude = "longitude"

//MARK: - Table section
let sFieldIdSection = "id_section"
let sFieldSectionName = "section_name"
let sFieldAbbrev = "abbrev"

//MARK: - Table user_section
let usFieldIdUserSection = "id_user_section"
let usFieldIdUser = "id_user"
let usFieldIdSection = "id_section"
