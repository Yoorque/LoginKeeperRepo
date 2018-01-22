//
//  Reachability.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 1/22/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import Foundation
import SystemConfiguration

class Reachability: NSObject {
    func isReachable() -> Bool{
        let reachability = SCNetworkReachabilityCreateWithName(nil,"www.google.com")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        
        return flags.contains(.reachable)
    }
}
