//
//  NetworkManager.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    class func sendLoginRequest(credentials:(email:String,pass:String), completionBlock:((Dictionary<String,AnyObject>?,_ errorMessage:String?)->Void)!){
        let parameters = ["correo":credentials.email,"contrasenia":credentials.pass] as [String:Any]?
        
        Alamofire.request("\(URL_BASE)\(END_POINT_LOGIN)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                if let jsonResult = response.result.value as? Dictionary<String,AnyObject>{
                    completionBlock(jsonResult,nil)
                }else{
                    completionBlock(nil,"Usuario incorrecto.")
                }
            }else{
                completionBlock(nil,"Ocurrió un error al hacer el login, por favor reintente más tarde.")
            }
        }
    }
    
    class func getProfile(token: String, completionBlock:((Dictionary<String,AnyObject>?,_ errorMessage:String?)->Void)!){
        var request = URLRequest(url:  NSURL(string: "\(URL_BASE)\(END_POINT_PROFILE_DATA)")! as URL)
        
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                if let jsonResult = response.result.value as? Dictionary<String,AnyObject>{
                    completionBlock(jsonResult,nil)
                }else{
                    completionBlock(nil,"Sin información.")
                }
            }else{
                completionBlock(nil,"Ocurrió un error al obtener la información, por favor reintente más tarde.")
            }
        }
    }
}
