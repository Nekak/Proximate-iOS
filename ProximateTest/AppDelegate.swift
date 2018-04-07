//
//  AppDelegate.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let user=UserDefaults.standard.object(forKey: USER_DEFAULTS) as? String
        
        if user == nil{
            self.window?.rootViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        }else{
            self.showProfile()
        }
        
        self.window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.loginDone), name: NSNotification.Name(rawValue: LOGIN_DONE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.logOut), name: NSNotification.Name(rawValue: LOGOUT), object: nil)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if DBManager.shared.createDatabase() {
            
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func showProfile(){
        self.window?.rootViewController=ProfileViewController(nibName: "ProfileViewController", bundle: nil)
    }
    
    @objc func loginDone(){
        OperationQueue.main.addOperation { () -> Void in
            self.showProfile()
        }
    }
    
    @objc func logOut(){
        OperationQueue.main.addOperation { () -> Void in
            let alert=UIAlertController(title: "Aviso", message: "¿Cerrar sesión?", preferredStyle: UIAlertControllerStyle.alert)
            let alertActionCancel=UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: nil)
            let alertAction=UIAlertAction(title: "Continuar", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
                self.doLogout();
            })
            
            alert.addAction(alertActionCancel)
            alert.addAction(alertAction)
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func doLogout(){
        DBManager.shared.deleteUser()
        
        self.deleteImages()
        
        let defaults=UserDefaults.standard
        
        defaults.removeObject(forKey: USER_DEFAULTS)
        defaults.removeObject(forKey: PASSWORD_DEFAULTS)
        defaults.removeObject(forKey: TOKEN_DEFAULTS)
        
        defaults.synchronize()
        
        let login=LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.window?.rootViewController=login
    }
    
    func deleteImages(){
        let fileManager = FileManager.default
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        do{
            let directoryContents = try fileManager.contentsOfDirectory(atPath: dirPath as String)
            
            for path in directoryContents {
                if path.hasSuffix("sqlite") == false {
                    let fullPath = dirPath.appendingPathComponent(path)
                    try fileManager.removeItem(atPath: fullPath)
                }
            }
        }catch{
            print("\(error)")
        }
    }
}

