//
//  eKreativeTestAssignmentApp.swift
//  eKreativeTestAssignment
//
//  Created by Rostyslav Litvinov on 09.06.2021.
//

import SwiftUI
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

@main
struct eKreativeTestAssignmentApp: App {
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) private var appDelegate
    private var fbLoginManager = LoginManager()
    
    init() {
        appDelegate.fbLoginManager = fbLoginManager
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(fbLoginManager: fbLoginManager)
                .onOpenURL(perform: { url in
                    ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
                    GIDSignIn.sharedInstance()?.handle(url)
                })
        }
    }
}

class MyAppDelegate: NSObject, UIApplicationDelegate, GIDSignInDelegate {
    @AppStorage("loginStatus") private var loginStatus = LoginStatus.loggedOut
    var fbLoginManager: LoginManager
    
    override init() {
        fbLoginManager = LoginManager()
        super.init()
    }
    
    init(fbLoginManager: LoginManager) {
        self.fbLoginManager = fbLoginManager
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Stub from google api docs
        
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Required actions on sign-in
        if loginStatus == .loggedInFacebook {
            fbLoginManager.logOut()
        }
        loginStatus = .loggedInGoogle
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Sign-out actions
        print(error?.localizedDescription ?? "")
        loginStatus = .loggedOut
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let resultFB = ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance()?.clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String
        GIDSignIn.sharedInstance()?.delegate = self
        return resultFB
    }
}
