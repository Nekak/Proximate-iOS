//
//  ProfileViewController.swift
//  ProximateTest
//
//  Created by Nekak Kinich on 06/04/18.
//  Copyright © 2018 Ramses Rodríguez. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var label:UILabel!
    @IBOutlet var textView:UITextView!
    @IBOutlet var button:UIButton!
    
    var alertController:UIAlertController?
    
    var locationManager:CLLocationManager?
    
    var currentLocation:CLLocation?
    
    var geocoder:CLGeocoder?
    
    var userData:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.isExclusiveTouch = true
        button.isExclusiveTouch = true
        
        label.adjustsFontSizeToFitWidth = true
        textView.isEditable = false
        textView.isSelectable = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(sender:)))
        tapGesture.numberOfTapsRequired = 1
        
        self.imageView.addGestureRecognizer(tapGesture)
        
        self.currentLocation = nil
        
        self.userData = DBManager.shared.loadUserData()
        
        if self.userData != nil{
            self.showUserData()
        }else{
            self.downloadUserProfile()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadUserProfile(){
        self.showActivityIndicator()
        
        let token=UserDefaults.standard.object(forKey: TOKEN_DEFAULTS) as? String ?? ""
        
        NetworkManager.getProfile(token: token, completionBlock: { (dictResult, error) in
            self.hideActivityIndicator(completion: {
                if error != nil {
                    self.showAlertViewWith(title: "¡Aviso!", andMessage: error!, completion: nil)
                }else{
                    let message = dictResult!["message"] as? String ?? "Error inesperado."
                    
                    if let errorBool = dictResult!["error"] as? Bool, errorBool == true{
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: nil)
                    }else if let successBool = dictResult!["success"] as? Bool, successBool == true, token != "" {
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: {
                            let auxUser = User()
                            
                            if let arrData = dictResult!["data"] as? Array<Dictionary<String,AnyObject>>{
                                if arrData.count > 0 {
                                    let dictUser = arrData[0]
                                    
                                    auxUser.parseFromDictionary(dictResult: dictUser)
                                    
                                    DBManager.shared.insertUserData(userData: auxUser)
                                    
                                    self.userData = DBManager.shared.loadUserData()
                                }
                                
                                self.showUserData()
                            }
                        })
                    }else{
                        self.showAlertViewWith(title: "¡Aviso!", andMessage: message, completion: nil)
                    }
                }
            })
        })
    }
    
    func showUserData(){
        // Do any additional setup after loading the view.
        if userData?.pathPicture == "" {
            label.text="Para tomar una foto, toque la imagen de la cámara."
        }else{
            if userData != nil {
                self.currentLocation = CLLocation(latitude: CLLocationDegrees(exactly: userData!.latitude)!, longitude: CLLocationDegrees(exactly: userData!.longitude)!)
                self.getImage(imageName: userData!.pathPicture)
            }
            
            loadAddress()
        }
        
        if userData != nil {
            let myString=NSMutableAttributedString(string: "")
            let boldAttribute = [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 20)] as [NSAttributedStringKey : Any]
            
            let name=NSAttributedString(string: "\(userData!.names) \(userData!.lastnames)\n\n", attributes: boldAttribute)
            
            myString.append(name)
            
            let mediumAttribute = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16)] as [NSAttributedStringKey : Any]
            
            let email = NSAttributedString(string: "\(userData!.email)\n\n", attributes: mediumAttribute)
            
            myString.append(email)
            
            let greyAttribute = [NSAttributedStringKey.foregroundColor:UIColor.darkGray] as [NSAttributedStringKey : Any]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let dateLL = formatter.date(from: userData!.lastLogin){
                let formatterLL = DateFormatter()
                formatterLL.dateFormat = "dd-MM-yyyy 'a las' HH:mm:ss"
                formatterLL.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                let dateStr = formatterLL.string(from: dateLL)
                
                let lastLogin = NSAttributedString(string: "Último inicio de sesión: \(dateStr)\n\n", attributes: greyAttribute)
                
                myString.append(lastLogin)
            }
            
            myString.append(NSAttributedString(string: "Secciones:\n\n"))
            
            for (_,section) in userData!.sections.enumerated() {
                myString.append(NSAttributedString(string: "\(section.sectionName)\n\n"))
            }
            
            textView.attributedText = myString
        }
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
    
    func loadAddress(){
        if self.geocoder == nil {
            self.geocoder=CLGeocoder()
        }
        
        guard self.currentLocation != nil else{
            return
        }
        
        self.label.text = "Fotografía tomada en las coordenadas: \(self.currentLocation!.coordinate.latitude),\(self.currentLocation!.coordinate.longitude)"
        
        self.geocoder?.reverseGeocodeLocation(self.currentLocation!, completionHandler: { (placemarks, error) -> Void in
            if placemarks != nil {
                let placeArr:Array<CLPlacemark>=(placemarks as Array<CLPlacemark>?)!
                if error == nil && placeArr.count > 0 {
                    let placemark=placeArr.last
                    self.label.text=String(format:"Fotografía tomada en: %@ %@ %@ %@ %@ %@",
                                           placemark!.subThoroughfare ?? "",
                                           placemark!.thoroughfare ?? "",
                                           placemark!.postalCode ?? "",
                                           placemark!.locality ?? "",
                                           placemark!.administrativeArea ?? "",
                                           placemark!.country ?? "")
                }
            }
        })
    }
    
    @objc func tapped(sender:UITapGestureRecognizer){
        self.currentLocation = nil
        
        self.locationManager=CLLocationManager()
        self.locationManager?.delegate=self
        self.locationManager?.desiredAccuracy=kCLLocationAccuracyBestForNavigation
        
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.requestWhenInUseAuthorization()
        
        self.locationManager?.startUpdatingLocation()
    }
    
    @IBAction func logout(sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name(rawValue: LOGOUT), object: nil)
    }
    
    func takePhoto(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            let imagePicker=UIImagePickerController()
            imagePicker.sourceType=UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureMode.photo
            imagePicker.cameraDevice=UIImagePickerControllerCameraDevice.rear
            imagePicker.showsCameraControls=true
            imagePicker.isNavigationBarHidden=false
            imagePicker.delegate=self
            
            self.present(imagePicker, animated: true, completion: nil)
        }else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == true {
            let imagePicker=UIImagePickerController()
            
            imagePicker.sourceType=UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate=self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
                self.imageView.image = image
                
                let path = self.savePicture()
                
                if self.currentLocation != nil && self.userData != nil {
                    let latitude = self.currentLocation!.coordinate.latitude as Double
                    let longitude = self.currentLocation!.coordinate.longitude as Double
                    
                    DBManager.shared.updateUserData(userData: (self.userData!.idUser, path, latitude, longitude))
                }
                
                self.loadAddress()
            }
        }
    }
    
    func savePicture() -> String{
        let fileManager = FileManager.default
        //get the image path
        let imageName = getPhotoFileName()
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the image we took with camera
        let image = imageView.image!
        //get the PNG data for this image
        let data = UIImagePNGRepresentation(image)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        
        return imageName
    }
    
    func getImage(imageName: String){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            imageView.image = UIImage(contentsOfFile: imagePath)
        }else{
            print("Panic! No Image!")
        }
    }
    
    func getPhotoFileName() -> (String){
        let defaults=UserDefaults.standard
        var uniqueID=defaults.object(forKey: "UniquePhotoIdentifier") as! String?
        
        if uniqueID == nil{
            let cfuuid:CFUUID=CFUUIDCreate(kCFAllocatorDefault)
            uniqueID=CFUUIDCreateString(kCFAllocatorDefault, cfuuid) as String?
            
            defaults.set(uniqueID, forKey: "UniquePhotoIdentifier")
            defaults.synchronize()
        }
        
        let fileName=String(format: "i%@%@.jpg",uniqueID!,String(format:"%.00f",Date().timeIntervalSince1970))
        return fileName;
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways{
            self.showActivityIndicator()
            
            self.locationManager?.startUpdatingLocation()
        } else if status == CLAuthorizationStatus.denied {
            let alertView=UIAlertController(title: "Servicios de localización no autorizados.", message: "Esta aplicación necesita que usted autorize los servicios de localización.", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction=UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            
            alertView.addAction(alertAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.hideActivityIndicator {
            OperationQueue.main.addOperation { () -> Void in
                let alertView=UIAlertController(title: "Error", message: "No se pudo obtener la ubicación.", preferredStyle: UIAlertControllerStyle.alert)
                let alertAction=UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                
                alertView.addAction(alertAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.hideActivityIndicator {
            guard self.currentLocation == nil else {
                return
            }
            
            if let cLocation = locations.last{
                self.currentLocation = cLocation
                
                self.locationManager?.stopUpdatingLocation()
                
                self.takePhoto()
            }
        }
    }
}
