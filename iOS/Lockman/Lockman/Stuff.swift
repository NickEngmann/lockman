//
//  Stuff.swift
//  fingerprintTest
//
//  Created by Yuriy Minin on 11/21/15.
//  Copyright © 2015 Yuriy Minin. All rights reserved.
//

import Foundation
import UIKit

class Stuff {
    var approval: Bool?
    var waiting: Bool?
    var image: String?
    var time: String?

init(json: NSDictionary) {
    self.approval = json["approval"] as? Bool
    self.waiting = json["waiting"] as? Bool
    self.image = json["image"] as? String
    self.time = json["time"] as? String 
    }
}