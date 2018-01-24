//
//  NotificationManager.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 1/16/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationManager: NSObject {
    let localNotificationCenter = UNUserNotificationCenter.current()
    
    func notify(with message: String) {
        
        let content = UNMutableNotificationContent()
        content.title = "\(heyThereLocalized) \(UIDevice.current.name.replacingOccurrences(of: "'s iPhone", with: ""))!"
        content.body = message
        content.sound = UNNotificationSound(named: "notification.aiff")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: true)
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
        localNotificationCenter.add(request) { (error) in
            guard error == nil else {
                print("Couldn't display notification due to \(error!)")
                return
            }
            print("Notification is scheduled")
        }
    }
}
