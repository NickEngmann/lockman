//
//  SecondViewController.swift
//  fingerprintTest
//
//  Created by Yuriy Minin on 11/7/15.
//  Copyright © 2015 Yuriy Minin. All rights reserved.
//

import UIKit
import Alamofire

var lockID = ""
var faces = ""


class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(.GET, baseURL + "/list").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let id_list = JSON(value)
                    for result in id_list["result"].arrayValue {
                        let url = baseURL + "/id/" + result.stringValue
                        Alamofire.request(.GET, url).validate().responseJSON { response in
                            switch response.result {
                            case .Success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    self.peopleLabel.text = "You have " + json["result"]["faces"].stringValue + " friends in this photo."
                                    let image: UIImage = UIImage(data: NSData(base64EncodedString: json["result"]["image"].stringValue, options: NSDataBase64DecodingOptions())!)!
                                    self.img.image = image
                                    lockID = result.stringValue
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

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var peopleLabel: UILabel!
    
    @IBAction func approved(recognizer: UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.img.alpha = 0.0
            
            }, completion: nil)
        
        Alamofire.request(.PUT, baseURL + "/id/" + lockID + "/approve")
        print(baseURL + "/id/" + lockID + "/approve")
        
        Alamofire.request(.GET, baseURL + "/list").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let id_list = JSON(value)
                    for result in id_list["result"].arrayValue {
                        let url = baseURL + "/id/" + result.stringValue
                        Alamofire.request(.GET, url).validate().responseJSON { response in
                            switch response.result {
                            case .Success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    self.peopleLabel.text = "You have " + json["result"]["faces"].stringValue + " friends in this photo."
                                    let image: UIImage = UIImage(data: NSData(base64EncodedString: json["result"]["image"].stringValue, options: NSDataBase64DecodingOptions())!)!
                                    self.img.image = image
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
        UIView.animateWithDuration(0.4, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.img.alpha = 100.0
            
            }, completion: nil)
    }
    @IBAction func denied(recognizer: UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.img.alpha = 0.0
            
            }, completion: nil)
        
        Alamofire.request(.PUT, baseURL + "/id/" + lockID + "/deny")
        print(baseURL + "/id/" + lockID + "/deny")
        
        Alamofire.request(.GET, baseURL + "/list").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let id_list = JSON(value)
                    for result in id_list["result"].arrayValue {
                        let url = baseURL + "/id/" + result.stringValue
                        Alamofire.request(.GET, url).validate().responseJSON { response in
                            switch response.result {
                            case .Success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    self.peopleLabel.text = "You have " + json["result"]["faces"].stringValue + " friends in this photo."
                                    let image: UIImage = UIImage(data: NSData(base64EncodedString: json["result"]["image"].stringValue, options: NSDataBase64DecodingOptions())!)!
                                    self.img.image = image
                                    lockID = result.stringValue
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
        UIView.animateWithDuration(0.4, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.img.alpha = 100.0
            
            }, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

