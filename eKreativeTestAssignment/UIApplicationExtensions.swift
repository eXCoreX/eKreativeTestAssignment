//
//  UIApplicationExtensions.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 09.06.2021.
//

import SwiftUI

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
}
