//
//  LoginViewController.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var tfEmail:UITextField!
    @IBOutlet var tfPassword:UITextField!
    var currentTf:UITextField?
    
    @IBOutlet var scroll:UIScrollView!
    
    var alertController:UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        registerForKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: .UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification:NSNotification){
        let info = notification.userInfo
        
        guard info != nil else {
            return
        }
        
        let kbSize=(info![UIKeyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero).size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scroll.contentInset = contentInsets;
        scroll.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height;
        
        guard currentTf != nil else {
            return
        }
        
        if (!aRect.contains(currentTf!.frame.origin) ) {
            self.scroll.scrollRectToVisible(currentTf!.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(notification:NSNotification){
        let contentInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInsets;
        scroll.scrollIndicatorInsets = contentInsets;
    }
    
    @IBAction func sendLogin(sender:UIButton){
        guard textFieldContainsText(textField: self.tfEmail) else {
            showAlertViewWith(title: "¡Aviso!", andMessage: "Campo de correo electrónico vacío.", completion: nil)
            return
        }
        
        guard textFieldContainsText(textField: self.tfPassword) else {
            showAlertViewWith(title: "¡Aviso!", andMessage: "Campo de contraseña vacío.", completion: nil)
            return
        }
        
        guard isValidEmail(email: self.tfEmail.text!) else {
            showAlertViewWith(title: "¡Aviso!", andMessage: "Correo electrónico inválido.", completion: nil)
            return
        }
        
        showActivityIndicator()
        
        NetworkManager.sendLoginRequest(credentials: (self.tfEmail.text!,self.tfPassword.text!)) { (dictResult, error) in
            self.hideActivityIndicator(completion: {
                if error != nil {
                    self.showAlertViewWith(title: "¡Aviso!", andMessage: error!, completion: nil)
                }else{
                    let message = dictResult!["message"] as? String ?? "Error inesperado."
                    let token = dictResult!["token"] as? String ?? ""
                    
                    if let errorBool = dictResult!["error"] as? Bool, errorBool == true{
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: nil)
                    }else if let successBool = dictResult!["success"] as? Bool, successBool == true, token != "" {
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: {
                            let defaults=UserDefaults.standard
                            
                            defaults.set(self.tfEmail.text!, forKey: USER_DEFAULTS)
                            defaults.set(self.tfPassword.text!, forKey: PASSWORD_DEFAULTS)
                            defaults.set(token, forKey: TOKEN_DEFAULTS)
                            defaults.synchronize()
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: LOGIN_DONE), object: nil)
                        })
                    }else{
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: nil)
                    }
                }
            })
        }
    }
    
    func textFieldContainsText(textField:UITextField) -> Bool{
        guard textField.text != nil else {
            return false
        }
        
        return textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
    }
    
    func isValidEmail(email:String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        
        return result
    }
    
    func showActivityIndicator(){
        OperationQueue.main.addOperation { () -> Void in
            self.alertController = UIAlertController(title: "Espere por favor.\n\n", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            indicator.frame=CGRect(x: 0, y: 20, width: self.alertController!.view.frame.size.width, height: self.alertController!.view.frame.size.height-20)
            indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.alertController?.view.addSubview(indicator)
            indicator.isUserInteractionEnabled = false
            indicator.startAnimating()
            
            self.alertController?.show()
        }
    }
    
    func hideActivityIndicator(completion:(() -> Void)?){
        OperationQueue.main.addOperation { () -> Void in
            if self.alertController != nil {
                self.alertController?.dismiss(animated: true, completion: completion)
            }
        }
    }
    
    func showAlertViewWith(title:String, andMessage message:String,completion:(() -> Void)?){
        OperationQueue.main.addOperation { () -> Void in
            let alertMessage = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            let alertAction=UIAlertAction(title: "Continuar", style: .default, handler: { (alertAction) in
                if completion != nil {
                    completion!()
                }
            })
            
            alertMessage.addAction(alertAction)
            
            alertMessage.show()
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTf = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTf = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.isEqual(self.tfEmail)){
            self.tfPassword.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil){
            return false
        }
        
        return true
    }
}
