//
//  FirstViewController.swift
//  fingerprintTest
//
//  Created by Yuriy Minin on 11/7/15.
//  Copyright © 2015 Yuriy Minin. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire

let baseURL = "http://api.codered.kirmani.io/lock"

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(netHex: 0xe1e0dd)
        lockStatement.backgroundColor = UIColor(netHex: 0xe1e0dd)
        lockButton.hidden = true
        lockImage.image = UIImage(named: "lock")
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var dankButton: UIView!
    @IBOutlet weak var lockStatement: UILabel!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var lockImage: UIImageView!
    
    @IBAction func hitMeWitDatJSON(sender: AnyObject) {
        Alamofire.request(.GET, baseURL + "/list").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let id_list = JSON(value)
                    print("JSON: \(id_list)")
                    for result in id_list["result"].arrayValue {
                        print(result.stringValue)
                        let url = baseURL + "/id/" + result.stringValue
                        Alamofire.request(.GET, url).validate().responseJSON { response in
                            switch response.result {
                            case .Success:
                                if let value = response.result.value {
                                    let input = JSON(value)
                                    print(input["result"]["image"])
                                }
                            case .Failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func lockButtonTouchUp(sender: UIButton) {
        Alamofire.request(.PUT, "http://api.codered.kirmani.io/lock/close")
        self.lockStatement.text = "Your Door is Locked"
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.lockImage.alpha = 100.0
            self.authButton.alpha = 100.0
            self.lockButton.hidden = true
            self.lockButton.alpha = 0.0
            
            }, completion: nil)
    }
    
    @IBAction func authenticateButtonTouchUp(sender: UIButton) {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to unlock your door."
        
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    Alamofire.request(.PUT, "http://api.codered.kirmani.io/lock/open")
                    dispatch_async(dispatch_get_main_queue()) {
                        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.lockImage.alpha = 0.0
                            self.authButton.alpha = 0.0
                            self.lockButton.hidden = false
                            self.lockButton.alpha = 100.0
                            
                            }, completion: nil)
                        self.lockStatement.text = "Your Door is Unlocked"
                    }
                    Alamofire.request(.GET, "http://api.codered.kirmani.io/lock/list").validate().responseJSON { response in
                        switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                let json = JSON(value)
                                print("JSON: \(json)")
                            }
                        case .Failure(let error):
                            print(error)
                        }
                    }
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                    default:
                        print("Authentication failed")
                    }
                }
                
            })]
        }
        else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            print(error?.localizedDescription)
            
        }
    }
    
    
}

